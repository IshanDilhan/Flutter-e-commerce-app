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

  void clearUserInfo() {
    _userInfoMap = {
      "email": "",
      "userId": "",
      "username": "",
      "imageURL": "",
    };
    Logger().i("User info cleared");
    notifyListeners();
  }
}
