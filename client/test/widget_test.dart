// Baseline smoke test for the template.
// As you add features, replace this with feature-specific tests.
// See test/helpers/test_widget_wrapper.dart for utilities.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp baseline builds without exception', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('ok'))),
      ),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
