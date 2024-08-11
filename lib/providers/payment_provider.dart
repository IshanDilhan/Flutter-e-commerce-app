import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:myapp/services/Sripe_service.dart';

class PaymentProvider extends ChangeNotifier {
  StripeService service = StripeService();

  Future<void> getPayment(String amount, BuildContext context) async {
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
        await Stripe.instance.presentPaymentSheet().then((value) {
          Logger().i("Payment Success");
          notifyListeners();
        }).catchError((e) {
          Logger().e('Error presenting PaymentSheet: $e');
          _showErrorSnackbar("Payment failed. Please try again.", context);
        });
      } else {
        Logger().e('Failed to create Payment Intent');
        _showErrorSnackbar(
            "Failed to create payment intent. Please try again.", context);
      }
    } catch (e) {
      Logger().e('Error during payment process: $e');
      _showErrorSnackbar("An error occurred. Please try again.", context);
    }
  }

  void _showErrorSnackbar(String message, BuildContext context) {
    // Show error message (assuming context is available)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
