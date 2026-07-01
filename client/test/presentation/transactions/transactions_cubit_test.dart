import 'package:flutter_test/flutter_test.dart';

import 'package:transaction_screen/domain/transaction/usecase/get_transactions_usecase.dart';
import 'package:transaction_screen/presentation/transactions/bloc/transactions_cubit.dart';

import 'transaction_fixtures.dart';

void main() {
  TransactionsCubit buildCubit(FakeTransactionRepository repo) {
    return TransactionsCubit(GetTransactionsUseCase(repo));
  }

  group('load', () {
    test('emits loading then loaded with items and nextPage advanced', () async {
      final repo = FakeTransactionRepository(
        (page, limit) async => okPage(items: [buildTransaction(id: 1), buildTransaction(id: 2)]),
      );
      final cubit = buildCubit(repo);
      final expectation = expectLater(
        cubit.stream.map((s) => s.status),
        emitsInOrder([TransactionsStatus.loading, TransactionsStatus.loaded]),
      );

      await cubit.load();
      await expectation;

      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.nextPage, 2);
      expect(repo.requestedPages, [1]);
      await cubit.close();
    });

    test('emits error on failure', () async {
      final cubit = buildCubit(failingRepository());

      await cubit.load();

      expect(cubit.state.status, TransactionsStatus.error);
      expect(cubit.state.failure?.code, 'network');
      expect(cubit.state.items, isEmpty);
      await cubit.close();
    });
  });

  group('loadMore', () {
    test('appends the next page and dedupes by id', () async {
      final repo = FakeTransactionRepository((page, limit) async {
        if (page == 1) {
          return okPage(items: [buildTransaction(id: 1), buildTransaction(id: 2)]);
        }
        return okPage(items: [buildTransaction(id: 2), buildTransaction(id: 3)], hasMore: false);
      });
      final cubit = buildCubit(repo);

      await cubit.load();
      await cubit.loadMore();

      expect(cubit.state.items.map((t) => t.id), [1, 2, 3]);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.nextPage, 3);
      expect(repo.requestedPages, [1, 2]);
      await cubit.close();
    });

    test('is a no-op when there are no more pages', () async {
      final repo = FakeTransactionRepository(
        (page, limit) async => okPage(items: [buildTransaction(id: 1)], hasMore: false),
      );
      final cubit = buildCubit(repo);

      await cubit.load();
      await cubit.loadMore();

      expect(repo.requestedPages, [1]);
      await cubit.close();
    });
  });

  group('refresh', () {
    test('replaces the list and resets paging', () async {
      var call = 0;
      final repo = FakeTransactionRepository((page, limit) async {
        call++;
        return okPage(items: [buildTransaction(id: call)]);
      });
      final cubit = buildCubit(repo);

      await cubit.load();
      await cubit.refresh();

      expect(cubit.state.items.single.id, 2);
      expect(cubit.state.nextPage, 2);
      await cubit.close();
    });

    test('keeps existing items when refresh fails after a successful load', () async {
      var shouldFail = false;
      final repo = FakeTransactionRepository((page, limit) async {
        if (shouldFail) return failingRepository().handler(page, limit);
        return okPage(items: [buildTransaction(id: 1)]);
      });
      final cubit = buildCubit(repo);

      await cubit.load();
      shouldFail = true;
      await cubit.refresh();

      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.status, TransactionsStatus.loaded);
      await cubit.close();
    });
  });

  test('groups transactions by day, newest first', () async {
    final repo = FakeTransactionRepository(
      (page, limit) async => okPage(
        items: [
          buildTransaction(id: 1, date: DateTime(2026, 6, 21, 9)),
          buildTransaction(id: 2, date: DateTime(2026, 6, 21, 18)),
          buildTransaction(id: 3, date: DateTime(2026, 6, 20, 12)),
        ],
        hasMore: false,
      ),
    );
    final cubit = buildCubit(repo);

    await cubit.load();
    final groups = cubit.state.groups;

    expect(groups, hasLength(2));
    expect(groups.first.day, DateTime(2026, 6, 21));
    expect(groups.first.items.map((t) => t.id), [2, 1]);
    expect(groups.last.day, DateTime(2026, 6, 20));
    await cubit.close();
  });
}
