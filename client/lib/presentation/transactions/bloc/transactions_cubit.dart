import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/types/failure.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';
import 'package:transaction_screen/domain/transaction/usecase/get_transactions_usecase.dart';
import 'package:transaction_screen/presentation/transactions/model/transaction_day_group.dart';

part 'transactions_cubit.freezed.dart';
part 'transactions_state.dart';

@injectable
class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._getTransactions) : super(const TransactionsState());

  final GetTransactionsUseCase _getTransactions;

  static const int _pageSize = 50;

  Future<void> load() async {
    emit(state.copyWith(status: TransactionsStatus.loading, failure: null));
    final result = await _getTransactions(page: 1, limit: _pageSize);
    if (isClosed) return;
    switch (result) {
      case Success<TransactionsPageEntity>(value: final page):
        emit(
          state.copyWith(
            status: TransactionsStatus.loaded,
            items: page.items,
            hasMore: page.hasMore,
            nextPage: 2,
            failure: null,
          ),
        );
      case FailureResult<TransactionsPageEntity>(failure: final failure):
        logger.e('TransactionsCubit.load failed: ${failure.code}');
        emit(state.copyWith(status: TransactionsStatus.error, failure: failure));
    }
  }

  Future<void> refresh() async {
    final result = await _getTransactions(page: 1, limit: _pageSize);
    if (isClosed) return;
    switch (result) {
      case Success<TransactionsPageEntity>(value: final page):
        emit(
          state.copyWith(
            status: TransactionsStatus.loaded,
            items: page.items,
            hasMore: page.hasMore,
            nextPage: 2,
            failure: null,
          ),
        );
      case FailureResult<TransactionsPageEntity>(failure: final failure):
        logger.e('TransactionsCubit.refresh failed: ${failure.code}');
        if (state.items.isEmpty) {
          emit(state.copyWith(status: TransactionsStatus.error, failure: failure));
        }
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.status != TransactionsStatus.loaded) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getTransactions(page: state.nextPage, limit: _pageSize);
    if (isClosed) return;
    switch (result) {
      case Success<TransactionsPageEntity>(value: final page):
        emit(
          state.copyWith(
            items: _mergeUnique(state.items, page.items),
            hasMore: page.hasMore,
            nextPage: state.nextPage + 1,
            isLoadingMore: false,
          ),
        );
      case FailureResult<TransactionsPageEntity>(failure: final failure):
        logger.e('TransactionsCubit.loadMore failed: ${failure.code}');
        emit(state.copyWith(isLoadingMore: false));
    }
  }

  static List<TransactionEntity> _mergeUnique(
    List<TransactionEntity> current,
    List<TransactionEntity> next,
  ) {
    final seen = current.map((tx) => tx.id).toSet();
    return [...current, ...next.where((tx) => seen.add(tx.id))];
  }
}
