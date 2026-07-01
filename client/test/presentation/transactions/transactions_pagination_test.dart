import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:transaction_screen/core/local_storage/locale_storage.dart';
import 'package:transaction_screen/core/local_storage/theme_mode_storage.dart';
import 'package:transaction_screen/core/localization/locale_cubit.dart';
import 'package:transaction_screen/core/localization/system_locale_provider.dart';
import 'package:transaction_screen/core_ui/theme/theme_mode_cubit.dart';
import 'package:transaction_screen/domain/transaction/usecase/get_transactions_usecase.dart';
import 'package:transaction_screen/presentation/transactions/bloc/transactions_cubit.dart';
import 'package:transaction_screen/presentation/transactions/pages/transactions_page.dart';

import '../../helpers/test_widget_wrapper.dart';
import 'transaction_fixtures.dart';

class _FakeSystemLocaleProvider implements ISystemLocaleProvider {
  @override
  Locale getCurrentLocale() => const Locale('en');
}

void main() {
  const pageSize = 50;
  const totalPages = 3;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  FakeTransactionRepository pagedRepository() {
    return FakeTransactionRepository((page, limit) async {
      final start = (page - 1) * pageSize + 1;
      final items = [
        for (var i = start; i < start + pageSize; i++)
          buildTransaction(
            id: i,
            merchantName: 'Merchant $i',
            date: DateTime(2026, 6, 21, 12).subtract(Duration(minutes: i)),
          ),
      ];
      return okPage(items: items, hasMore: page < totalPages);
    });
  }

  Widget wrap(TransactionsCubit cubit) {
    return wrapWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TransactionsCubit>.value(value: cubit),
          BlocProvider<ThemeModeCubit>(create: (_) => ThemeModeCubit(ThemeModeStorage())),
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit(LocaleStorage(), _FakeSystemLocaleProvider()),
          ),
        ],
        child: const TransactionsPage(),
      ),
    );
  }

  testWidgets('scrolling to the bottom loads more pages until the end', (tester) async {
    final repo = pagedRepository();
    final cubit = TransactionsCubit(GetTransactionsUseCase(repo));
    addTearDown(cubit.close);
    cubit.load();

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, [1]);
    expect(cubit.state.items, hasLength(pageSize));
    expect(cubit.state.hasMore, isTrue);

    final scrollable = find.byType(CustomScrollView);

    await tester.drag(scrollable, const Offset(0, -6000));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, [1, 2]);
    expect(cubit.state.items, hasLength(pageSize * 2));
    expect(cubit.state.nextPage, 3);

    await tester.drag(scrollable, const Offset(0, -12000));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, [1, 2, 3]);
    expect(cubit.state.items, hasLength(pageSize * 3));
    expect(cubit.state.hasMore, isFalse);

    await tester.drag(scrollable, const Offset(0, -12000));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, [1, 2, 3]);
  });

  testWidgets('does not request the same page twice while a load is in flight', (tester) async {
    final repo = pagedRepository();
    final cubit = TransactionsCubit(GetTransactionsUseCase(repo));
    addTearDown(cubit.close);
    cubit.load();

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    final scrollable = find.byType(CustomScrollView);
    await tester.drag(scrollable, const Offset(0, -6000));
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    final page2Requests = repo.requestedPages.where((p) => p == 2).length;
    expect(page2Requests, 1);
  });
}
