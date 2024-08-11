import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/paid_details_model.dart';

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final Logger _logger = Logger();
  late Future<List<PaidDetailsModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<PaidDetailsModel>> _fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _logger.w('No user is logged in.');
      return [];
    }

    try {
      _logger.i('Fetching transactions for user: ${user.uid}');

      // Fetch transactions for the current user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('transactionDate', descending: true)
          .get();

      _logger.i('Fetched ${snapshot.docs.length} transactions successfully.');

      // Convert the snapshot to a list of PaidDetailsModel
      List<PaidDetailsModel> transactions = snapshot.docs.map((doc) {
        return PaidDetailsModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return transactions;
    } catch (e) {
      _logger.e('Error fetching transactions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: FutureBuilder<List<PaidDetailsModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Logger().e('Error displaying transactions: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found.'));
          } else {
            List<PaidDetailsModel> transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text('Transaction ID: ${transaction.id}'),
                  subtitle: Text('Amount: ${transaction.transactionAmount}'),
                  trailing: Text(transaction.transactionDate
                      .toDate()
                      .toLocal()
                      .toString()), // Adjust date format as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
