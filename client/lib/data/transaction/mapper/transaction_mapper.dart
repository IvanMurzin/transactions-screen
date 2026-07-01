import 'package:transaction_screen/data/transaction/dto/transaction_dto.dart';
import 'package:transaction_screen/data/transaction/dto/transactions_response_dto.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
import 'package:transaction_screen/domain/transaction/entity/transactions_page_entity.dart';

abstract final class TransactionMapper {
  static TransactionsPageEntity toPageEntity(TransactionsResponseDto dto) {
    return TransactionsPageEntity(
      items: dto.results.map(toEntity).toList(growable: false),
      totalCount: dto.count,
      hasMore: dto.next != null && dto.next!.isNotEmpty,
    );
  }

  static TransactionEntity toEntity(TransactionDto dto) {
    return TransactionEntity(
      id: dto.id,
      merchantName: (dto.merchantName ?? '').trim(),
      amount: double.tryParse(dto.amount ?? '') ?? 0,
      currency: (dto.currency ?? '').trim(),
      status: _status(dto.status),
      type: _type(dto.type),
      date:
          DateTime.tryParse(dto.authorizedAt ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static TransactionStatus _status(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'AUTHORIZED':
        return TransactionStatus.pending;
      case 'SETTLED':
        return TransactionStatus.settled;
      case 'DECLINED':
        return TransactionStatus.declined;
      case 'REVERSED':
        return TransactionStatus.reversed;
      default:
        return TransactionStatus.unknown;
    }
  }

  static TransactionType _type(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'CARD_PAYMENT':
        return TransactionType.cardPayment;
      case 'INBOUND_CRYPTO':
        return TransactionType.inboundCrypto;
      case 'OUTBOUND_CRYPTO':
        return TransactionType.outboundCrypto;
      default:
        return TransactionType.unknown;
    }
  }
}
