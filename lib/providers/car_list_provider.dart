import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';

class CarListProvider extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> favourites = [];
  List<String> carts = [];

  CarListProvider() {
    _initializeUserData();
  }
  Future<void> _initializeUserData() async {
    await initializeUserDocument();
    await fetchFavoriteCarIds();
    await fetchCartCarIds();
  }

  Future<void> initializeUserDocument() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('User').doc(user?.uid).set({
          'favourite': [],
          'cartItems': [],
        });
        Logger().i('User document created');
      } else {
        Logger().i('User document already exists');
      }
    } catch (e) {
      Logger().e('Error initializing user document: $e');
    }
  }

  Future<void> fetchFavoriteCarIds() async {
    await initializeUserDocument();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final favoriteCars = List<dynamic>.from(data?['favourite'] ?? []);

        final favoriteCarIds = favoriteCars
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['id'] as String;
              } else {
                return '';
              }
            })
            .where((id) => id.isNotEmpty)
            .toList();

        favourites = favoriteCarIds;
        notifyListeners();
        Logger().i(favoriteCarIds);
      }
    } catch (e) {
      Logger().e('Error fetching favorite car IDs: $e');
    }
  }

  Future<void> fetchCartCarIds() async {
    await initializeUserDocument();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final cartCars = List<dynamic>.from(data?['cartItems'] ?? []);

        final cartCarIds = cartCars
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['id'] as String;
              } else {
                return '';
              }
            })
            .where((id) => id.isNotEmpty)
            .toList();

        carts = cartCarIds;
        notifyListeners();
        Logger().i('carts : $carts');
      }
    } catch (e) {
      Logger().e('Error fetching cart car IDs: $e');
    }
  }

  Future<void> addToFavorites(CarModel car) async {
    await initializeUserDocument();
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .update({
        'favourite': FieldValue.arrayUnion([car.toJson()]),
      });
      favourites.add(car.id);
      notifyListeners();
      Logger().i('Car "${car.carName}" added to favorites.');
    } catch (e) {
      Logger().e('Error adding car to favorite: $e');
    }
    notifyListeners();
  }

  Future<void> removeFromFavorites(CarModel car) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .update({
        'favourite': FieldValue.arrayRemove([car.toJson()]),
      });
      favourites.remove(car.id);
      notifyListeners();
      Logger().i('Car "${car.carName}" removed from favorite.');
    } catch (e) {
      Logger().e('Error removing car from favorites: $e');
    }
  }

  bool isFavorite(String carId) {
    return favourites.contains(carId);
  }

  Future<void> addToCart(CarModel car) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .update({
        'cartItems': FieldValue.arrayUnion([car.toJson()]),
      });
      carts.add(car.id);
      notifyListeners();
      Logger().i('Car "${car.carName}" added to cart.');
    } catch (e) {
      Logger().e('Error adding car to cart: $e');
    }
    notifyListeners();
  }

  Future<void> removeFromCart(CarModel car) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .update({
        'cartItems': FieldValue.arrayRemove([car.toJson()]),
      });
      carts.remove(car.id);
      notifyListeners();
      Logger().i('Car "${car.carName}" removed from cart.');
    } catch (e) {
      Logger().e('Error removing car from cart: $e');
    }
  }

  bool isCart(String carId) {
    return carts.contains(carId);
  }
}
