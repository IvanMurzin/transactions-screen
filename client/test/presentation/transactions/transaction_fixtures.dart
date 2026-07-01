import 'package:transaction_screen/core/types/failure.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';
import 'package:transaction_screen/domain/transaction/repository/i_transaction_repository.dart';

TransactionEntity buildTransaction({
  int id = 1,
  String merchantName = 'IKEA',
  double amount = -29.06,
  String currency = 'USDT',
  TransactionStatus status = TransactionStatus.settled,
  TransactionType type = TransactionType.cardPayment,
  DateTime? date,
}) {
  return TransactionEntity(
    id: id,
    merchantName: merchantName,
    amount: amount,
    currency: currency,
    status: status,
    type: type,
    date: date ?? DateTime(2026, 6, 21, 14, 6),
  );
}

TransactionsPageEntity buildPage({
  required List<TransactionEntity> items,
  int totalCount = 240,
  bool hasMore = true,
}) {
  return TransactionsPageEntity(items: items, totalCount: totalCount, hasMore: hasMore);
}

Result<TransactionsPageEntity> okPage({
  required List<TransactionEntity> items,
  int totalCount = 240,
  bool hasMore = true,
}) {
  return Success(buildPage(items: items, totalCount: totalCount, hasMore: hasMore));
}

class FakeTransactionRepository implements ITransactionRepository {
  FakeTransactionRepository(this.handler);

  final Future<Result<TransactionsPageEntity>> Function(int page, int limit) handler;

  final List<int> requestedPages = [];

  @override
  Future<Result<TransactionsPageEntity>> getTransactions({required int page, int limit = 50}) {
    requestedPages.add(page);
    return handler(page, limit);
  }
}

FakeTransactionRepository failingRepository([String code = 'network']) {
  return FakeTransactionRepository(
    (_, _) async => FailureResult(Failure(code: code, message: 'boom')),
  );
}
