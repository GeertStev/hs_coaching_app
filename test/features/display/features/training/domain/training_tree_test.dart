import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';

void main() {
  // Boom:
  //  [0] Warmup                      (los, root)
  //  [1] MainSet                     (groep, "Set")
  //      [1,0] Sprint                (los, in MainSet)
  //      [1,1] Techniek              (groep, "Subset" — genest in MainSet)
  //          [1,1,0] Drill           (los, in Techniek)
  //  [2] Cooldown                    (los, root)
  Training buildFixture() {
    return const Training(
      children: [
        TrainingNode.exercise(
          exercise: TrainingExercise(id: 'warmup', title: 'Warmup'),
        ),
        TrainingNode.group(
          group: TrainingGroup(
            id: 'mainSet',
            title: 'MainSet',
            children: [
              TrainingNode.exercise(
                exercise: TrainingExercise(id: 'sprint', title: 'Sprint'),
              ),
              TrainingNode.group(
                group: TrainingGroup(
                  id: 'techniek',
                  title: 'Techniek',
                  children: [
                    TrainingNode.exercise(
                      exercise: TrainingExercise(id: 'drill', title: 'Drill'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TrainingNode.exercise(
          exercise: TrainingExercise(id: 'cooldown', title: 'Cooldown'),
        ),
      ],
    );
  }

  // Twee onafhankelijke root-groepen, elk hoogte 2 (één laag geneste
  // kinderen) — voor cross-parent verplaats-/groepeer-scenario's die
  // buildFixture() niet kan uitdrukken zonder in elkaars subboom te vallen.
  Training buildTwoGroupsFixture() {
    return const Training(
      children: [
        TrainingNode.group(
          group: TrainingGroup(
            id: 'looseGroup',
            title: 'Loose group',
            children: [
              TrainingNode.exercise(
                exercise: TrainingExercise(id: 'loose1', title: 'Loose1'),
              ),
            ],
          ),
        ),
        TrainingNode.group(
          group: TrainingGroup(
            id: 'setB',
            title: 'SetB',
            children: [
              TrainingNode.exercise(
                exercise: TrainingExercise(id: 'inB', title: 'InB'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Twee onafhankelijke root-groepen die elk zelf al een geneste groep
  // bevatten (hoogte 3) — voor de "twee Subsets op hetzelfde niveau, niet
  // in elkaars subboom" canInsert-afwijzingscasus.
  Training buildTwoNestedGroupsFixture() {
    return const Training(
      children: [
        TrainingNode.group(
          group: TrainingGroup(
            id: 'setA',
            children: [
              TrainingNode.group(
                group: TrainingGroup(
                  id: 'subA',
                  children: [
                    TrainingNode.exercise(
                      exercise: TrainingExercise(id: 'exA', title: 'ExA'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TrainingNode.group(
          group: TrainingGroup(
            id: 'setB',
            children: [
              TrainingNode.group(
                group: TrainingGroup(
                  id: 'subB',
                  children: [
                    TrainingNode.exercise(
                      exercise: TrainingExercise(id: 'exB', title: 'ExB'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  group('nodeAt', () {
    test('lengte 1 geeft de root-child terug', () {
      final node = nodeAt(buildFixture(), [0]);
      expect(node, isA<TrainingNodeExercise>());
      expect((node as TrainingNodeExercise).exercise.id, 'warmup');
    });

    test('lengte 2 geeft het groep-kind terug', () {
      final node = nodeAt(buildFixture(), [1, 0]);
      expect(node, isA<TrainingNodeExercise>());
      expect((node as TrainingNodeExercise).exercise.id, 'sprint');
    });

    test('lengte 3 geeft de losse oefening in de geneste groep terug', () {
      final node = nodeAt(buildFixture(), [1, 1, 0]);
      expect(node, isA<TrainingNodeExercise>());
      expect((node as TrainingNodeExercise).exercise.id, 'drill');
    });

    test('leeg pad gooit een TrainingPathError', () {
      expect(
        () => nodeAt(buildFixture(), []),
        throwsA(isA<TrainingPathError>()),
      );
    });

    test('index buiten bereik gooit een TrainingPathError', () {
      expect(
        () => nodeAt(buildFixture(), [99]),
        throwsA(isA<TrainingPathError>()),
      );
    });

    test('dieper indexeren dan een losse oefening toestaat gooit', () {
      expect(
        () => nodeAt(buildFixture(), [0, 0]),
        throwsA(isA<TrainingPathError>()),
      );
    });

    test(
      'dieper indexeren dan een los kind binnen een groep toestaat gooit',
      () {
        expect(
          () => nodeAt(buildFixture(), [1, 0, 0]),
          throwsA(isA<TrainingPathError>()),
        );
      },
    );
  });

  group('replaceAt', () {
    test('vervangt een root-child', () {
      final updated = replaceAt(
        buildFixture(),
        [0],
        const TrainingNode.exercise(
          exercise: TrainingExercise(id: 'warmup', title: 'Hernoemd'),
        ),
      );
      final node = nodeAt(updated, [0]) as TrainingNodeExercise;
      expect(node.exercise.title, 'Hernoemd');
      // De rest van de boom blijft ongewijzigd.
      expect(
        (nodeAt(updated, [2]) as TrainingNodeExercise).exercise.id,
        'cooldown',
      );
    });

    test('vervangt een oefening diep in een geneste groep', () {
      final updated = replaceAt(
        buildFixture(),
        [1, 1, 0],
        const TrainingNode.exercise(
          exercise: TrainingExercise(id: 'drill', title: 'Hernoemde drill'),
        ),
      );
      final node = nodeAt(updated, [1, 1, 0]) as TrainingNodeExercise;
      expect(node.exercise.title, 'Hernoemde drill');
    });
  });

  group('removeAt', () {
    test('verwijdert een root-child', () {
      final updated = removeAt(buildFixture(), [0]);
      expect(updated.children, hasLength(2));
      expect((nodeAt(updated, [0]) as TrainingNodeGroup).group.id, 'mainSet');
    });

    test('verwijdert een groep-kind', () {
      final updated = removeAt(buildFixture(), [1, 0]);
      final group = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
      expect(group.children, hasLength(1));
      expect((group.children.single as TrainingNodeGroup).group.id, 'techniek');
    });

    test('verwijdert een oefening uit een geneste groep, en de geneste groep '
        'zelf meteen mee als ze daardoor leeg wordt (een lege Subset heeft '
        'geen zin)', () {
      final updated = removeAt(buildFixture(), [1, 1, 0]);
      final mainSet = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
      expect(mainSet.children, hasLength(1));
      expect(
        (mainSet.children.single as TrainingNodeExercise).exercise.id,
        'sprint',
      );
    });

    test('cascadeert meerdere niveaus omhoog: een Subset die leeg wordt neemt '
        'ook haar eigen (nu lege) Set mee', () {
      final updated = removeAt(buildTwoNestedGroupsFixture(), [0, 0, 0]);
      // setA had subA als enige kind, subA had exA als enige kind: beide
      // verdwijnen, setB blijft als enige root-item over.
      expect(updated.children, hasLength(1));
      final setB = (nodeAt(updated, [0]) as TrainingNodeGroup).group;
      expect(setB.id, 'setB');
    });
  });

  group('insertAt', () {
    test('voegt toe aan de root-lijst', () {
      final updated = insertAt(
        buildFixture(),
        [],
        1,
        const TrainingNode.exercise(
          exercise: TrainingExercise(id: 'new', title: 'Nieuw'),
        ),
      );
      expect(updated.children, hasLength(4));
      expect((nodeAt(updated, [1]) as TrainingNodeExercise).exercise.id, 'new');
    });

    test('voegt toe aan de children van een groep (Set-niveau)', () {
      final updated = insertAt(
        buildFixture(),
        [1],
        0,
        const TrainingNode.exercise(
          exercise: TrainingExercise(id: 'new', title: 'Nieuw'),
        ),
      );
      final group = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
      expect(group.children, hasLength(3));
      expect((group.children.first as TrainingNodeExercise).exercise.id, 'new');
    });

    test('voegt toe aan de children van een geneste groep (Subset-niveau)', () {
      final updated = insertAt(
        buildFixture(),
        [1, 1],
        1,
        const TrainingNode.exercise(
          exercise: TrainingExercise(id: 'new', title: 'Nieuw'),
        ),
      );
      final nested = (nodeAt(updated, [1, 1]) as TrainingNodeGroup).group;
      expect(nested.children, hasLength(2));
      expect(nested.children.last.id, 'new');
    });
  });

  group('canInsert (volledige matrix uit §4 van het ontwerpdocument)', () {
    const exerciseNode = TrainingNode.exercise(
      exercise: TrainingExercise(id: 'e', title: 'E'),
    );
    const bareGroupNode = TrainingNode.group(
      group: TrainingGroup(
        id: 'bare',
        children: [
          TrainingNode.exercise(
            exercise: TrainingExercise(id: 'e2', title: 'E2'),
          ),
        ],
      ),
    ); // hoogte 2
    const fullSetNode = TrainingNode.group(
      group: TrainingGroup(
        id: 'full',
        children: [
          TrainingNode.group(
            group: TrainingGroup(
              id: 'nested',
              children: [
                TrainingNode.exercise(
                  exercise: TrainingExercise(id: 'e3', title: 'E3'),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // hoogte 3

    test('oefening in root is toegestaan', () {
      expect(canInsert(exerciseNode, [], buildFixture()), isTrue);
    });

    test('oefening in een Set (niveau 1) is toegestaan', () {
      expect(canInsert(exerciseNode, [1], buildFixture()), isTrue);
    });

    test('oefening in een Subset (niveau 2) is toegestaan', () {
      expect(canInsert(exerciseNode, [1, 1], buildFixture()), isTrue);
    });

    test('kale groep op een Set wordt een Subset (toegestaan)', () {
      expect(canInsert(bareGroupNode, [1], buildFixture()), isTrue);
    });

    test('kale groep op een Subset is niet toegestaan', () {
      expect(canInsert(bareGroupNode, [1, 1], buildFixture()), isFalse);
    });

    test(
      'een volle Set (met Subset-kinderen) op een andere Set is niet toegestaan',
      () {
        expect(canInsert(fullSetNode, [1], buildFixture()), isFalse);
      },
    );

    test('een Subset naar de root is toegestaan', () {
      final techniek = nodeAt(buildFixture(), [1, 1]);
      expect(canInsert(techniek, [], buildFixture()), isTrue);
    });

    test('gooit een TrainingPathError op een onzinnig parentPath', () {
      expect(
        () => canInsert(exerciseNode, [99], buildFixture()),
        throwsA(isA<TrainingPathError>()),
      );
    });
  });

  group('moveNode', () {
    test('herordent binnen dezelfde root-lijst (naar achteren)', () {
      final updated = moveNode(buildFixture(), [0], [], 2);
      expect(updated.children.map((c) => c.id).toList(), [
        'mainSet',
        'cooldown',
        'warmup',
      ]);
    });

    test('herordent binnen dezelfde root-lijst (naar voren)', () {
      final updated = moveNode(buildFixture(), [2], [], 0);
      expect(updated.children.map((c) => c.id).toList(), [
        'cooldown',
        'warmup',
        'mainSet',
      ]);
    });

    test('herschikt de children van een groep (zelfde ouder)', () {
      final updated = moveNode(buildFixture(), [1, 1], [1], 0);
      final group = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
      expect(group.children.map((c) => c.id).toList(), ['techniek', 'sprint']);
    });

    test('verplaatst een Subset naar de root (kon niet in v1 — nu alleen '
        'begrensd door canInsert)', () {
      final updated = moveNode(buildFixture(), [1, 1], [], 3);
      // Root blijft 4 items: verwijderen van een genest kind wijzigt de
      // root-lijst zelf niet (MainSet blijft een root-item, alleen met
      // één kind minder) — Techniek wordt daarna als vierde item toegevoegd.
      expect(updated.children, hasLength(4));
      expect((nodeAt(updated, [3]) as TrainingNodeGroup).group.id, 'techniek');
      // MainSet heeft alleen Sprint nog over.
      final mainSet = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
      expect(mainSet.children.map((c) => c.id).toList(), ['sprint']);
    });

    test('past het toParent-pad correct aan na verwijderen uit dezelfde lijst '
        '(cross-parent verplaatsing waarbij de doelindex verschuift)', () {
      // looseGroup staat op root-index 0, setB op root-index 1. Verplaats
      // looseGroup als eerste kind ván setB — na het verwijderen van index
      // 0 schuift setB naar index 0, dus toParent=[1] moet intern
      // gecorrigeerd worden naar [0] om nog naar setB te wijzen.
      final updated = moveNode(buildTwoGroupsFixture(), [0], [1], 0);
      expect(updated.children, hasLength(1));
      final setB = (nodeAt(updated, [0]) as TrainingNodeGroup).group;
      expect(setB.id, 'setB');
      expect(setB.children.map((c) => c.id).toList(), ['looseGroup', 'inB']);
    });

    test('gooit TrainingInvalidMoveException wanneer de bestemming de '
        'max-diepte-3 zou overschrijden (geen zelf-verplaatsing)', () {
      // subA en subB staan allebei op niveau 2, in onafhankelijke takken.
      // subA verplaatsen als kind van subB zou niveau 2 + hoogte 2 = 4 zijn.
      expect(
        () => moveNode(buildTwoNestedGroupsFixture(), [0, 0], [1, 0], 0),
        throwsA(isA<TrainingInvalidMoveException>()),
      );
    });

    test(
      'gooit TrainingInvalidMoveException bij verplaatsen naar de eigen subboom',
      () {
        expect(
          () => moveNode(buildFixture(), [1], [1, 1], 0),
          throwsA(isA<TrainingInvalidMoveException>()),
        );
      },
    );
  });

  group('groupWithTarget', () {
    test(
      'groepeert twee losse root-oefeningen tot een nieuwe groep ("Set")',
      () {
        final updated = groupWithTarget(
          buildFixture(),
          [0],
          [2],
          newId: () => 'newSet',
        );
        expect(updated.children, hasLength(2));
        final grouped = nodeAt(updated, [1]) as TrainingNodeGroup;
        expect(grouped.group.id, 'newSet');
        expect(grouped.group.children.map((c) => c.id).toList(), [
          'cooldown',
          'warmup',
        ]);
      },
    );

    test(
      'groepeert twee losse oefeningen binnen een Set tot een nieuwe geneste '
      'groep ("Subset")',
      () {
        final mainSet =
            (nodeAt(buildFixture(), [1]) as TrainingNodeGroup).group;
        final fixtureWithTwoLoose = replaceAt(
          buildFixture(),
          [1],
          TrainingNode.group(
            group: mainSet.copyWith(
              children: const [
                TrainingNode.exercise(
                  exercise: TrainingExercise(id: 'a', title: 'A'),
                ),
                TrainingNode.exercise(
                  exercise: TrainingExercise(id: 'b', title: 'B'),
                ),
              ],
            ),
          ),
        );

        final updated = groupWithTarget(
          fixtureWithTwoLoose,
          [1, 0],
          [1, 1],
          newId: () => 'newSubset',
        );

        final group = (nodeAt(updated, [1]) as TrainingNodeGroup).group;
        expect(group.children, hasLength(1));
        final nested = (group.children.single as TrainingNodeGroup).group;
        expect(nested.id, 'newSubset');
        expect(nested.children.map((e) => e.id).toList(), ['b', 'a']);
      },
    );

    test(
      'groepeert een kale groep als kind van een andere groep ("kale Set wordt Subset")',
      () {
        final updated = groupWithTarget(
          buildTwoGroupsFixture(),
          [0],
          [1],
          newId: () => 'unused',
        );
        expect(updated.children, hasLength(1));
        final setB = (nodeAt(updated, [0]) as TrainingNodeGroup).group;
        expect(setB.id, 'setB');
        expect(setB.children.map((c) => c.id).toList(), ['inB', 'looseGroup']);
      },
    );

    test(
      'gooit TrainingInvalidMoveException bij groeperen van twee oefeningen '
      'op diepte 3 (kon in v1 alleen als hardgecodeerde "niet ondersteund")',
      () {
        final techniek =
            (nodeAt(buildFixture(), [1, 1]) as TrainingNodeGroup).group;
        final fixtureWithTwoLooseInSubset = replaceAt(
          buildFixture(),
          [1, 1],
          TrainingNode.group(
            group: techniek.copyWith(
              children: const [
                TrainingNode.exercise(
                  exercise: TrainingExercise(id: 'x', title: 'X'),
                ),
                TrainingNode.exercise(
                  exercise: TrainingExercise(id: 'y', title: 'Y'),
                ),
              ],
            ),
          ),
        );
        expect(
          () => groupWithTarget(
            fixtureWithTwoLooseInSubset,
            [1, 1, 0],
            [1, 1, 1],
            newId: () => 'z',
          ),
          throwsA(isA<TrainingInvalidMoveException>()),
        );
      },
    );

    test('groepeert een losse root-oefening met een oefening die al genest zit '
        '(cross-lijst — was in v2 per ongeluk beperkt tot "zelfde lijst", nu '
        'alleen nog begrensd door canInsert)', () {
      // warmup staat op root ([0]), sprint zit al in MainSet ([1, 0]).
      // Resultaat: sprint's plek wordt een nieuwe geneste groep met
      // [sprint, warmup] erin — niveau 1 + hoogte 2 = 3, dus toegestaan.
      final updated = groupWithTarget(
        buildFixture(),
        [0],
        [1, 0],
        newId: () => 'newNested',
      );
      expect(updated.children, hasLength(2));
      final mainSet = (nodeAt(updated, [0]) as TrainingNodeGroup).group;
      expect(mainSet.id, 'mainSet');
      final nested = mainSet.children.first as TrainingNodeGroup;
      expect(nested.group.id, 'newNested');
      expect(nested.group.children.map((c) => c.id).toList(), [
        'sprint',
        'warmup',
      ]);
    });

    test('gooit TrainingInvalidMoveException wanneer de cross-lijst-groepering '
        'de max-diepte-3 zou overschrijden', () {
      // Drill ([1, 1, 0]) zit al op niveau 2 (binnen Techniek, genest in
      // MainSet). Groeperen met een losse root-oefening zou een nieuwe
      // groep van hoogte 2 op niveau 2 opleveren: 2 + 2 = 4, dus afgewezen.
      expect(
        () => groupWithTarget(buildFixture(), [0], [1, 1, 0], newId: () => 'x'),
        throwsA(isA<TrainingInvalidMoveException>()),
      );
    });

    test('gooit wanneer source en target gelijk zijn', () {
      expect(
        () => groupWithTarget(buildFixture(), [0], [0], newId: () => 'x'),
        throwsA(isA<TrainingPathError>()),
      );
    });

    test('gooit TrainingInvalidMoveException wanneer target de voorouder van '
        'source is (groeperen met eigen ouder)', () {
      expect(
        () => groupWithTarget(buildFixture(), [1, 1, 0], [1], newId: () => 'x'),
        throwsA(isA<TrainingInvalidMoveException>()),
      );
    });

    test('gooit TrainingInvalidMoveException wanneer source de voorouder van '
        'target is (groeperen met eigen nakomeling)', () {
      expect(
        () => groupWithTarget(buildFixture(), [1], [1, 1, 0], newId: () => 'x'),
        throwsA(isA<TrainingInvalidMoveException>()),
      );
    });
  });
}
