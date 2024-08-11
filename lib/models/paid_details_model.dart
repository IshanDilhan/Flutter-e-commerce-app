import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/car_model.dart';

class PaidDetailsModel {
  String id; // Unique ID for the transaction
  String userId; // ID of the user who made the transaction
  String userName; // Name of the user
  String userEmail; // Email of the user
  List<CarModel> cars; // List of cars included in the transaction
  String transactionAmount; // Total amount paid in the transaction
  Timestamp transactionDate; // Date and time of the transaction
  String paymentMethod; // Method used for payment (e.g., Credit Card, PayPal)
  String
      transactionStatus; // Status of the transaction (e.g., Completed, Pending)

  PaidDetailsModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cars,
    required this.transactionAmount,
    required this.transactionDate,
    required this.paymentMethod,
    required this.transactionStatus,
  });

  factory PaidDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaidDetailsModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      cars: (json['cars'] as List).map((e) => CarModel.fromJson(e)).toList(),
      transactionAmount: json['transactionAmount'],
      transactionDate: json['transactionDate'],
      paymentMethod: json['paymentMethod'],
      transactionStatus: json['transactionStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'cars': cars.map((e) => e.toJson()).toList(),
      'transactionAmount': transactionAmount,
      'transactionDate': transactionDate,
      'paymentMethod': paymentMethod,
      'transactionStatus': transactionStatus,
    };
  }
}
