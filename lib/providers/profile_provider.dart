import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserInfoProvider with ChangeNotifier {
  Map<String, dynamic> _userInfoMap = {
    "email": "",
    "userId": "",
    "username": "",
    "imageURL": "",
  };

  Map<String, dynamic> get userInfo => _userInfoMap;
  UserInfoProvider() {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();
        _userInfoMap = userDoc.data() as Map<String, dynamic>;
        notifyListeners();
      } catch (e) {
        Logger().e('Failed to load user info: $e');
      }
    }
  }

  void setUserInfo(Map<String, dynamic> userInfo) {
    _userInfoMap = userInfo;
    Logger().i("User info saved: $userInfo");
    notifyListeners();
  }

  void updateUserInfo(String key, dynamic value) {
    _userInfoMap[key] = value;
    Logger().i("User info saved: $value");
    notifyListeners();
  }
}
