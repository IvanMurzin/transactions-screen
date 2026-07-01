import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';

abstract interface class ITransactionRepository {
  Future<Result<TransactionsPageEntity>> getTransactions({required int page, int limit});
}
