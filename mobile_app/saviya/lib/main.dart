import 'package:flutter/material.dart';
import 'login_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: 'https://fbkovdupdbumqkqrzeys.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZia292ZHVwZGJ1bXFrcXJ6ZXlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExOTk0NjksImV4cCI6MjA2Njc3NTQ2OX0.q0-ylimYskgsyy-bihpJgEmTI_I4lY5dutMbPH1TLrU'
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
