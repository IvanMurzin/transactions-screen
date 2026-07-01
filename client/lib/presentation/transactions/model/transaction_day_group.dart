import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';

class TransactionDayGroup {
  const TransactionDayGroup({required this.day, required this.items});

  final DateTime day;
  final List<TransactionEntity> items;
}

List<TransactionDayGroup> groupTransactionsByDay(List<TransactionEntity> transactions) {
  final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

  final groups = <DateTime, List<TransactionEntity>>{};
  for (final tx in sorted) {
    final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
    (groups[day] ??= <TransactionEntity>[]).add(tx);
  }

  final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final day in days) TransactionDayGroup(day: day, items: groups[day]!)];
}
