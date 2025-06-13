import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../model/transaction_model.dart';
import '../component/transaction_list.dart';
import '../component/chart_widget.dart';
import 'add_transaction_screen.dart';

enum FilterOption { all, thisWeek, thisMonth, thisYear }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> _allTx = [];
  List<TransactionModel> _filteredTx = [];
  FilterOption _selectedFilter = FilterOption.all;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await DBHelper().getAllTransactions();
    setState(() {
      _allTx = txs;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    List<TransactionModel> temp;
    switch (_selectedFilter) {
      case FilterOption.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        temp = _allTx.where((tx) =>
        tx.date.isAfter(startOfWeek) || tx.date.isAtSameMomentAs(startOfWeek)).toList();
        break;
      case FilterOption.thisMonth:
        temp = _allTx.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
        break;
      case FilterOption.thisYear:
        temp = _allTx.where((tx) => tx.date.year == now.year).toList();
        break;
      case FilterOption.all:
      default:
        temp = List.from(_allTx);
    }
    setState(() {
      _filteredTx = temp;
    });
  }

  void _onFilterChanged(FilterOption? option) {
    if (option == null) return;
    _selectedFilter = option;
    _applyFilter();
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result == true) {
      _loadTransactions();
    }
  }

  double get _totalIncome =>
      _filteredTx.where((tx) => !tx.isExpense).fold(0, (sum, tx) => sum + tx.amount);
  double get _totalExpense =>
      _filteredTx.where((tx) => tx.isExpense).fold(0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Filter:'),
                const SizedBox(width: 16),
                DropdownButton<FilterOption>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: FilterOption.all, child: Text('All')),
                    DropdownMenuItem(value: FilterOption.thisWeek, child: Text('This Week')),
                    DropdownMenuItem(value: FilterOption.thisMonth, child: Text('This Month')),
                    DropdownMenuItem(value: FilterOption.thisYear, child: Text('This Year')),
                  ],
                  onChanged: _onFilterChanged,
                ),
              ],
            ),
          ),
          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Income', _totalIncome, Colors.green),
                _buildSummaryCard('Expense', _totalExpense, Colors.red),
              ],
            ),
          ),
          // Chart & List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ChartWidget(transactions: _filteredTx),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TransactionList(
                      transactions: _filteredTx,
                      onDelete: (id) async {
                        await DBHelper().deleteTransaction(id);
                        _loadTransactions();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

