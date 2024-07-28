import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/service/database.dart';
import 'package:logger/logger.dart';

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
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication?.idToken,
          accessToken: googleSignInAuthentication?.accessToken);

      UserCredential result =
          await firebaseAuth.signInWithCredential(credential);

      User? userDetails = result.user;

      logger.i("Google sign-in successful: ${userDetails?.email}");
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        "id": userDetails.uid
      };
      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        logger.i("User data added to database for user: ${userDetails.uid}");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    } catch (e) {
      logger.e("Error during Google Sign-In: $e");
    }
  }
}
