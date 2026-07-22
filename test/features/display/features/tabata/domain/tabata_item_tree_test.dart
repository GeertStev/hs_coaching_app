import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_group.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item_tree.dart';

void main() {
  const exerciseA = TabataExercise(id: 'a', title: 'A');
  const exerciseB = TabataExercise(id: 'b', title: 'B');
  const exerciseC = TabataExercise(id: 'c', title: 'C');

  group('findExercise', () {
    test('vindt een top-level oefening', () {
      final items = [TabataItem.exercise(exerciseA)];
      expect(findExercise(items, 'a'), exerciseA);
    });

    test('vindt een genest kind in een groep', () {
      final items = [
        TabataItem.group(
          TabataGroup(id: 'g', children: [exerciseA, exerciseB]),
        ),
      ];
      expect(findExercise(items, 'b'), exerciseB);
    });

    test('null als de id nergens voorkomt', () {
      expect(findExercise([TabataItem.exercise(exerciseA)], 'x'), isNull);
    });
  });

  group('insertExercise', () {
    test('voegt in op de gevraagde positie', () {
      final items = [TabataItem.exercise(exerciseA), TabataItem.exercise(exerciseC)];
      final result = insertExercise(items, 1, exerciseB);
      expect(result.map((i) => i.id), ['a', 'b', 'c']);
    });
  });

  group('replaceExercise', () {
    test('vervangt een top-level oefening', () {
      final items = [TabataItem.exercise(exerciseA)];
      final updated = exerciseA.copyWith(title: 'A2');
      final result = replaceExercise(items, updated);
      expect((result.single as TabataItemExercise).exercise.title, 'A2');
    });

    test('vervangt een genest kind zonder de groep te breken', () {
      final items = [
        TabataItem.group(
          TabataGroup(id: 'g', children: [exerciseA, exerciseB]),
        ),
      ];
      final result = replaceExercise(items, exerciseB.copyWith(title: 'B2'));
      final group = (result.single as TabataItemGroup).group;
      expect(group.children.map((c) => c.title), ['A', 'B2']);
    });
  });

  group('removeItem', () {
    test('verwijdert een top-level oefening', () {
      final items = [TabataItem.exercise(exerciseA), TabataItem.exercise(exerciseB)];
      final result = removeItem(items, 'a');
      expect(result.map((i) => i.id), ['b']);
    });

    test('verwijdert een geheel top-level groep', () {
      final items = [
        TabataItem.group(TabataGroup(id: 'g', children: [exerciseA, exerciseB])),
        TabataItem.exercise(exerciseC),
      ];
      final result = removeItem(items, 'g');
      expect(result.map((i) => i.id), ['c']);
    });

    test('groep met 1 overblijvend kind wordt losse oefening', () {
      final items = [
        TabataItem.group(
          TabataGroup(
            id: 'g',
            restAfter: 42,
            children: [exerciseA, exerciseB],
          ),
        ),
      ];
      final result = removeItem(items, 'a');
      final item = result.single as TabataItemExercise;
      expect(item.exercise.id, 'b');
      // Neemt de rust-ná van de groep over, want de kaart staat nu zelf
      // weer op het topniveau.
      expect(item.exercise.restAfter, 42);
    });

    test('lege groep verdwijnt volledig', () {
      final items = [
        TabataItem.group(TabataGroup(id: 'g', children: [exerciseA])),
        TabataItem.exercise(exerciseB),
      ];
      final result = removeItem(items, 'a');
      expect(result.map((i) => i.id), ['b']);
    });
  });

  group('moveItem', () {
    test('herordent top-level kaarten', () {
      final items = [
        TabataItem.exercise(exerciseA),
        TabataItem.exercise(exerciseB),
        TabataItem.exercise(exerciseC),
      ];
      final result = moveItem(items, 'a', 2);
      expect(result.map((i) => i.id), ['b', 'c', 'a']);
    });

    test(
      'haalt een genest kind uit zijn groep en zet het top-level '
      '(groep met 1 overblijvend kind wordt losse oefening, zie removeItem)',
      () {
        final items = [
          TabataItem.group(
            TabataGroup(id: 'g', children: [exerciseA, exerciseB]),
          ),
          TabataItem.exercise(exerciseC),
        ];
        final result = moveItem(items, 'b', 0);
        expect(result.map((i) => i.id), ['b', 'a', 'c']);
      },
    );

    test('verplaatst een genest kind naar een groep die blijft bestaan', () {
      final items = [
        TabataItem.group(
          TabataGroup(id: 'g', children: [exerciseA, exerciseB, exerciseC]),
        ),
      ];
      final result = moveItem(items, 'b', 0);
      expect(result.map((i) => i.id), ['b', 'g']);
      final group = (result[1] as TabataItemGroup).group;
      expect(group.children.map((c) => c.id), ['a', 'c']);
    });

    test('onbekende id laat de lijst ongewijzigd', () {
      final items = [TabataItem.exercise(exerciseA)];
      expect(moveItem(items, 'x', 0), same(items));
    });
  });

  group('groupWithTarget', () {
    test('vormt een nieuwe groep van twee losse oefeningen', () {
      final items = [TabataItem.exercise(exerciseA), TabataItem.exercise(exerciseB)];
      final result = groupWithTarget(items, 'a', 'b');
      expect(result, hasLength(1));
      final group = (result.single as TabataItemGroup).group;
      expect(group.children.map((c) => c.id), ['b', 'a']);
    });

    test('voegt toe aan een bestaande groep', () {
      final items = [
        TabataItem.group(
          TabataGroup(id: 'g', children: [exerciseA, exerciseB]),
        ),
        TabataItem.exercise(exerciseC),
      ];
      final result = groupWithTarget(items, 'c', 'g');
      final group = (result.single as TabataItemGroup).group;
      expect(group.children.map((c) => c.id), ['a', 'b', 'c']);
    });

    test('een gesleepte groep kan niet groeperen (geen geneste groepen)', () {
      final items = [
        TabataItem.group(TabataGroup(id: 'g1', children: [exerciseA])),
        TabataItem.exercise(exerciseB),
      ];
      final result = groupWithTarget(items, 'g1', 'b');
      expect(result, same(items));
    });

    test('zichzelf als doel is een no-op', () {
      final items = [TabataItem.exercise(exerciseA)];
      expect(groupWithTarget(items, 'a', 'a'), same(items));
    });
  });
}
