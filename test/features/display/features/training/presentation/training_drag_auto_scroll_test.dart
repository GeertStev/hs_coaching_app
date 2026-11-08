import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_drag_drop.dart';

void main() {
  late ScrollController controller;

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrainingDragAutoScroll(
            builder: (context, c) {
              controller = c;
              return ListView(
                controller: c,
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(
                      height: 80,
                      child: Draggable<TrainingDragPayload>(
                        data: TrainingDragPayload([i]),
                        feedback: const SizedBox(width: 40, height: 40),
                        child: Text('item $i'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('kaart tegen de onderrand slepen scrolt naar beneden', (
    tester,
  ) async {
    await pumpList(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('item 2')),
    );
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    final bottom = tester.getSize(find.byType(Scaffold)).height;
    await gesture.moveTo(Offset(100, bottom - 10));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.offset, greaterThan(200));

    // Terug naar het midden: scrollen stopt.
    await gesture.moveTo(Offset(100, bottom / 2));
    await tester.pump(const Duration(milliseconds: 16));
    final stopped = controller.offset;
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller.offset, stopped);

    // Tegen de bovenrand: weer omhoog.
    await gesture.moveTo(const Offset(100, 5));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.offset, lessThan(stopped));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('zonder slepen scrolt de lijst niet vanzelf', (tester) async {
    await pumpList(tester);
    final bottom = tester.getSize(find.byType(Scaffold)).height;
    final gesture = await tester.createGesture();
    await gesture.addPointer(location: Offset(100, bottom - 10));
    await gesture.moveTo(Offset(100, bottom - 5));
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller.offset, 0);
    await gesture.removePointer();
  });
}
