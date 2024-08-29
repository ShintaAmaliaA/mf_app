import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  EditTransactionPage({required this.transaction, required String id});

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _description;
  late String _amount;
  late bool _isIncome;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _category = widget.transaction.category;
    _description = widget.transaction.description;
    _amount = widget.transaction.amount.toString();
    _isIncome = widget.transaction.type == 'income';
    _selectedDate = widget.transaction.date;
  }

  _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("transaksi/${widget.transaction.id}");

        TransactionModel updatedTransaction = TransactionModel(
          id: widget.transaction.id,
          userId: user.uid,
          amount: double.parse(_amount),
          category: _category,
          description: _description,
          date: _selectedDate,
          type: _isIncome ? 'income' : 'expense',
        );

        await ref.set(updatedTransaction.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is signed in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How much?',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                initialValue: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                ),
                onChanged: (value) {
                  _amount = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                items: <String>[
                  'Infaq',
                  'Sedekah',
                  'Donation',
                  'Salary',
                  'Zakat',
                  'Others'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isIncome = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isIncome ? Colors.green : Colors.grey,
                      ),
                      child: Text('Income'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isIncome = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isIncome ? Colors.red : Colors.grey,
                      ),
                      child: Text('Expense'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Pick your date',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: '${_selectedDate.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
