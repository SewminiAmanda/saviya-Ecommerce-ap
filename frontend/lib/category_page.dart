import 'package:flutter/material.dart';
import 'header.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final int categoryid;
  final String categoryImage;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryid,
    this.categoryImage = "assets/images/default_category.jpeg", // Default image
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool showProducts = true; // Default selection is "Products"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          CustomHeader(),

          // Stack for Half Circle and Content
          Expanded(
            child: Stack(
              children: [
                // Background Half Circle with Image
                Positioned(
                  top: -150, // Adjust to fine-tune placement
                  left: -70,
                  right: -70,
                  child: Container(
                    height: 390, // Adjust height for a larger half-circle
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(400), // Creates half-circle effect
                      ),
                      image: DecorationImage(
                        image: AssetImage(widget.categoryImage),
                        fit: BoxFit.cover, // Ensures image fills the half-circle
                      ),
                    ),
                  ),
                ),

                // Content Section (Placed after the half-circle)
                Positioned(
                  top: 260, // Place content below the half-circle
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30), // Increased spacing below category title

                      // **Text Tabs (Products & Sellers)**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // **Products Tab**
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showProducts = true;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Products',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: showProducts ? Colors.orange : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (showProducts)
                                  Container(
                                    height: 3,
                                    width: 70,
                                    color: Colors.orange, // Underline
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 150), 

                          // **Sellers Tab**
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showProducts = false;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Sellers',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: !showProducts ? Colors.orange : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (!showProducts)
                                  Container(
                                    height: 3,
                                    width: 70,
                                    color: Colors.orange, // Underline
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30), // **Increased spacing below the tabs**

                      // **Conditional Content Display**
                      showProducts
                          ? Text("Displaying Products List...")
                          : Text("Displaying Sellers List..."),
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
}
