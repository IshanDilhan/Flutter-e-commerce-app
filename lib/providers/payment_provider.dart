import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/models/paid_details_model.dart';
import 'package:myapp/screens/Admin/payment_details.dart';
import 'package:myapp/services/sripe_service.dart';

class PaymentProvider extends ChangeNotifier {
  StripeService service = StripeService();

  Future<void> getPayment(
      String amount, List<CarModel> cars, BuildContext context) async {
    try {
      // Step 1: Request payment intent from Stripe
      Map<String, dynamic>? intent = await service.requestPaymentIntent(amount);

      if (intent != null) {
        Logger().i(
            'Payment Intent created successfully: ${intent['client_secret']}');

        // Step 2: Initialize PaymentSheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intent['client_secret'],
            merchantDisplayName: "Car App",
          ),
        );

        Logger().i('PaymentSheet initialized successfully');

        // Step 3: Present PaymentSheet
        await Stripe.instance.presentPaymentSheet().then((value) async {
          Logger().i("Payment Success");

          // Store transaction details after payment success
          return storeTransactionDetails(cars, amount);
        }).then((_) {
          // Navigate after the transaction details have been stored
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentDetailsPage(),
            ),
          );

          notifyListeners();
        }).catchError((e) {
          Logger().e('Error presenting PaymentSheet: $e');
          _showErrorSnackbar("Payment failed. Please try again.", context);
        });
      } else {
        Logger().e('Failed to create Payment Intent');
        _showErrorSnackbar(
            // ignore: use_build_context_synchronously
            "Failed to create payment intent. Please try again.",
            // ignore: use_build_context_synchronously
            context);
      }
    } catch (e) {
      Logger().e('Error during payment process: $e');
      // ignore: use_build_context_synchronously
      _showErrorSnackbar("An error occurred. Please try again.", context);
    }
  }

  Future<void> storeTransactionDetails(
      List<CarModel> cars, String amount) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        // Create a PaidDetailsModel instance
        PaidDetailsModel paidDetails = PaidDetailsModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          userEmail: user.email ?? '',
          cars: cars,
          transactionAmount: (double.parse(amount) * 0.01).toStringAsFixed(2),
          transactionDate: Timestamp.now(),
          paymentMethod: 'Stripe', // Example payment method
          transactionStatus: 'Completed', // Example status
        );

        // Store the transaction data in Firestore
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(paidDetails.id)
            .set(paidDetails.toJson());

        Logger().i('Transaction details stored successfully');
      } else {
        Logger().e('No authenticated user found');
      }
    } catch (e) {
      Logger().e('Failed to store transaction details: $e');
    }
  }

  void _showErrorSnackbar(String message, BuildContext context) {
    // Show error message (assuming context is available)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
