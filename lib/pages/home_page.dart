import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../statitics/statistic.dart';
import 'add_transaction.dart';
import 'edit_page.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    StatisticsPage(),
    AddTransactionPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.black, // Warna label untuk item yang dipilih
      unselectedItemColor:
          Colors.black, // Warna label untuk item yang tidak dipilih
      showSelectedLabels: true, // Menampilkan label pada item yang dipilih
      showUnselectedLabels:
          true, // Menampilkan label pada item yang tidak dipilih
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart, color: Colors.black),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add, color: Colors.black),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.black),
          label: 'Profile',
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('transaksi');

  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  void _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userId = user?.uid;
    });
    _fetchTransactions();
  }

  void _fetchTransactions() {
    if (_userId == null) return;

    _databaseReference
        .orderByChild('userId')
        .equalTo(_userId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<TransactionModel> transactionsList = [];
        double income = 0.0;
        double expense = 0.0;

        data.forEach((key, value) {
          final transactionSnapshot = event.snapshot.child(key);
          final transaction =
              TransactionModel.fromSnapshot(transactionSnapshot);

          final transactionDate = DateFormat('dd MMMM yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(
                  transaction.date.millisecondsSinceEpoch));

          if (transactionDate == _selectedDate) {
            transactionsList.add(transaction);

            if (transaction.type == 'income') {
              income += transaction.amount;
            } else {
              expense += transaction.amount;
            }
          }
        });

        setState(() {
          _transactions = transactionsList;
          _totalIncome = income;
          _totalExpense = expense;
          _balance = _totalIncome - _totalExpense;
        });
      } else {
        setState(() {
          _transactions = [];
          _totalIncome = 0.0;
          _totalExpense = 0.0;
          _balance = 0.0;
        });
      }
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('dd MMMM yyyy').format(picked);
      });
      _fetchTransactions();
    }
  }

  void _deleteTransaction(String id) {
    _databaseReference.child(id).remove();
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 207, 203),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Text(
                        _selectedDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 218, 207, 203),
                          backgroundImage: AssetImage('assets/img/logo.png'),
                          radius: 25,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account Balance',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _balance.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IncomeExpenseCard(
                      amount: _totalIncome.toStringAsFixed(1),
                      label: 'Pendapatan',
                      color: Colors.green,
                    ),
                    IncomeExpenseCard(
                      amount: _totalExpense.toStringAsFixed(1),
                      label: 'Pengeluaran',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._transactions.map((transaction) {
                  return TransactionItem(
                    transaction: transaction,
                    onDelete: () => _deleteTransaction(transaction.id),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeExpenseCard extends StatelessWidget {
  final String amount;
  final String label;
  final Color color;

  const IncomeExpenseCard({
    Key? key,
    required this.amount,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: transaction.type == 'income'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transaction.type == 'income'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color:
                      transaction.type == 'income' ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd MMM yyyy').format(transaction.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                transaction.amount.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTransactionPage(
                        transaction: transaction,
                        id: '',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
