import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Add a list of TransactionModel to hold the transactions
  List<TransactionModel> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction.category),
            subtitle: Text(transaction.type),
            trailing: Text(transaction.amount.toString()),
          );
        },
      ),
    );
  }
}
