import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';

void main() {
  testWidgets('ErrorView toont geen ruwe fout en kan opnieuw proberen', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            error: Exception('geheim detail'),
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.textContaining('geheim'), findsNothing);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('ongevangen async-fout verschijnt als melding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const Scaffold(),
      ),
    );
    showUncaughtErrorSnackBar(Exception('x'));
    await tester.pump();
    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });
}
