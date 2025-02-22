import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home.dart';
import 'api_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: const Color(
                0x7A262525), // 0x7A = 47% opacity + hex color #262525
          ),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _inputField(context, emailController, passwordController),
                  const SizedBox(height: 20),
                  _loginButton(context, emailController, passwordController),
                  const SizedBox(height: 30),
                  _googleButton(context),
                  const SizedBox(height: 16),
                  _facebookButton(context),
                  const SizedBox(height: 50),
                  _createAccountLink(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _header(BuildContext context) {
  return const SizedBox(
    height: 400,
    width: 352,
    child: Image(
      image: AssetImage("assets/images/logo.png"),
      fit: BoxFit.cover,
    ),
  );
}

Widget _inputField(BuildContext context, TextEditingController emailController, TextEditingController passwordController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 300,
        child: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Email",
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.person, color: Colors.white),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: 300,
        child: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.lock, color: Colors.white),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
        ),
      ),
    ],
  );
}


Widget _loginButton(BuildContext context,TextEditingController emailController, TextEditingController passwordController) {
  return Center(
    child: SizedBox(
      width: 300,
      child: OutlinedButton(
        onPressed: () async {
          String email = emailController.text.trim();
          String password = passwordController.text.trim();
          
           if (email.isNotEmpty && password.isNotEmpty) {
            try {
              var response = await ApiService.loginUser(email: email, password: password);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login Successful! Welcome, ${response['user']['first_name']}')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login Failed: ${e.toString()}')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter email and password')),
            );
          
          }
          
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

Widget _googleButton(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDF9929),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          "Sign in with Google",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

Widget _facebookButton(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDF9929),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          "Sign in with Facebook",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

Widget _createAccountLink(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center, // Centers the row elements
    children: [
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        },
        child: const Text(
          "Create an Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      const SizedBox(width: 80), // Adds space between the buttons
      TextButton(
        onPressed: () {
          // Navigate to Forgot Password page
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );
}
