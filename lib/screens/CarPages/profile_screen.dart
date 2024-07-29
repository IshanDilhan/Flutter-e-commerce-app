import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/Admin/admin_page.dart';
import 'package:myapp/screens/Sign_In_Pages/login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController editusernamecontroler = TextEditingController();
  String? username;

  String? email;
  @override
  void initState() {
    super.initState();
    // Use widget.username if it's already passed or fetch from Firestore if not

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();
      setState(() {
        username = userDoc['username'];
        email = userDoc['email'];
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({'username': newUsername});
        // Optionally, you can show a success message or handle post-update logic here
        Logger().i('username updated');
      } catch (e) {
        // Handle errors here, for example by showing an error message
        Logger().i('Failed to update username: $e');
      }
    } else {
      // Handle the case where no user is signed in
      Logger().i('No user is signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Background Image Container
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/2.jpg"),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Profile Image Container
              GestureDetector(
                onTap: () {
                  // Placeholder for profile image picking logic
                },
                child: Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: const NetworkImage(
                        "https://www.gravatar.com/avatar?d=mp"), // Placeholder image
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black.withOpacity(0.5),
                            child: const Icon(
                              Icons.edit,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                username ?? 'Loading...', // Replace with dynamic data if needed
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email ?? 'Loading...', // Replace with dynamic data if needed
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: () {
                  // Logout logic here
                  _logout(context);
                },
                child: const Text('Logout'),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: editusernamecontroler,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                        height:
                            20), // Increased spacing for better visual separation
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Background color of the button
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0), // Padding inside the button
                      ),
                      onPressed: () async {
                        String newUsername = editusernamecontroler.text;
                        try {
                          await updateUsername(newUsername);
                          // Refresh user data after update
                          await fetchUserData();
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Username updated successfully!')),
                          );
                        } catch (error) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to update username: $error')),
                          );
                        }
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white), // Adjusted text style
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        },
        child: const Icon(Icons.admin_panel_settings_sharp),
      ),
    );
  }
}
