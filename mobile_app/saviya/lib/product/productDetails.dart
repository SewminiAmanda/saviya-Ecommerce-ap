import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/header.dart';
import '../services/cart_service.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productName;
  final double price;
  final int quantity;
  final int minQuantity;
  final String sellerName;
  final String imageUrl;
  final String description;
  final int sellerId;
  final int productId;

  const ProductDetailsPage({
    Key? key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.minQuantity,
    required this.sellerName,
    required this.imageUrl,
    required this.description,
    required this.sellerId,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 60),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Name
                    Center(
                      child: Text(
                        productName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price and Seller
                    Text(
                      'Price: Rs. ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Seller: $sellerName',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Available Stock: $quantity',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Product Description
                    const Text(
                      'Product Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 40),

                    // Add To Cart with quantity dialog
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          int? selectedQty = await showDialog<int>(
                            context: context,
                            builder: (context) {
                              final TextEditingController qtyController =
                                  TextEditingController(
                                    text: minQuantity.toString(),
                                  );

                              return AlertDialog(
                                title: const Text('Select Quantity'),
                                content: TextField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter quantity (min $minQuantity)',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final qty = int.tryParse(
                                        qtyController.text.trim(),
                                      );
                                      if (qty == null ||
                                          qty < minQuantity ||
                                          qty > quantity) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Invalid quantity"),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context, qty);
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (selectedQty != null) {
                            final success = await cartService.addToCart(
                              productId,
                              selectedQty,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Added to cart"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("❌ Failed to add to cart"),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Add to Cart",
                          style: TextStyle(color: Colors.orange),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
