import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:transaction_screen/core/local_storage/locale_storage.dart';
import 'package:transaction_screen/core/local_storage/theme_mode_storage.dart';
import 'package:transaction_screen/core/localization/locale_cubit.dart';
import 'package:transaction_screen/core/localization/system_locale_provider.dart';
import 'package:transaction_screen/core_ui/theme/theme_mode_cubit.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
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
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  testWidgets('renders grouped rows once loaded', (tester) async {
    final repo = FakeTransactionRepository(
      (page, limit) async => okPage(
        items: [
          buildTransaction(id: 1, merchantName: 'IKEA', status: TransactionStatus.settled),
          buildTransaction(id: 2, merchantName: 'Spotify', status: TransactionStatus.declined),
        ],
        hasMore: false,
      ),
    );
    final cubit = TransactionsCubit(GetTransactionsUseCase(repo))..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('IKEA'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Settled'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no transactions', (tester) async {
    final repo = FakeTransactionRepository(
      (page, limit) async => okPage(items: const [], hasMore: false),
    );
    final cubit = TransactionsCubit(GetTransactionsUseCase(repo))..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('shows the error state with a retry button', (tester) async {
    final cubit = TransactionsCubit(GetTransactionsUseCase(failingRepository()))..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load transactions"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
