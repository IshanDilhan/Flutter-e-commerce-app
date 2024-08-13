import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/providers/profile_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/service/database.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var logger = Logger();

  getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        logger.e("Google Sign-In aborted by user");
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result =
          await firebaseAuth.signInWithCredential(credential);

      User? userDetails = result.user;

      if (userDetails == null) {
        logger.e("Failed to retrieve user details after Google Sign-In");
        return;
      }

      logger.i("Google sign-in successful: ${userDetails.email}");

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.displayName,
        "imageURL": userDetails.photoURL,
        "userId": userDetails.uid,
        "favourite": [],
        "cartItems": [],
      };

      // ignore: use_build_context_synchronously
      context.read<UserInfoProvider>().setUserInfo(userInfoMap);
      logger.i("User info saved in provider");

      await DatabaseMethods().addUser(userDetails.uid, userInfoMap);
      logger.i("User data added to database for user: ${userDetails.uid}");

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      logger.e("Error during Google Sign-In: $e");
    }
  }
}
