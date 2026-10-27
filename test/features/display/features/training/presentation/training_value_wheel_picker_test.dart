import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_wheel_picker.dart';

void main() {
  group('WheelScrollStepper', () {
    Duration ms(int v) => Duration(milliseconds: v);

    test('één grote wielklik is één stap', () {
      final stepper = WheelScrollStepper();
      expect(stepper.add(100, ms(0)), 1);
      expect(stepper.add(-100, ms(1000)), -1);
    });

    test('een reeks kleine events (smooth scrolling) is ook één stap', () {
      final stepper = WheelScrollStepper();
      final steps = [for (var i = 0; i < 6; i++) stepper.add(20, ms(i * 15))];
      expect(steps.where((s) => s != 0).length, 1);
    });

    test('snel na elkaar grote wielklikken: elk één stap', () {
      final stepper = WheelScrollStepper();
      final steps = [for (var i = 0; i < 3; i++) stepper.add(100, ms(i * 100))];
      expect(steps, [1, 1, 1]);
    });

    test('snel doordraaien met kleine events geeft meerdere stappen', () {
      final stepper = WheelScrollStepper();
      final steps = [for (var i = 0; i < 5; i++) stepper.add(120, ms(i * 50))];
      expect(steps.fold<int>(0, (a, b) => a + b), greaterThan(3));
    });

    test('van richting veranderen stapt meteen terug', () {
      final stepper = WheelScrollStepper();
      expect(stepper.add(100, ms(0)), 1);
      expect(stepper.add(-30, ms(50)), -1);
    });
  });

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

  testWidgets('waarde typen + Enter geeft de index terug', (tester) async {
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
    // Naast de tekst, niet erop: daar viel het wiel eerder terug op
    // scrollen per pixel (één klik = meerdere items).
    final center =
        tester.getCenter(find.byType(ListWheelScrollView)) +
        const Offset(-65, 0);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(center));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 300)));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '5x'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(results, [4]);
  });
}
