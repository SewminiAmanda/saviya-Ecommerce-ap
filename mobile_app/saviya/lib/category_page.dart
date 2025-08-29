import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components/header.dart';
import 'components/product_card.dart';
import 'package:easy_localization/easy_localization.dart';

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
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/product/category/${widget.categoryid}',
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> fetchedProducts = decoded['products'] ?? [];

        if (fetchedProducts.isEmpty) {
          setState(() {
            errorMessage = "no_products_available".tr();
            isLoading = false;
          });
          return;
        }

        final userIds = fetchedProducts
            .map((product) => product['userId'] as int?)
            .whereType<int>()
            .toSet();

        final futures = userIds.map((id) async {
          try {
            final userResponse = await http.get(
              Uri.parse('http://10.0.2.2:8080/api/users/$id'),
              headers: {"Content-Type": "application/json"},
            );

            if (userResponse.statusCode == 200) {
              final userJson = jsonDecode(userResponse.body);
              final userData = userJson['user'] ?? userJson;

              final firstName =
                  userData['first_name'] ?? userData['firstName'] ?? '';
              final lastName =
                  userData['last_name'] ?? userData['lastName'] ?? '';
              final sellerName = "$firstName $lastName".trim();

              return MapEntry(
                id,
                sellerName.isNotEmpty
                    ? sellerName
                    : 'supplier'.tr(args: [id.toString()]),
              );
            } else {
              return MapEntry(id, 'Supplier'.tr(args: [id.toString()]));
            }
          } catch (e) {
            return MapEntry(id, 'supplier'.tr(args: [id.toString()]));
          }
        });

        final results = await Future.wait(futures);
        final sellerMap = Map<int, String>.fromEntries(results);

        setState(() {
          products = fetchedProducts;
          sellerNames = sellerMap;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "failed_to_load_products".tr(
            args: [response.statusCode.toString()],
          );
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "connection_error".tr(args: [e.toString()]);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(),
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
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey[700],
                            ),
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
                          _buildTab("products".tr(), true),
                          const SizedBox(width: 80),
                          _buildTab("sellers".tr(), false),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: showProducts
                            ? _buildProductList()
                            : Center(
                                child: Text(
                                  "sellers_list_not_implemented".tr(),
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
        tooltip: 'refresh'.tr(),
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
            ElevatedButton(onPressed: fetchProducts, child: Text("retry".tr())),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "no_products_found".tr(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text("try_another_category".tr()),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product['productId'] ?? 0;
        final userId = product['userId'] ?? 0;
        final sellerName =
            sellerNames[userId] ?? 'supplier'.tr(args: [userId.toString()]);

        final imageUrl = (product['image']?.toString().isNotEmpty ?? false)
            ? product['image'].toString()
            : 'https://via.placeholder.com/150';

        return ProductCard(
          productId: productId,
          productName:
              product['productName']?.toString() ?? 'unnamed_product'.tr(),
          price: product['price']?.toString() ?? '0',
          quantity: product['quantity']?.toString() ?? '0',
          minQuantity: product['minQuantity']?.toString() ?? '1',
          sellerName: sellerName,
          imageUrl: imageUrl,
          description:
              product['description']?.toString() ?? 'no_description'.tr(),
          sellerId: userId,
        );
      },
    );
  }
}
