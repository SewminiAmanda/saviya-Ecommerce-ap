import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'upload_verification_page.dart';
import 'product/add_product.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../components/change_address_modal.dart';
import './order/order_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  String? firstName;
  String? lastName;
  String? email;
  int? userId;

  List<dynamic> products = [];
  List<dynamic> buyerOrders = [];
  List<dynamic> sellerOrders = [];

  bool isLoadingProducts = false;
  bool isLoadingOrders = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'Unknown';
      lastName = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? 'No email';
      userId = prefs.getInt('userid');
    });

    if (userId != null && userId! > 0) {
      fetchUserProducts();
      fetchOrders();
    }
  }

  Future<void> fetchUserProducts() async {
    setState(() => isLoadingProducts = true);
    final fetchedProducts = await ProductService.getUserProducts();
    if (mounted) {
      setState(() {
        products = fetchedProducts;
        isLoadingProducts = false;
      });
    }
  }

  Future<void> fetchOrders() async {
    setState(() => isLoadingOrders = true);
    final service = OrderService();

    final fetchedBuyerOrders = await service.getBuyerOrders();
    final fetchedSellerOrders = await service.getReceivedOrders();

    if (mounted) {
      setState(() {
        buyerOrders = fetchedBuyerOrders;
        sellerOrders = fetchedSellerOrders;
        isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsCard(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductTab(),
                _buildOrdersTab(
                  buyerOrders,
                  isLoadingOrders,
                  "No Buyer Orders",
                ),
                _buildOrdersTab(
                  sellerOrders,
                  isLoadingOrders,
                  "No Seller Orders",
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: _handleAddProduct,
      ),
    );
  }

  Widget _buildHeader() => Stack(
    children: [
      Container(
        color: Colors.orange,
        padding: const EdgeInsets.only(top: 50, bottom: 20),
        width: double.infinity,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/bg.jpg'),
            ),
            const SizedBox(height: 10),
            Text(
              "${firstName ?? ''} ${lastName ?? ''}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
      Positioned(
        right: 20,
        top: 60,
        child: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white),
          tooltip: 'Change Address'.tr(),
          onPressed: () {
            if (userId == null || userId == 0) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("User ID not found".tr())));
              return;
            }
            UpdateAddressModal(userId: userId!).show(context);
          },
        ),
      ),
    ],
  );

  Widget _buildStatsCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Products", products.length),
            _buildStatItem("Buyer Orders", buyerOrders.length),
            _buildStatItem("Seller Orders", sellerOrders.length),
          ],
        ),
      ),
    ),
  );

  Widget _buildStatItem(String title, int count) => Column(
    children: [
      Text(
        count.toString(),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Text(title, style: const TextStyle(color: Colors.grey)),
    ],
  );

  Widget _buildTabBar() => TabBar(
    controller: _tabController,
    labelColor: Colors.orange,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.orange,
    tabs: const [
      Tab(text: "Products"),
      Tab(text: "My orders"),
      Tab(text: "Recieved Orders"),
    ],
  );

  Widget _buildProductTab() {
    if (isLoadingProducts)
      return const Center(child: CircularProgressIndicator());
    if (products.isEmpty) return const Center(child: Text("No Products Found"));

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product['image'] != null
                      ? Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : const Icon(Icons.shopping_bag_outlined, size: 60),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      product['productName'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${product['price']}",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(
    List<dynamic> orders,
    bool loading,
    String emptyMessage,
  ) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return Center(child: Text(emptyMessage));

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[100],
              child: Text(
                order['orderId'].toString(),
                style: const TextStyle(color: Colors.orange),
              ),
            ),
            title: Text("Order #${order['orderId']}"),
            subtitle: Text(
              "Total: \$${order['totalAmount']} | ${order['status']}",
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage(order: order),
                ),
              );
            },
          ),
        );
      },
    );
  }



  Future<void> _handleAddProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isVerified = prefs.getBool('is_verified') ?? false;
    bool isRejected = prefs.getBool('is_rejected') ?? false;

    if (userId == null || userId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User ID not found".tr())));
      return;
    }

    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProductPage(userId: userId!),
        ),
      ).then((_) => fetchUserProducts());
    } else if (!isVerified && !isRejected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadVerificationPage(userId: userId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Verification Rejected".tr())));
    }
  }
}
