import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upload_verification_page.dart';
import 'product/add_product.dart';
import '../services/product_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? firstName;
  String? lastName;
  String? email;
  int? userId;
  int productCount = 0;
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
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
      fetchUserProducts(userId!);
    }
  }

  Future<void> fetchUserProducts(int userId) async {
    final fetchedProducts = await ProductService.getUserProducts();
    if (mounted) {
      setState(() {
        products = fetchedProducts;
        productCount = fetchedProducts.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.orange,
              ),
              const Positioned(
                bottom: -50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/bg.jpg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Center(
            child: Text(
              '${firstName ?? ''} ${lastName ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 15),

          // Product count + Add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      '$productCount products',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.grey[700]),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    bool isVerified = prefs.getBool('is_verified') ?? false;
                    bool isRejected = prefs.getBool('is_rejected') ?? false;

                    if (userId == null || userId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User ID not found.")),
                      );
                      return;
                    }

                    if (isVerified) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductPage(userId: userId!),
                        ),
                      ).then((_) {
                        fetchUserProducts(userId!);
                      });
                    } else if (!isVerified && !isRejected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UploadVerificationPage(userId: userId!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Your verification was rejected or blocked.",
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Added Products Section
          if (products.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Recent Added Products",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length < 3 ? products.length : 3,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          product['image'] != null &&
                                  product['image'].toString().isNotEmpty
                              ? Image.network(
                                  product['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 60,
                                ),
                          const SizedBox(height: 5),
                          Text(
                            product['productName'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "\$${product['price'] ?? '0'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
