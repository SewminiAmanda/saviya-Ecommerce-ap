import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Map<String, dynamic> order;
  String? selectedStatus;
  bool isUpdating = false;
  int? currentUserId;

  final List<String> allowedStatuses = ["pending", "shipped", "delivered"];

  @override
  void initState() {
    super.initState();
    order = widget.order;
    selectedStatus = order['status'];
    _loadUser();
  }

  Future<void> _loadUser() async {
    currentUserId = await AuthService.getUserId();
    setState(() {});
  }

  Future<void> _updateStatus(String status) async {
    setState(() => isUpdating = true);
    bool success = await OrderService().updateOrderStatus(
      order['orderId'],
      status,
    );
    if (success) {
      setState(() {
        order['status'] = status;
        selectedStatus = status;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order status updated".tr())));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status".tr())));
    }
    setState(() => isUpdating = false);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  /// 🔹 Review Dialog
  Future<void> _showReviewDialog(int productId) async {
    final TextEditingController _commentController = TextEditingController();
    double rating = 3.0;
    final parentContext = context; // save parent context

    showDialog(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Submit"),
                  onPressed: () async {
                    Navigator.pop(context); // close dialog first
                    try {
                      await ProductService.addReview(
                        productId: productId,
                        rating: rating.toInt(),
                        comment: _commentController.text,
                      );

                      // Use the parent context here
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text("Review submitted!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text("Failed to submit review: $e")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSeller =
        currentUserId != null && currentUserId == order['seller']['userid'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${order['orderId']}"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Buyer & Seller Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Buyer & Seller Info".tr()),
                  _buildInfoRow(
                    "Buyer".tr(),
                    "${order['buyer']['first_name']} ${order['buyer']['last_name']}",
                  ),
                  _buildInfoRow(
                    "Seller".tr(),
                    "${order['seller']['first_name']} ${order['seller']['last_name']}",
                  ),
                  isSeller
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            DropdownButton<String>(
                              value: selectedStatus,
                              items: allowedStatuses
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.tr()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      if (value != null) _updateStatus(value);
                                    },
                            ),
                          ],
                        )
                      : _buildInfoRow("Status".tr(), order['status']),
                  _buildInfoRow("Payment".tr(), "${order['paymentStatus']}"),
                  _buildInfoRow("Total".tr(), "\$${order['totalAmount']}"),
                ],
              ),
            ),
          ),

          // Order Items
          _buildSectionTitle("Items".tr()),
          ...order['items'].map<Widget>(
            (item) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Qty: ${item['quantity']} | Price: \$${item['price']}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.rate_review, color: Colors.orange),
                  onPressed: () {
                    _showReviewDialog(item['productId']);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
