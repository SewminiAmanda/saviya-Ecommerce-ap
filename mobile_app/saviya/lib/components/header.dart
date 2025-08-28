import 'package:flutter/material.dart';
import '../home.dart';
import '../profile_page.dart';


class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left - Menu icon
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),

          // Center - Logo
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset('assets/images/logo.png', height: 100),
            ),
          ),

          // Right - Icons
          Row(
            children: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),

              // Translate Icon
              IconButton(
                icon: const Icon(Icons.translate),
                onPressed: () {
                },
              ),

              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
