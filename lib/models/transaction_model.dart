import 'package:firebase_database/firebase_database.dart';

class TransactionModel {
  late final String id;
  final String category;
  final String type; // 'income' or 'expense'
  final double amount;
  final DateTime date;
  final String userId;
  final String description;

  TransactionModel({
    required this.id,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    required this.userId,
    required this.description,
  });

  // Factory method to create a TransactionModel from Firebase data
  factory TransactionModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;

    return TransactionModel(
      id: snapshot.key ?? '',
      category: data['category'] as String? ?? 'Uncategorized',
      type: data['type'] as String? ?? 'expense',
      amount: double.tryParse(data['amount'].toString()) ?? 0.0,
      date:
          DateTime.parse(data['date'] as String? ?? DateTime.now().toString()),
      userId: data['userId'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  // Method to convert TransactionModel to a map for saving to Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'amount': amount.toString(),
      'date': date.toIso8601String(),
      'userId': userId,
      'description': description,
    };
  }
}
