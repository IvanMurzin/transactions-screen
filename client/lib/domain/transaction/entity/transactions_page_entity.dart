import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';

part 'transactions_page_entity.freezed.dart';

@freezed
abstract class TransactionsPageEntity with _$TransactionsPageEntity {
  const factory TransactionsPageEntity({
    required List<TransactionEntity> items,
    required int totalCount,
    required bool hasMore,
  }) = _TransactionsPageEntity;
}
