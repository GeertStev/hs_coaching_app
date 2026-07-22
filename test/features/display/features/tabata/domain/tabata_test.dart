import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_group.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';

void main() {
  int s(int seconds) => seconds * 1000;

  // Eén oefening: werk 20s, rust 10s, 4 rondes; voorbereiding 10s.
  // Tijdlijn: 0-10 prepare | 10-30 werk R1 | 30-40 rust R1 | 40-60 werk R2 |
  // 60-70 rust R2 | 70-90 werk R3 | 90-100 rust R3 | 100-120 werk R4 | klaar.
  const tabata = Tabata(
    prepareSeconds: 10,
    items: [
      TabataItem.exercise(
        TabataExercise(id: 'e1', workSeconds: 20, restSeconds: 10, rounds: 4),
      ),
    ],
  );

  group('Tabata.totalDurationMillis', () {
    test(
      'telt voorbereiding, werk en tussenliggende rust (geen eindrust)',
      () {
        expect(tabata.totalDurationMillis, s(10 + 4 * 20 + 3 * 10));
      },
    );
  });

  group('Tabata.progressAt — één oefening', () {
    test('start in voorbereiding', () {
      final p = tabata.progressAt(0);
      expect(p.phase, TabataPhase.prepare);
      expect(p.itemIndex, 1);
      expect(p.totalItems, 1);
      expect(p.round, 1);
      expect(p.phaseRemaining, const Duration(seconds: 10));
      expect(p.totalRemaining, const Duration(seconds: 120));
    });

    test('eerste werkfase direct na de voorbereiding', () {
      final p = tabata.progressAt(s(10));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
      expect(p.phaseRemaining, const Duration(seconds: 20));
      expect(p.phaseTotal, const Duration(seconds: 20));
    });

    test('rust na de eerste werkfase', () {
      final p = tabata.progressAt(s(35));
      expect(p.phase, TabataPhase.rest);
      expect(p.round, 1);
      expect(p.phaseRemaining, const Duration(seconds: 5));
    });

    test('tweede ronde begint na de eerste rust', () {
      final p = tabata.progressAt(s(40));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 2);
    });

    test('laatste werkfase is ronde 4', () {
      final p = tabata.progressAt(s(110));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 4);
      expect(p.phaseRemaining, const Duration(seconds: 10));
      expect(p.totalRemaining, const Duration(seconds: 10));
    });

    test('klaar na de laatste werkfase, zonder eindrust', () {
      final p = tabata.progressAt(s(120));
      expect(p.phase, TabataPhase.finished);
      expect(p.round, 4);
      expect(p.totalRemaining, Duration.zero);
    });

    test('elapsed voorbij het einde blijft klaar en klemt elapsed', () {
      final p = tabata.progressAt(s(500));
      expect(p.phase, TabataPhase.finished);
      expect(p.elapsed, const Duration(seconds: 120));
    });

    test('negatieve elapsed wordt op nul geklemd', () {
      final p = tabata.progressAt(-1000);
      expect(p.phase, TabataPhase.prepare);
      expect(p.phaseRemaining, const Duration(seconds: 10));
    });

    test('zonder voorbereiding start meteen de eerste werkfase', () {
      const noPrepare = Tabata(
        prepareSeconds: 0,
        items: [
          TabataItem.exercise(
            TabataExercise(
              id: 'e1',
              workSeconds: 20,
              restSeconds: 10,
              rounds: 2,
            ),
          ),
        ],
      );
      final p = noPrepare.progressAt(0);
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
    });

    test('ongeldige config (0 rondes) is meteen klaar', () {
      const invalid = Tabata(
        items: [TabataItem.exercise(TabataExercise(id: 'e1', rounds: 0))],
      );
      expect(invalid.progressAt(0).phase, TabataPhase.finished);
    });

    test('zonder kaarten is de sessie meteen klaar', () {
      const empty = Tabata(items: []);
      expect(empty.progressAt(0).phase, TabataPhase.finished);
    });
  });

  group('stap per ronde (stepSeconds)', () {
    // Werk 20s met -5s per ronde, 4 rondes → werkrondes 20, 15, 10, 5.
    // Tijdlijn (geen voorbereiding): 0-20 W1 | 20-30 rust | 30-45 W2 |
    // 45-55 rust | 55-65 W3 | 65-75 rust | 75-80 W4 | klaar (80).
    const beeptest = Tabata(
      prepareSeconds: 0,
      items: [
        TabataItem.exercise(
          TabataExercise(
            id: 'e1',
            workSeconds: 20,
            restSeconds: 10,
            rounds: 4,
            stepSeconds: -5,
          ),
        ),
      ],
    );

    test('totale duur telt de korter wordende werkrondes', () {
      expect(beeptest.totalDurationMillis, s(20 + 15 + 10 + 5 + 3 * 10));
    });

    test('ronde 2 duurt 15 seconden', () {
      final p = beeptest.progressAt(s(30));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 2);
      expect(p.phaseTotal, const Duration(seconds: 15));
      expect(p.phaseRemaining, const Duration(seconds: 15));
    });

    test('laatste ronde duurt 5 seconden en daarna klaar', () {
      final p = beeptest.progressAt(s(75));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 4);
      expect(p.phaseTotal, const Duration(seconds: 5));
      expect(beeptest.progressAt(s(80)).phase, TabataPhase.finished);
    });

    test('positieve stap laat de werktijd oplopen', () {
      const growing = TabataExercise(
        id: 'e1',
        workSeconds: 10,
        rounds: 3,
        stepSeconds: 3,
      );
      expect(growing.workSecondsForRound(1), 10);
      expect(growing.workSecondsForRound(2), 13);
      expect(growing.workSecondsForRound(3), 16);
    });

    test('werkduur klemt op minimaal 1 seconde', () {
      const extreme = TabataExercise(
        id: 'e1',
        workSeconds: 10,
        restSeconds: 0,
        rounds: 4,
        stepSeconds: -6,
      );
      expect(extreme.workSecondsForRound(1), 10);
      expect(extreme.workSecondsForRound(2), 4);
      expect(extreme.workSecondsForRound(3), 1);
      expect(extreme.workSecondsForRound(4), 1);
    });
  });

  group('meerdere top-level kaarten', () {
    // Kaart 1 "Onderwaters": 2 × 10s werk, 5s rust, daarna 30s rust-na.
    // Kaart 2 "Half onder half boven": 2 × 20s werk, 10s rust.
    // Tijdlijn: 0-10 prepare | 10-20 W1.1 | 20-25 rust | 25-35 W1.2 |
    // 35-65 rust-na | 65-85 W2.1 | 85-95 rust | 95-115 W2.2 | klaar (115).
    const multi = Tabata(
      prepareSeconds: 10,
      items: [
        TabataItem.exercise(
          TabataExercise(
            id: 'e1',
            title: 'Onderwaters',
            workSeconds: 10,
            restSeconds: 5,
            rounds: 2,
            restAfter: 30,
          ),
        ),
        TabataItem.exercise(
          TabataExercise(
            id: 'e2',
            title: 'Half onder half boven',
            workSeconds: 20,
            restSeconds: 10,
            rounds: 2,
          ),
        ),
      ],
    );

    test('totale duur: rust-na van de laatste kaart telt niet mee', () {
      expect(
        multi.totalDurationMillis,
        s(10 + (10 + 5 + 10) + 30 + (20 + 10 + 20)),
      );
    });

    test('kaart 1 heeft eigen titel en rondetelling', () {
      final p = multi.progressAt(s(12));
      expect(p.phase, TabataPhase.work);
      expect(p.itemIndex, 1);
      expect(p.totalItems, 2);
      expect(p.itemTitle, 'Onderwaters');
      expect(p.round, 1);
      expect(p.totalRounds, 2);
      expect(p.groupRepeat, isNull);
    });

    test('na de laatste ronde van kaart 1 volgt rust-na, geen gewone rust', () {
      final p = multi.progressAt(s(35));
      expect(p.phase, TabataPhase.setRest);
      expect(p.phaseTotal, const Duration(seconds: 30));
      expect(p.phaseRemaining, const Duration(seconds: 30));
    });

    test('rust-na hoort al bij de volgende kaart', () {
      final p = multi.progressAt(s(40));
      expect(p.phase, TabataPhase.setRest);
      expect(p.itemIndex, 2);
      expect(p.itemTitle, 'Half onder half boven');
      expect(p.round, 1);
    });

    test('kaart 2 begint met een eigen rondetelling', () {
      final p = multi.progressAt(s(65));
      expect(p.phase, TabataPhase.work);
      expect(p.itemIndex, 2);
      expect(p.round, 1);
      expect(p.totalRounds, 2);
      expect(p.phaseTotal, const Duration(seconds: 20));
    });

    test('klaar na de laatste werkronde van de laatste kaart', () {
      final p = multi.progressAt(s(115));
      expect(p.phase, TabataPhase.finished);
      expect(p.itemIndex, 2);
      expect(p.totalRemaining, Duration.zero);
    });
  });

  group('groep met herhalingen', () {
    // Groep van 2 oefeningen, 2 herhalingen, 15s rust tussen de herhalingen:
    //  - Ex A: 1 × 10s werk, 5s rust-na (tussen A en B)
    //  - Ex B: 1 × 8s werk, geen rust-na
    // Tijdlijn (geen voorbereiding):
    //  0-10  W A (rep 1)
    //  10-15 rust-na A→B (rep 1)
    //  15-23 W B (rep 1)
    //  23-38 rust tussen herhalingen
    //  38-48 W A (rep 2)
    //  48-53 rust-na A→B (rep 2)
    //  53-61 W B (rep 2) → klaar (61)
    const grouped = Tabata(
      prepareSeconds: 0,
      items: [
        TabataItem.group(
          TabataGroup(
            id: 'g1',
            rounds: 2,
            restBetweenRepeats: 15,
            children: [
              TabataExercise(
                id: 'a',
                title: 'A',
                workSeconds: 10,
                rounds: 1,
                restAfter: 5,
              ),
              TabataExercise(id: 'b', title: 'B', workSeconds: 8, rounds: 1),
            ],
          ),
        ),
      ],
    );

    test('totale duur telt beide herhalingen en alle rust mee', () {
      expect(grouped.totalDurationMillis, s(2 * (10 + 5 + 8) + 15));
    });

    test('eerste herhaling: oefening A', () {
      final p = grouped.progressAt(s(5));
      expect(p.phase, TabataPhase.work);
      expect(p.itemTitle, 'A');
      expect(p.groupRepeat, 1);
      expect(p.totalGroupRepeats, 2);
    });

    test('rust tussen A en B binnen dezelfde herhaling', () {
      final p = grouped.progressAt(s(12));
      expect(p.phase, TabataPhase.setRest);
      expect(p.itemTitle, 'B');
      expect(p.groupRepeat, 1);
    });

    test('rust tussen de herhalingen van de groep', () {
      final p = grouped.progressAt(s(25));
      expect(p.phase, TabataPhase.rest);
      expect(p.phaseTotal, const Duration(seconds: 15));
      // Beschrijft de aankomende herhaling, net als de rust-na tussen kaarten.
      expect(p.itemTitle, 'A');
      expect(p.groupRepeat, 2);
    });

    test('tweede herhaling: oefening B, daarna klaar', () {
      final p = grouped.progressAt(s(55));
      expect(p.phase, TabataPhase.work);
      expect(p.itemTitle, 'B');
      expect(p.groupRepeat, 2);
      expect(grouped.progressAt(s(61)).phase, TabataPhase.finished);
    });
  });

  group('TabataProgress.phaseRemainingFraction', () {
    test('halverwege een werkfase is de fractie 0.5', () {
      final p = tabata.progressAt(s(20));
      expect(p.phaseRemainingFraction, closeTo(0.5, 0.001));
    });
  });

  group('Tabata.toJson — Firestore-veiligheid', () {
    // Regressietest: json_serializable zet geneste Freezed-objecten alleen om
    // via hun eigen toJson() als `explicitToJson: true` staat op de klasse
    // die ze bevat (TabataItem voor `exercise`/`group`, TabataGroup voor
    // `children`). Zonder die annotatie belandt het ruwe object zelf in de
    // map; Firestore's StandardMessageCodec (en jsonEncode hieronder)
    // crasht daar dan op met "Invalid argument: Instance of '_TabataExercise'".
    // We toetsen enkel `items` (niet de volledige Tabata-json): het
    // `serverWriteTimestamp`-veld schrijft bewust een niet-JSON-encodeerbare
    // Firestore `FieldValue.serverTimestamp()`-sentinel, wat hier irrelevant
    // is.
    test('een losse oefening is volledig JSON-encodeerbaar', () {
      const withExercise = Tabata(
        items: [TabataItem.exercise(TabataExercise(id: 'e1', title: 'A'))],
      );
      expect(() => jsonEncode(withExercise.toJson()['items']), returnsNormally);
    });

    test('een groep (met kinderen) is volledig JSON-encodeerbaar', () {
      const withGroup = Tabata(
        items: [
          TabataItem.group(
            TabataGroup(
              id: 'g1',
              children: [
                TabataExercise(id: 'a', title: 'A'),
                TabataExercise(id: 'b', title: 'B'),
              ],
            ),
          ),
        ],
      );
      expect(() => jsonEncode(withGroup.toJson()['items']), returnsNormally);
    });
  });
}
