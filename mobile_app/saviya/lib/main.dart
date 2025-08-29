import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'cart.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure EasyLocalization is initialized
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fbkovdupdbumqkqrzeys.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZia292ZHVwZGJ1bXFrcXJ6ZXlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExOTk0NjksImV4cCI6MjA2Njc3NTQ2OX0.q0-ylimYskgsyy-bihpJgEmTI_I4lY5dutMbPH1TLrU',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartService()..fetchCart()),
          ChangeNotifierProvider(create: (_) => OrderService()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDrive Shop',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const LoginPage(),
      routes: {'/cart': (context) => const CartPage()},
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
