// ignore: file_names
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class StripeService {
  final String endpoint = "https://api.stripe.com/v1/payment_intents";

  Future<Map<String, dynamic>?> requestPaymentIntent(String amount) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer ${dotenv.env['SECRET_KEY']}",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "amount": amount,
          "currency": "usd", // Specify the correct currency
        },
      );

      if (response.statusCode == 200) {
        Logger().i('Payment Intent Created: ${response.body}');
        return jsonDecode(response.body);
      } else {
        Logger().e('Failed to create Payment Intent: ${response.body}');
        return null;
      }
    } catch (e) {
      Logger().e('Error creating Payment Intent: $e');
      return null;
    }
  }
}
