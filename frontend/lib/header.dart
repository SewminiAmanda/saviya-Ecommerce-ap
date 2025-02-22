import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 60,
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
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          
          // Center - Logo
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,

              ),
            ),
          ),
          
          // Right side - Icons
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}