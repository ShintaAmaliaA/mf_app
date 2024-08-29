import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan import ini

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('transaksi');
  double _income = 0.0;
  double _expense = 0.0;
  DateTimeRange? _selectedDateRange;
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
    _fetchTransactionData(); // Panggil fungsi ini setelah mendapatkan userId
  }

  void _fetchTransactionData({DateTimeRange? dateRange}) {
    if (_userId == null) return;

    _databaseReference
        .orderByChild('userId')
        .equalTo(_userId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        double income = 0.0;
        double expense = 0.0;

        data.forEach((key, value) {
          final type = value['type'] ?? '';
          final amount = double.tryParse(value['amount'].toString()) ?? 0.0;
          final date = DateTime.tryParse(value['date'] ?? '') ?? DateTime.now();

          if (dateRange == null ||
              (date.isAfter(dateRange.start) && date.isBefore(dateRange.end))) {
            if (type == 'income') {
              income += amount;
            } else if (type == 'expense') {
              expense += amount;
            }
          }
        });

        setState(() {
          _income = income;
          _expense = expense;
        });
      }
    });
  }

  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _fetchTransactionData(dateRange: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedDateRange != null)
              Text(
                'From: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)}\n'
                'To: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            const Text(
              'Income vs Expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _showingSections(),
                  centerSpaceRadius: 60,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(color: Colors.green, text: 'Income'),
                const SizedBox(width: 16),
                _buildIndicator(color: Colors.red, text: 'Expense'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final total = _income + _expense;
    final incomePercentage = (total == 0) ? 0 : (_income / total) * 100;
    final expensePercentage = (total == 0) ? 0 : (_expense / total) * 100;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: incomePercentage.toDouble(),
        title: '${incomePercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: expensePercentage.toDouble(),
        title: '${expensePercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
