import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'home_page.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  String _category = 'Infaq';
  String _description = '';
  String _amount = '';
  bool _isIncome = true;
  DateTime _selectedDate = DateTime.now();

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
        DatabaseReference ref = FirebaseDatabase.instance.ref("transaksi");

        DatabaseReference transactionRef = ref.push();
        String transactionId = transactionRef.key!;

        TransactionModel newTransaction = TransactionModel(
          id: transactionId,
          userId: user.uid,
          amount: double.parse(_amount),
          category: _category,
          description: _description,
          date: _selectedDate,
          type: _isIncome ? 'income' : 'expense',
        );

        await transactionRef.set(newTransaction.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
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
        title: Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    'Zakat',
                    'Donasi',
                    'Wakaf',
                    'Pembangunan',
                    'Pengembangan',
                    'Pemeliharaan',
                    'Operasional',
                    'Program Sosial',
                    'Program Dakwah',
                    'Program Kemanusiaan',
                    'Lainnya'
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
                          backgroundColor:
                              _isIncome ? Colors.green : Colors.grey,
                        ),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: _isIncome ? Colors.white : Colors.black,
                          ),
                        ),
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
                          backgroundColor:
                              !_isIncome ? Colors.red : Colors.grey,
                        ),
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: !_isIncome ? Colors.white : Colors.black,
                          ),
                        ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Teks berwarna putih
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
