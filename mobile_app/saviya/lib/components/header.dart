import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../home.dart';
import '../profile_page.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 16, top: 4),
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
          // Center - Logo
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
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
              IconButton(icon: const Icon(Icons.search), onPressed: () {},
              tooltip: 'search'.tr(),
              ),

              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                tooltip: 'cart'.tr(),
              ),

              // Language switcher
              PopupMenuButton<String>(
                icon: const Icon(Icons.translate),
                onSelected: (String lang) {
                  // Change the app locale
                  context.setLocale(Locale(lang));
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'en', child: Text("English")),
                  PopupMenuItem(value: 'si', child: Text("සිංහල")),
                  PopupMenuItem(value: 'ta', child: Text("தமிழ்")),
                ],
                
              ),

              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                tooltip: 'profile'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
