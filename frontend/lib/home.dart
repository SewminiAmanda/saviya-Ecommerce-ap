import 'package:flutter/material.dart';
import 'header.dart';
import 'api_service.dart'; 
import 'category_page.dart';// Import the API service

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = [
    'assets/images/slideshow_1.jpeg',
    'assets/images/slideshow_2.jpg',
    'assets/images/slideshow_3.jpeg',
  ];

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<dynamic> categories = []; // List to store categories
  bool isLoading = true; // Flag to check if categories are loading
  String errorMessage = ''; // String to store error message

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _getCategories(); // Fetch categories on page load
  }

  void _startAutoSlide() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        int nextPage = (_currentIndex + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = nextPage;
        });
        _startAutoSlide();
      }
    });
  }

  // Fetch categories from the API
  void _getCategories() async {
    try {
      List<dynamic> fetchedCategories = await ApiService.getCategories(); // Call the API method
      setState(() {
        categories = fetchedCategories; // Update the state with fetched categories
        isLoading = false; // Set loading to false once categories are fetched
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load categories: $e'; // Display error message
        isLoading = false; // Set loading to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomHeader(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Slideshow
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20), // Spacing

            // Order Status Row
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOrderStatus(Icons.payment, "To Pay"),
                  _buildOrderStatus(Icons.local_shipping, "To Ship"),
                  _buildOrderStatus(Icons.delivery_dining, "Shipped"),
                  _buildOrderStatus(Icons.rate_review, "To Review"),
                  _buildOrderStatus(Icons.keyboard_return, "Return"),
                ],
              ),
            ),

            SizedBox(height: 20), // Spacing

            // "Categories" Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Loading or Error handling
            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : SizedBox(
                        height: 700,
                        child: GridView.builder(
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryItem(
                              'assets/images/default_category.jpeg',
                              categories[index]['categoryname'],
                              categories[index]['categoryid'] ?? 2
                            );
                          },
                        ),
                      ),

            SizedBox(height: 0), // Spacing

            // Footer Section
            _buildFooter(),
          ],
        ),
      ),
    );
  }

Widget _buildCategoryItem(String imageUrl, String categoryName, int categoryid) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryPage(categoryName: categoryName, categoryid: categoryid),
        ),
      );
    },
    child: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
          SizedBox(height: 5),
          Text(
            categoryName,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}



  // Widget to build order status
  Widget _buildOrderStatus(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: Color(0xFFF39C12)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Footer Widget
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: Color(0xFFF39C12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Address Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "123 Street, Colombo, Sri Lanka",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "contact@company.com",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Social Media Section
          Column(
            children: [
              Text(
                "Follow Us",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.facebook, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Icon(Icons.camera_alt, color: Colors.white, size: 24), // Instagram
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
