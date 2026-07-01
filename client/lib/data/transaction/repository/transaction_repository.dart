import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/types/failure.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/data/transaction/data_source/transaction_remote_data_source.dart';
import 'package:transaction_screen/data/transaction/mapper/transaction_mapper.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';
import 'package:transaction_screen/domain/transaction/repository/i_transaction_repository.dart';

@LazySingleton(as: ITransactionRepository)
class TransactionRepository implements ITransactionRepository {
  TransactionRepository(this._dataSource);

  final TransactionRemoteDataSource _dataSource;

  @override
  Future<Result<TransactionsPageEntity>> getTransactions({
    required int page,
    int limit = 50,
  }) async {
    try {
      final dto = await _dataSource.fetchTransactions(page: page, limit: limit);
      final entity = TransactionMapper.toPageEntity(dto);
      logger.i('TransactionRepository.getTransactions page=$page count=${entity.items.length}');
      return Success(entity);
    } on DioException catch (error) {
      logger.e('TransactionRepository.getTransactions network error', error: error);
      return const FailureResult(
        Failure(code: 'network', message: 'No internet connection. Check your network and retry.'),
      );
    } catch (error) {
      logger.e('TransactionRepository.getTransactions failed', error: error);
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load transactions. Please try again.'),
      );
    }
  }
}
