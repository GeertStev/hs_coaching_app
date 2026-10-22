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

  group('blokken invoegen', () {
    test('kolommen op een lege tekst: cursor in kolom 1', () {
      final result = insertColumns(const TextEditingValue(text: ''));
      expect(result.text, '{\n\n}\n{\n\n}');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });

    test('midden in een regel komt het blok op eigen regels', () {
      final result = insertColumns(value('ab', 1));
      expect(result.text, 'a\n{\n\n}\n{\n\n}\nb');
      expect(result.selection, const TextSelection.collapsed(offset: 4));
    });

    test('tabel: Header 1 geselecteerd', () {
      final result = insertTable(value('intro\n', 6));
      expect(result.text, startsWith('intro\n| Header 1 |'));
      expect(
        result.text.substring(result.selection.start, result.selection.end),
        'Header 1',
      );
    });
  });
}
