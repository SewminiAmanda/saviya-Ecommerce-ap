import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _inputField(context),
                ],
              ))),
    );
  }
}

_header(context) {
  return const Column(children: [
    // saviya logo image
  ]);
}

_inputField(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        style: const TextStyle(
          color: Colors.white, // Set text color to white
          fontSize: 13, // Set font size to 13px (Flutter uses logical pixels)
        ),
        decoration: InputDecoration(
          hintText: "Username",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6), // Hint text color
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white, // Bottom border color
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white, // Bottom border color when focused
              width: 2, // Increase thickness when focused
            ),
          ),
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.white, // Icon color
          ),
          // Remove the fillColor and filled properties to make it transparent
        ),
      ),
    ],
  );
}
