import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_progress.dart';

void main() {
  int s(int seconds) => seconds * 1000;

  // Werk 20s, rust 10s, 4 rondes, 1 set; voorbereiding 10s.
  // Tijdlijn: 0-10 prepare | 10-30 werk R1 | 30-40 rust R1 | 40-60 werk R2 |
  // 60-70 rust R2 | 70-90 werk R3 | 90-100 rust R3 | 100-120 werk R4 | klaar.
  const tabata = Tabata(
    prepareSeconds: 10,
    workSeconds: 20,
    restSeconds: 10,
    rounds: 4,
    sets: 1,
  );

  group('Tabata.totalDurationMillis', () {
    test(
      'telt voorbereiding, werk en tussenliggende rust (geen eindrust)',
      () {
        expect(tabata.totalDurationMillis, s(10 + 4 * 20 + 3 * 10));
      },
    );
  });

  group('Tabata.progressAt — één set', () {
    test('start in voorbereiding', () {
      final p = tabata.progressAt(0);
      expect(p.phase, TabataPhase.prepare);
      expect(p.round, 1);
      expect(p.set, 1);
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

    test('laatste werkfase is ronde 4, geen rust erna', () {
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
      expect(p.set, 1);
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
        workSeconds: 20,
        restSeconds: 10,
        rounds: 2,
        sets: 1,
      );
      final p = noPrepare.progressAt(0);
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
    });

    test('zonder rust tussen rondes gaat werk direct in werk over', () {
      const noRest = Tabata(
        prepareSeconds: 0,
        workSeconds: 10,
        restSeconds: 0,
        rounds: 3,
        sets: 1,
      );
      expect(noRest.totalDurationMillis, s(30));
      final p = noRest.progressAt(s(10));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 2);
    });

    test('0 rondes is meteen klaar', () {
      const invalid = Tabata(rounds: 0);
      expect(invalid.progressAt(0).phase, TabataPhase.finished);
    });

    test('0 sets is meteen klaar', () {
      const invalid = Tabata(sets: 0);
      expect(invalid.progressAt(0).phase, TabataPhase.finished);
    });

    test('workSeconds 0 is meteen klaar', () {
      const invalid = Tabata(workSeconds: 0);
      expect(invalid.progressAt(0).phase, TabataPhase.finished);
    });
  });

  group('stap per ronde (stepSeconds)', () {
    // Werk 20s met -5s per ronde, 4 rondes → werkrondes 20, 15, 10, 5.
    // Tijdlijn (geen voorbereiding): 0-20 W1 | 20-30 rust | 30-45 W2 |
    // 45-55 rust | 55-65 W3 | 65-75 rust | 75-80 W4 | klaar (80).
    const beeptest = Tabata(
      prepareSeconds: 0,
      workSeconds: 20,
      restSeconds: 10,
      rounds: 4,
      stepSeconds: -5,
      sets: 1,
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
      const growing = Tabata(workSeconds: 10, rounds: 3, stepSeconds: 3);
      expect(growing.workSecondsForRound(1), 10);
      expect(growing.workSecondsForRound(2), 13);
      expect(growing.workSecondsForRound(3), 16);
    });

    test('werkduur klemt op minimaal 1 seconde', () {
      const extreme = Tabata(
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

  group('meerdere sets', () {
    // Werk 10s, rust 5s, 2 rondes per set, 2 sets, 15s rust tussen sets.
    // Tijdlijn (geen voorbereiding):
    //  0-10  W (r1,s1)
    //  10-15 rust
    //  15-25 W (r2,s1)
    //  25-40 rust tussen sets
    //  40-50 W (r1,s2)
    //  50-55 rust
    //  55-65 W (r2,s2) → klaar (65)
    const multiSet = Tabata(
      prepareSeconds: 0,
      workSeconds: 10,
      restSeconds: 5,
      rounds: 2,
      sets: 2,
      restBetweenSets: 15,
    );

    test('totale duur: rust tussen sets, geen rust na de laatste set', () {
      expect(multiSet.totalDurationMillis, s(2 * (2 * 10 + 5) + 15));
    });

    test('eerste set, eerste ronde', () {
      final p = multiSet.progressAt(s(5));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
      expect(p.set, 1);
      expect(p.totalSets, 2);
    });

    test('rust tussen sets toont al de volgende set (ronde 1)', () {
      final p = multiSet.progressAt(s(30));
      expect(p.phase, TabataPhase.restBetweenSets);
      expect(p.round, 1);
      expect(p.set, 2);
      expect(p.phaseTotal, const Duration(seconds: 15));
      expect(p.phaseRemaining, const Duration(seconds: 10));
    });

    test('tweede set begint direct na de rust tussen sets', () {
      final p = multiSet.progressAt(s(40));
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
      expect(p.set, 2);
      expect(p.phaseRemaining, const Duration(seconds: 10));
    });

    test('klaar na de laatste ronde van de laatste set', () {
      final p = multiSet.progressAt(s(65));
      expect(p.phase, TabataPhase.finished);
      expect(p.set, 2);
      expect(p.totalRemaining, Duration.zero);
    });

    test('zonder rust tussen sets gaat de laatste ronde direct door', () {
      const noSetRest = Tabata(
        prepareSeconds: 0,
        workSeconds: 10,
        restSeconds: 0,
        rounds: 1,
        sets: 2,
        restBetweenSets: 0,
      );
      expect(noSetRest.totalDurationMillis, s(20));
      final p = noSetRest.progressAt(s(10));
      expect(p.phase, TabataPhase.work);
      expect(p.set, 2);
      expect(p.round, 1);
    });
  });

  group('TabataProgress.phaseRemainingFraction', () {
    test('halverwege een werkfase is de fractie 0.5', () {
      final p = tabata.progressAt(s(20));
      expect(p.phaseRemainingFraction, closeTo(0.5, 0.001));
    });
  });

  group('Tabata.toJson/fromJson — Firestore-veiligheid', () {
    test('rondtrip behoudt alle configuratievelden', () {
      const original = Tabata(
        prepareSeconds: 5,
        workSeconds: 30,
        restSeconds: 15,
        stepSeconds: -2,
        rounds: 6,
        sets: 3,
        restBetweenSets: 20,
      );
      final decoded = Tabata.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, original);
    });
  });
}
