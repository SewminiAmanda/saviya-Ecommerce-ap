import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'header.dart';
import 'product/product_card.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final int categoryid;
  final String imageurl;
  final String description;
  final int sellerId; 

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryid,
    required this.imageurl,
    required this.description,
    required this.sellerId,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool showProducts = true;
  List<dynamic> products = [];
  Map<int, String> sellerNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/product/category/${widget.categoryid}',
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> fetchedProducts = decoded['products'] ?? [];

        final userIds = fetchedProducts
            .map((product) => int.tryParse(product['userId'].toString()))
            .whereType<int>()
            .toSet();

        final futures = userIds.map((id) async {
          try {
            final userResponse = await http.get(
              Uri.parse('http://10.0.2.2:8080/api/users/$id'),
              headers: {"Content-Type": "application/json"},
            );
            print("User ID: $id, Response: ${userResponse.body}");

            if (userResponse.statusCode == 200) {
              final userJson = jsonDecode(userResponse.body);
              final userData = userJson['user'];

              final sellerName =
                  "${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}"
                      .trim();

              return MapEntry(
                id,
                sellerName.isNotEmpty ? sellerName : 'Unknown Seller',
              );
            } else {
              return MapEntry(id, 'Unknown Seller');
            }
          } catch (e) {
            print("Error fetching user $id: $e");
            return MapEntry(id, 'Unknown Seller');
          }
        });

        final results = await Future.wait(futures);
        final sellerMap = Map<int, String>.fromEntries(results);

        setState(() {
          products = fetchedProducts;
          sellerNames = sellerMap;
          isLoading = false;
        });
        print("Products fetched: ${products.length}");
        print("Sellers fetched: ${sellerNames.length}");
      } else {
        throw Exception("Failed to fetch products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: -150,
                  left: -70,
                  right: -70,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(400),
                    ),
                    child: Image.network(
                      widget.imageurl,
                      height: 390,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 390,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 60),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 260,
                  left: 40,
                  right: 20,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          _buildTab("Products", true),
                          const SizedBox(width: 150),
                          _buildTab("Sellers", false),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: showProducts
                            ? _buildProductList()
                            : const Center(
                                child: Text(
                                  "Sellers List not implemented yet.",
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isProductTab) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showProducts = isProductTab;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: showProducts == isProductTab
                  ? Colors.orange
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (showProducts == isProductTab)
            Container(height: 3, width: 70, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("No products available."));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final userId = int.tryParse(product['userId'].toString()) ?? -1;
        final sellerName = sellerNames.containsKey(userId)
            ? sellerNames[userId]!
            : 'Fetching...';

        final imageUrl =
            (product['image'] != null && product['image'].toString().isNotEmpty)
            ? product['image']
            : 'https://via.placeholder.com/90';

        print(
          "Product ID: ${product['id']}, User ID: $userId, Seller: $sellerName",
        );

        return ProductCard(
          productName: product['productName'] ?? 'Unknown Product',
          price: product['price']?.toString() ?? '0',
          quantity: product['quantity']?.toString() ?? '0',
          sellerName: sellerName,
          imageUrl: imageUrl,
          description: product['description'] ?? 'No description available.',
          sellerId: userId,
        );
      },
    );
  }
}
