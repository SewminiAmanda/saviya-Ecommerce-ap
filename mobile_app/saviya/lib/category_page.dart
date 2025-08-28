import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components/header.dart';
import 'components/product_card.dart';

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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Fetching products for category ${widget.categoryid}');
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/product/category/${widget.categoryid}',
        ),
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> fetchedProducts = decoded['products'] ?? [];

        print('Fetched ${fetchedProducts.length} products');
        print(
          'First product: ${fetchedProducts.isNotEmpty ? fetchedProducts[0] : "N/A"}',
        );

        // Temporary: Accept null IDs for debugging
        final validProducts = fetchedProducts.where((product) {
          final productId = product['productId'];
          final userId = product['userId'];
          print('Product ID: $productId, User ID: $userId');
          return true; // Accept all products for now
        }).toList();

        if (validProducts.isEmpty) {
          setState(() {
            errorMessage = "No products available in this category";
            isLoading = false;
          });
          return;
        }

        final userIds = validProducts
            .map((product) => product['userId'] as int?)
            .whereType<int>()
            .toSet();

        print('Unique user IDs: $userIds');

        final futures = userIds.map((id) async {
          try {
            print('Fetching user details for ID: $id');
            final userResponse = await http.get(
              Uri.parse('http://10.0.2.2:8080/api/users/$id'),
              headers: {"Content-Type": "application/json"},
            );

            print('User response for $id: ${userResponse.statusCode}');
            if (userResponse.statusCode == 200) {
              final userJson = jsonDecode(userResponse.body);
              final userData =
                  userJson['user'] ?? userJson; // Try both structures
              print('User data: $userData');

              final firstName =
                  userData['first_name'] ?? userData['firstName'] ?? '';
              final lastName =
                  userData['last_name'] ?? userData['lastName'] ?? '';
              final sellerName = "$firstName $lastName".trim();

              return MapEntry(
                id,
                sellerName.isNotEmpty ? sellerName : 'Supplier $id',
              );
            } else {
              return MapEntry(id, 'Supplier $id');
            }
          } catch (e) {
            print('Error fetching user $id: $e');
            return MapEntry(id, 'Supplier $id');
          }
        });

        final results = await Future.wait(futures);
        final sellerMap = Map<int, String>.fromEntries(results);

        print('Final seller map: $sellerMap');
        print('Valid products count: ${validProducts.length}');

        setState(() {
          products = validProducts;
          sellerNames = sellerMap;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load products (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in fetchProducts: $e');
      setState(() {
        errorMessage = "Connection error: ${e.toString()}";
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
      floatingActionButton: FloatingActionButton(
        onPressed: fetchProducts,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
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

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchProducts,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text("No products found", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Try another category or check back later"),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product['id'];
        final userId = product['userId'];
        final sellerName = sellerNames[userId] ?? 'Supplier $userId';

        print('Building product card for index $index:');
        print('Product ID: $productId');
        print('User ID: $userId');
        print('Product data: $product');

        final imageUrl = (product['image']?.toString().isNotEmpty ?? false)
            ? product['image'].toString()
            : 'https://via.placeholder.com/150';

        return ProductCard(
          productId: product['productId'],
          productName: product['productName']?.toString() ?? 'Unnamed Product',
          price: product['price']?.toString() ?? '0',
          quantity: product['quantity']?.toString() ?? '0',
          minQuantity: product['minQuantity'].toString(),
          sellerName: sellerName,
          imageUrl: imageUrl,
          description:
              product['description']?.toString() ?? 'No description available.',
          sellerId: userId ?? 0, // Temporary fallback for null user IDs
        );
      },
    );
  }
}
