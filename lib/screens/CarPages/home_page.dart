import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/profile_provider.dart';
import 'package:myapp/screens/Sign_In_Pages/login_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Consumer<UserInfoProvider>(
            builder: (context, userInfoProvider, child) {
              final username = userInfoProvider.userInfo["username"];

              return username == null
                  ? const CircularProgressIndicator()
                  : Text('Welcome, $username to Tea app',
                      style: const TextStyle(fontSize: 20));
            },
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarListingPage()),
              );
            },
            child: const Text('Browse Cars'),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactPage()),
              );
            },
            child: const Text('Contact Us'),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Logout logic here
              _logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

class CarListingPage extends StatelessWidget {
  const CarListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Listings')),
      body: const Center(child: Text('Car Listings Page')),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Center(child: Text('Contact Us Page')),
    );
  }
}
