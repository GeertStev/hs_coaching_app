import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/text/domain/text_markup_editing.dart';

TextEditingValue value(String text, int start, [int? end]) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: start, extentOffset: end ?? start),
);

void main() {
  group('toggleInlineMarker', () {
    test('zet codes rond de selectie en houdt het woord geselecteerd', () {
      final result = toggleInlineMarker(value('een woord hier', 4, 9), '**');
      expect(result.text, 'een **woord** hier');
      expect(
        result.selection,
        const TextSelection(baseOffset: 6, extentOffset: 11),
      );
    });

    test('haalt de codes weg als de selectie al opgemaakt is', () {
      final result = toggleInlineMarker(
        value('een **woord** hier', 6, 11),
        '**',
      );
      expect(result.text, 'een woord hier');
      expect(
        result.selection,
        const TextSelection(baseOffset: 4, extentOffset: 9),
      );
    });

    test('zonder selectie: cursor tussen de codes', () {
      final result = toggleInlineMarker(value('ab', 1), '_');
      expect(result.text, 'a__b');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });

    test('zonder geldige selectie: aan het einde', () {
      final result = toggleInlineMarker(
        const TextEditingValue(text: 'ab'),
        '++',
      );
      expect(result.text, 'ab++++');
      expect(result.selection, const TextSelection.collapsed(offset: 4));
    });
  });

  group('toggleHeading', () {
    test('maakt de regel met de cursor een titel', () {
      final result = toggleHeading(value('eerste\ntweede', 9), 1);
      expect(result.text, 'eerste\n# tweede');
      expect(result.selection, const TextSelection.collapsed(offset: 11));
    });

    test('nog eens dezelfde knop haalt de titel weg', () {
      final result = toggleHeading(value('# titel', 4), 1);
      expect(result.text, 'titel');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });

    test('andere titelgrootte vervangt de bestaande', () {
      expect(toggleHeading(value('# titel', 4), 2).text, '## titel');
      expect(toggleHeading(value('## titel', 4), 1).text, '# titel');
    });

    test('werkt op alle geselecteerde regels', () {
      final result = toggleHeading(value('a\nb\nc', 0, 3), 2);
      expect(result.text, '## a\n## b\nc');
    });
  });
}
