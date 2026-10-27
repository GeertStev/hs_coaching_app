import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_value_input.dart';

void main() {
  group('parseIntInput', () {
    test('aanvaardt getallen met teken en eenheid', () {
      expect(parseIntInput('45'), 45);
      expect(parseIntInput(' 400m '), 400);
      expect(parseIntInput('80%'), 80);
      expect(parseIntInput('12x'), 12);
      expect(parseIntInput('+10s'), 10);
      expect(parseIntInput('-5'), -5);
    });

    test('weigert andere tekst', () {
      expect(parseIntInput(''), isNull);
      expect(parseIntInput('-'), isNull);
      expect(parseIntInput('abc'), isNull);
      expect(parseIntInput('1:30'), isNull);
    });
  });

  group('parseSecondsInput', () {
    test('los getal = seconden, m:ss = minuten', () {
      expect(parseSecondsInput('90'), 90);
      expect(parseSecondsInput('1:30'), 90);
      expect(parseSecondsInput('01:05'), 65);
      expect(parseSecondsInput('15:00'), 900);
    });

    test('weigert ongeldige tijden', () {
      expect(parseSecondsInput('1:75'), isNull);
      expect(parseSecondsInput('-5'), isNull);
      expect(parseSecondsInput('x'), isNull);
    });
  });

  group('numericInputParser', () {
    test('rondt af naar de dichtste stap en klemt', () {
      final parse = numericInputParser(min: 0, max: 2000, step: 25);
      expect(parse('400'), 16);
      expect(parse('410'), 16);
      expect(parse('415'), 17);
      expect(parse('5000'), 80);
      expect(parse('nope'), isNull);
    });

    test('optionele velden schuiven één op en aanvaarden leeg', () {
      final parse = numericInputParser(
        min: 1,
        max: 50,
        step: 1,
        nullable: true,
      );
      expect(parse(''), 0);
      expect(parse('–'), 0);
      expect(parse('1'), 1);
      expect(parse('12x'), 12);
    });

    test('werkt met negatieve bereiken (delta)', () {
      final parse = numericInputParser(min: -60, max: 60, step: 5);
      expect(parse('-60'), 0);
      expect(parse('0'), 12);
      expect(parse('+10'), 14);
    });

    test('gebruikt de meegegeven waarde-parser', () {
      final parse = numericInputParser(
        min: 0,
        max: 900,
        step: 5,
        parseValue: parseSecondsInput,
      );
      expect(parse('1:30'), 18);
    });
  });

  group('listInputParser', () {
    test('vergelijkt hoofdletterongevoelig', () {
      final parse = listInputParser(['–', 'AB', 'A', 'B', 'D']);
      expect(parse('ab'), 1);
      expect(parse(' d '), 4);
      expect(parse(''), 0);
      expect(parse('x'), isNull);
    });

    test('leeg is ongeldig zonder "–"-item', () {
      expect(listInputParser(['A', 'B'])(''), isNull);
    });
  });
}
