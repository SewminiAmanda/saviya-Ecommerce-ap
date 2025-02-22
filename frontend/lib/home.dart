import 'package:flutter/material.dart';
import 'header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomHeader(),
      ),
      body: Center(child: Text('Home Page Content')), 
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
