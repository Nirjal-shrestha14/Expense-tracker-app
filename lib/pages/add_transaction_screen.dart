import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../model/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final tx = TransactionModel(
      title: _title,
      amount: _amount,
      date: _selectedDate,
      isExpense: _isExpense,
    );
    await DBHelper().insertTransaction(tx);
    Navigator.of(context).pop(true);
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null) setState(() => _selectedDate = picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onSaved: (val) => _title = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val!.isEmpty ? 'Enter amount' : null,
                onSaved: (val) => _amount = double.parse(val!),
              ),
              Row(
                children: [
                  Expanded(child: Text('Date: ${DateFormat.yMd().format(_selectedDate)}')),
                  TextButton(onPressed: _presentDatePicker, child: const Text('Choose Date')),
                ],
              ),
              SwitchListTile(
                title: const Text('Expense?'),
                value: _isExpense,
                onChanged: (val) => setState(() => _isExpense = val),
              ),
              ElevatedButton(onPressed: _submit, child: const Text('Add')),
            ],
          ),
        ),
      ),
    );
  }
}