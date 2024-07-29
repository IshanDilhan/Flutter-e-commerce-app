import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:myapp/screens/sign_up_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    listenauthState();
  }

  Future<void> listenauthState() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        Logger().i('User is currently signed out!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        Logger().i('User is signed in!');
        Logger().i(user);

        Map<String, dynamic>? userInfo = await fetchUserData(user.uid);

        if (userInfo != null) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        }
      }
    });
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('User').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(215, 16, 16, 16),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg7.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 300),
                child: Text(
                  'Ride time car sale',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 241, 246, 251),
                    fontSize: 30, // Increased font size for better visibility
                    fontFamily: 'Anta', // Custom font family
                    fontWeight: FontWeight.bold, // Bold font weight
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.white.withOpacity(0.5), // Shadow color
                        offset: const Offset(2, 2), // Shadow offset
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: const CupertinoActivityIndicator(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
