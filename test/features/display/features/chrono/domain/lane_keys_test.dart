import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/lane_keys.dart';

void main() {
  test('A tot H zijn baan 1 tot 8', () {
    expect(laneForKey(LogicalKeyboardKey.keyA), 1);
    expect(laneForKey(LogicalKeyboardKey.keyC), 3);
    expect(laneForKey(LogicalKeyboardKey.keyH), 8);
  });

  test('andere toetsen zijn geen baan', () {
    expect(laneForKey(LogicalKeyboardKey.keyI), isNull);
    expect(laneForKey(LogicalKeyboardKey.space), isNull);
    expect(laneForKey(LogicalKeyboardKey.digit1), isNull);
  });
}
