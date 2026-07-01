part of 'transactions_cubit.dart';

enum TransactionsStatus { initial, loading, loaded, error }

@freezed
abstract class TransactionsState with _$TransactionsState {
  const TransactionsState._();

  const factory TransactionsState({
    @Default(TransactionsStatus.initial) TransactionsStatus status,
    @Default(<TransactionEntity>[]) List<TransactionEntity> items,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(1) int nextPage,
    Failure? failure,
  }) = _TransactionsState;

  bool get isEmpty => status == TransactionsStatus.loaded && items.isEmpty;

  List<TransactionDayGroup> get groups => groupTransactionsByDay(items);
}
