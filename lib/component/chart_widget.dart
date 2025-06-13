import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../model/transaction_model.dart';

class ChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ChartWidget({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double totalIncome = transactions
        .where((tx) => !tx.isExpense)
        .fold(0, (sum, tx) => sum + tx.amount);
    double totalExpense = transactions
        .where((tx) => tx.isExpense)
        .fold(0, (sum, tx) => sum + tx.amount);
    final chartData = [
      _ChartData('Income', totalIncome),
      _ChartData('Expense', totalExpense),
    ];
    final balance = totalIncome - totalExpense;
    final isPositive = balance >= 0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: SfCircularChart(
            legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            series: <PieSeries<_ChartData, String>>[
              PieSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
        // const SizedBox(height: 16),
        Text(
          'Balance: \$${balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ChartData {
  final String category;
  final double value;
  _ChartData(this.category, this.value);
}