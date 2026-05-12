import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:template_app/core_ui/theme/app_theme.dart';
import 'package:template_app/l10n/app_localizations.dart';

/// Wraps [child] in a minimal MaterialApp for widget tests.
///
/// Provides the project theme (light + dark), Material 3 baseline,
/// and localizations so any widget under test can access them.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(wrapWidget(const MyPage()));
/// ```
Widget wrapWidget(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: themeMode,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

/// Pumps [child] wrapped in [wrapWidget] and settles all animations.
Future<void> pumpWrapped(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(wrapWidget(child, themeMode: themeMode, locale: locale));
  await tester.pumpAndSettle();
}
