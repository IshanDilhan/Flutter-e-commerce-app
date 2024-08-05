import 'package:myapp/models/car_model.dart';

class UserModel {
  String email;
  String userId;
  String username;
  List<CarModel> favourite;
  List<CarModel> cartItems;
  String imageURL;

  UserModel({
    required this.email,
    required this.userId,
    required this.username,
    required this.favourite,
    required this.cartItems,
    this.imageURL = "https://www.gravatar.com/avatar?d=mp",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      userId: json['userId'],
      username: json['username'],
      favourite:
          (json['favourite'] as List).map((e) => CarModel.fromJson(e)).toList(),
      cartItems:
          (json['cartItems'] as List).map((e) => CarModel.fromJson(e)).toList(),
      imageURL: json['imageURL'] ?? "https://www.gravatar.com/avatar?d=mp",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userId': userId,
      'username': username,
      'favourite': favourite.map((e) => e.toJson()).toList(),
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
      'imageURL': imageURL,
    };
  }
}
