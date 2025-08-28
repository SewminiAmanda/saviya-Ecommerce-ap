import 'package:flutter/material.dart';
import '../chat/chat_page.dart'; // Make sure this import path is correct
import '../header.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productName;
  final String price;
  final String quantity;
  final String sellerName;
  final String imageUrl;
  final String description;
  final int sellerId;

  const ProductDetailsPage({
    Key? key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.sellerName,
    required this.imageUrl,
    required this.description,
    required this.sellerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = '123'; // Replace with actual logged-in user ID

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 60),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
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

                    // Price and Seller section
                    Text(
                      'Price: Rs. $price',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller: $sellerName',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TalkJsChatPage(
                                  currentUserId: currentUserId,
                                  currentUserName: 'John Doe',
                                  currentUserEmail: 'johndoe@example.com',
                                  currentUserPhotoUrl:
                                      'https://i.pravatar.cc/150?img=1',
                                  otherUserId: sellerId.toString(),
                                  otherUserName: sellerName,
                                  otherUserEmail: '$sellerId@supplier.com',
                                  otherUserPhotoUrl:
                                      'https://i.pravatar.cc/150?img=2',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Contact Supplier',
                            style: TextStyle(
                              color: Colors.orange,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Quantity: $quantity',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

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

                    // Add To Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
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
                    const SizedBox(height: 12),

                    // Buy Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceeding to buy now'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Buy Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
