import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'uploadVerificationPage.dart'; 
import 'product/addProduct.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? firstName;
  String? lastName;
  String? email;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'Unknown';
      lastName = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? 'No email';
      userId = prefs.getInt('userid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.orange,
              ),
              const Positioned(
                bottom: -50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/agri.png'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Center(
            child: Text(
              '${firstName ?? ''} ${lastName ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.grey[700]),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  bool isVerified = prefs.getBool('is_verified') ?? false;
                  bool isRejected = prefs.getBool('is_rejected') ?? false;

                  if (userId == null || userId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User ID not found.")),
                    );
                    return;
                  }

                  if (isVerified) {
                    print("Navigating to AddProductPage with userId: $userId");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddProductPage(userId: userId!),
                      ),
                    );
                  } else if (!isVerified && !isRejected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadVerificationPage(userId: userId!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your verification was rejected or blocked.",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


