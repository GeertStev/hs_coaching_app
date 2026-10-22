import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

void main() {
  group('canonicalTag', () {
    test('hergebruikt de bestaande spelling', () {
      expect(canonicalTag(' defense ', ['Defense', 'Attack']), 'Defense');
    });
    test('nieuwe tag wordt getrimd', () {
      expect(canonicalTag('  Apnea ', ['Defense']), 'Apnea');
    });
  });

  group('renameTagIn', () {
    test('hernoemt hoofdletter-ongevoelig en behoudt de volgorde', () {
      expect(renameTagIn(['a', 'Defence', 'b'], 'defence', 'Defense'), [
        'a',
        'Defense',
        'b',
      ]);
    });
    test('voegt samen als de nieuwe naam al bestaat', () {
      expect(renameTagIn(['Defence', 'Defense'], 'Defence', 'Defense'), [
        'Defense',
      ]);
    });
    test('lege nieuwe naam verwijdert de tag', () {
      expect(removeTagFrom(['a', 'B'], 'b'), ['a']);
    });
  });

  test('countTags telt varianten samen en sorteert alfabetisch', () {
    expect(
      countTags([
        ['Defense', 'warm-up'],
        ['defense'],
        ['Apnea', 'Apnea'],
      ]),
      {'Apnea': 1, 'Defense': 2, 'warm-up': 1},
    );
  });

  group('matchesAllTags', () {
    test('lege selectie laat alles door', () {
      expect(matchesAllTags(const [], const []), isTrue);
    });
    test('vereist alle geselecteerde tags', () {
      expect(matchesAllTags(['A', 'B'], {'a', 'b'}), isTrue);
      expect(matchesAllTags(['A'], {'a', 'b'}), isFalse);
    });
  });

  test('tagSuggestions geeft bij een lege query alle ongebruikte tags', () {
    expect(
      tagSuggestions(allTags: ['A', 'B', 'C'], current: ['b'], query: ''),
      ['A', 'C'],
    );
    expect(
      tagSuggestions(allTags: ['Apnea', 'Attack'], current: [], query: 'tt'),
      ['Attack'],
    );
  });
}
