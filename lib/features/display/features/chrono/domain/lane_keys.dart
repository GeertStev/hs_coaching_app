import 'package:flutter/services.dart';

/// Toetsen die de ESP32 met de baanknoppen stuurt (als USB-toetsenbord):
/// A = baan 1, B = baan 2, ...
const List<LogicalKeyboardKey> laneKeys = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyB,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
];

/// Baannummer (vanaf 1) voor [key], of null als het geen baantoets is.
int? laneForKey(LogicalKeyboardKey key) {
  final index = laneKeys.indexOf(key);
  return index < 0 ? null : index + 1;
}
