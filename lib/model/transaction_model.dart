class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;

  TransactionModel({this.id, required this.title, required this.amount, required this.date, required this.isExpense});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] == 1,
    );
  }
}