import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_wheel_picker.dart';

void main() {
  final items = numericWheelItems(
    min: 1,
    max: 20,
    step: 1,
    format: (v) => '${v}x',
  );

  Future<List<int?>> openPicker(WidgetTester tester) async {
    final results = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await showTrainingWheelPicker(
                context,
                title: 'Repeat count',
                items: items,
                initialIndex: 3,
                parseInput: numericInputParser(min: 1, max: 20, step: 1),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('waarde typen + Enter geeft de index terug', (
    tester,
  ) async {
    final results = await openPicker(tester);
    await tester.enterText(find.byType(TextField), '12');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(results, [11]);
  });

  testWidgets('onbekende tekst schakelt OK uit', (tester) async {
    await openPicker(tester);
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(find.text('Unknown value'), findsOneWidget);
    final ok = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(ok.onPressed, isNull);
  });

  testWidgets('pijltjestoetsen stappen door de items', (tester) async {
    final results = await openPicker(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '5x'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(results, [4]);
  });

  testWidgets('één muiswielklik draait precies één item', (tester) async {
    final results = await openPicker(tester);
    final center = tester.getCenter(find.byType(ListWheelScrollView));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(center));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 100)));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '5x'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(results, [4]);
  });
}
