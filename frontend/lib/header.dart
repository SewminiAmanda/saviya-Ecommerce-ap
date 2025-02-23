import 'package:flutter/material.dart';
import 'home.dart'; // Make sure to import HomePage

class CustomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Menu icon
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),

          // Center - Enlarged Logo (Shifted Right)
          GestureDetector(
            onTap: () {
              // Directly navigate to HomePage when logo is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20,), // Moves the logo to the right
              child: Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
            ),
          ),

          // Right side - Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
