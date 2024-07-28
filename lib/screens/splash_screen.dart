import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupPage()),
      );
    });
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
            )
          ],
        )),
      ),
    );
  }
}
