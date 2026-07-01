import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

enum TransactionStatus { pending, settled, declined, reversed, unknown }

enum TransactionType { cardPayment, inboundCrypto, outboundCrypto, unknown }

@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const TransactionEntity._();

  const factory TransactionEntity({
    required int id,
    required String merchantName,
    required double amount,
    required String currency,
    required TransactionStatus status,
    required TransactionType type,
    required DateTime date,
  }) = _TransactionEntity;

  bool get isCredit => amount >= 0;
}
