import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(int) onDelete;

  const TransactionList({Key? key, required this.transactions, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? const Center(child: Text('No transactions added yet!'))
        : ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final tx = transactions[i];
        return Slidable(
          key: ValueKey(tx.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) => onDelete(tx.id!),
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FittedBox(child: Text('\$${tx.amount.toStringAsFixed(2)}')),
                ),
              ),
              title: Text(
                tx.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateFormat.yMMMd().format(tx.date)),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
                onPressed: () => onDelete(tx.id!),
              ),
            ),
          ),
        );
      },
    );
  }
}