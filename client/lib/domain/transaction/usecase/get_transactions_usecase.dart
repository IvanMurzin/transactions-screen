import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';
import 'package:transaction_screen/domain/transaction/repository/i_transaction_repository.dart';

@injectable
class GetTransactionsUseCase {
  GetTransactionsUseCase(this._repository);

  final ITransactionRepository _repository;

  Future<Result<TransactionsPageEntity>> call({required int page, int limit = 50}) {
    return _repository.getTransactions(page: page, limit: limit);
  }
}
