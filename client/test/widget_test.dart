// Smoke test: verifies the example home page renders without throwing.
// Replace with proper feature tests as the app grows.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:template_app/l10n/app_localizations.dart';
import 'package:template_app/presentation/example/page/example_home_page.dart';

void main() {
  testWidgets('ExampleHomePage renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExampleHomePage(),
      ),
    );
    expect(find.byType(ExampleHomePage), findsOneWidget);
  });
}
