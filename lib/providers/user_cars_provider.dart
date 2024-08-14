import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';

class CarProvider with ChangeNotifier {
  List<CarModel> _cars = [];
  bool _isLoading = false;
  final Logger _logger = Logger();

  List<CarModel> get cars => _cars;
  bool get isLoading => _isLoading;

  Future<void> fetchCars() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _logger.e("No user is currently logged in.");
      throw Exception("No user is currently logged in.");
    }

    _isLoading = true;
    // notifyListeners();

    _logger.i("Fetching cars for user: ${user.uid}");
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cars')
        .orderBy('registrationDateTime', descending: true)
        .get();

    _cars = snapshot.docs
        .map((doc) => CarModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    _logger.i("Fetched ${_cars.length} cars.");
    _isLoading = false;
    notifyListeners();
  }
}
