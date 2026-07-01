import 'package:flutter_test/flutter_test.dart';

import 'package:transaction_screen/data/transaction/dto/transaction_dto.dart';
import 'package:transaction_screen/data/transaction/dto/transactions_response_dto.dart';
import 'package:transaction_screen/data/transaction/mapper/transaction_mapper.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';

void main() {
  group('TransactionMapper.toEntity', () {
    test('maps a well-formed dto and parses the amount string', () {
      const dto = TransactionDto(
        id: 90210,
        type: 'CARD_PAYMENT',
        status: 'SETTLED',
        amount: '-91.66',
        currency: 'USDT',
        authorizedAt: '2026-06-21T14:06:28.004Z',
        merchantName: 'IKEA',
      );

      final entity = TransactionMapper.toEntity(dto);

      expect(entity.id, 90210);
      expect(entity.merchantName, 'IKEA');
      expect(entity.amount, -91.66);
      expect(entity.currency, 'USDT');
      expect(entity.status, TransactionStatus.settled);
      expect(entity.type, TransactionType.cardPayment);
      expect(entity.isCredit, isFalse);
    });

    test('maps each backend status to the task emphasis semantics', () {
      TransactionStatus statusOf(String raw) =>
          TransactionMapper.toEntity(TransactionDto(id: 1, status: raw)).status;

      expect(statusOf('AUTHORIZED'), TransactionStatus.pending);
      expect(statusOf('SETTLED'), TransactionStatus.settled);
      expect(statusOf('DECLINED'), TransactionStatus.declined);
      expect(statusOf('REVERSED'), TransactionStatus.reversed);
    });

    test('degrades gracefully on unknown / missing fields', () {
      const dto = TransactionDto(
        id: 7,
        status: 'SOMETHING_NEW',
        type: 'FOO',
        amount: 'not-a-number',
      );

      final entity = TransactionMapper.toEntity(dto);

      expect(entity.status, TransactionStatus.unknown);
      expect(entity.type, TransactionType.unknown);
      expect(entity.amount, 0);
      expect(entity.merchantName, '');
      expect(entity.date, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('TransactionMapper.toPageEntity', () {
    test('derives hasMore from the next cursor', () {
      const withNext = TransactionsResponseDto(count: 240, next: '/karta/transaction/?page=2');
      const withoutNext = TransactionsResponseDto(count: 5, next: null);

      expect(TransactionMapper.toPageEntity(withNext).hasMore, isTrue);
      expect(TransactionMapper.toPageEntity(withoutNext).hasMore, isFalse);
      expect(TransactionMapper.toPageEntity(withNext).totalCount, 240);
    });

    test('parses the real API envelope shape', () {
      final json = {
        'count': 2,
        'next': '/karta/transaction/?page=2&limit=1',
        'previous': null,
        'results': [
          {
            'id': 90211,
            'type': 'OUTBOUND_CRYPTO',
            'status': 'SETTLED',
            'amount': '-3633.08',
            'currency': 'USDT',
            'authorizedAt': '2026-06-21T19:39:36.159Z',
            'merchantName': '0x849d73eb438a907d090402c802d7c5700893a34b',
          },
        ],
      };

      final page = TransactionMapper.toPageEntity(TransactionsResponseDto.fromJson(json));

      expect(page.items, hasLength(1));
      expect(page.items.single.type, TransactionType.outboundCrypto);
      expect(page.hasMore, isTrue);
    });
  });
}
