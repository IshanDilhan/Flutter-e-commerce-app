import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:myapp/screens/sign_up_page.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({super.key});

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final TextEditingController resetEmailController = TextEditingController();
  String email = "";
  final _formkey = GlobalKey<FormState>();
  void resetPassword() async {
    var logger = Logger();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      logger.i("Password reset email sent to: $email");

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text(
      //   "Password Reset Email has been sent!",
      //   style: TextStyle(fontSize: 20.0),
      // )));
      // Navigate to login page
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        logger.w("No user found for email: $email");

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 20.0),
        )));
      } else {
        logger.e("Error during password reset: ${e.message}");
      }
    } catch (e) {
      logger.e("Unexpected error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(context),
                _inputField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(context) {
    return const Column(
      children: [
        Text(
          "Reset Email",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your email"),
      ],
    );
  }

  Widget _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: resetEmailController,
          decoration: InputDecoration(
            hintText: "email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            if (_formkey.currentState!.validate()) {
              setState(() {
                email = resetEmailController.text;
              });
              resetPassword();
            }
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding:
                  const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 58, 7, 99),
                  borderRadius: BorderRadius.circular(30)),
              child: const Center(
                  child: Text(
                "Send e-mail",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? "),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        )
      ],
    );
  }
}
