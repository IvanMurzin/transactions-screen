import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:transaction_screen/core/local_storage/locale_storage.dart';
import 'package:transaction_screen/core/local_storage/theme_mode_storage.dart';
import 'package:transaction_screen/core/localization/locale_cubit.dart';
import 'package:transaction_screen/core/localization/system_locale_provider.dart';
import 'package:transaction_screen/core_ui/theme/theme_mode_cubit.dart';
import 'package:transaction_screen/presentation/settings/widgets/language_menu_button.dart';
import 'package:transaction_screen/presentation/settings/widgets/theme_mode_menu_button.dart';

import '../../helpers/test_widget_wrapper.dart';

class _FakeSystemLocaleProvider implements ISystemLocaleProvider {
  @override
  Locale getCurrentLocale() => const Locale('en');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpMenus(
    WidgetTester tester, {
    required ThemeModeCubit themeCubit,
    required LocaleCubit localeCubit,
  }) async {
    await tester.pumpWidget(
      wrapWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeModeCubit>.value(value: themeCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: const Scaffold(body: Row(children: [LanguageMenuButton(), ThemeModeMenuButton()])),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('theme menu switches the app theme mode', (tester) async {
    final themeCubit = ThemeModeCubit(ThemeModeStorage());
    final localeCubit = LocaleCubit(LocaleStorage(), _FakeSystemLocaleProvider());
    addTearDown(themeCubit.close);
    addTearDown(localeCubit.close);

    await pumpMenus(tester, themeCubit: themeCubit, localeCubit: localeCubit);

    await tester.tap(find.byIcon(Icons.brightness_auto_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeCubit.state, ThemeMode.dark);
  });

  testWidgets('language menu switches the locale to Russian', (tester) async {
    final themeCubit = ThemeModeCubit(ThemeModeStorage());
    final localeCubit = LocaleCubit(LocaleStorage(), _FakeSystemLocaleProvider());
    addTearDown(themeCubit.close);
    addTearDown(localeCubit.close);

    await pumpMenus(tester, themeCubit: themeCubit, localeCubit: localeCubit);

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(localeCubit.state.localeTag, 'ru');
  });
}
