import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';

void main() {
  int s(int seconds) => seconds * 1000;

  // Eén set: werk 20s, rust 10s, 4 rondes; voorbereiding 10s.
  // Tijdlijn: 0-10 prepare | 10-30 werk R1 | 30-40 rust R1 | 40-60 werk R2 |
  // 60-70 rust R2 | 70-90 werk R3 | 90-100 rust R3 | 100-120 werk R4 | klaar.
  const tabata = Tabata(
    prepareSeconds: 10,
    sets: [TabataSet(workSeconds: 20, restSeconds: 10, rounds: 4)],
  );

  group('Tabata.totalDurationMillis', () {
    test('telt voorbereiding, werk en tussenliggende rust (geen eindrust)',
        () {
      expect(tabata.totalDurationMillis, s(10 + 4 * 20 + 3 * 10));
    });
  });

  group('Tabata.progressAt — één set', () {
    test('start in voorbereiding', () {
      final p = tabata.progressAt(0);
      expect(p.phase, TabataPhase.prepare);
      expect(p.setIndex, 1);
      expect(p.totalSets, 1);
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
        sets: [TabataSet(workSeconds: 20, restSeconds: 10, rounds: 2)],
      );
      final p = noPrepare.progressAt(0);
      expect(p.phase, TabataPhase.work);
      expect(p.round, 1);
    });

    test('ongeldige config (0 rondes) is meteen klaar', () {
      const invalid = Tabata(sets: [TabataSet(rounds: 0)]);
      expect(invalid.progressAt(0).phase, TabataPhase.finished);
    });

    test('zonder sets is de sessie meteen klaar', () {
      const empty = Tabata(sets: []);
      expect(empty.progressAt(0).phase, TabataPhase.finished);
    });
  });

  group('beeptest (workDecrementSeconds)', () {
    // Werk 20s met -5s per ronde, 4 rondes → werkrondes 20, 15, 10, 5.
    // Tijdlijn (geen voorbereiding): 0-20 W1 | 20-30 rust | 30-45 W2 |
    // 45-55 rust | 55-65 W3 | 65-75 rust | 75-80 W4 | klaar (80).
    const beeptest = Tabata(
      prepareSeconds: 0,
      sets: [
        TabataSet(
          workSeconds: 20,
          restSeconds: 10,
          rounds: 4,
          workDecrementSeconds: 5,
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

    test('werkduur klemt op minimaal 1 seconde', () {
      const extreme = TabataSet(
        workSeconds: 10,
        restSeconds: 0,
        rounds: 4,
        workDecrementSeconds: 6,
      );
      expect(extreme.workSecondsForRound(1), 10);
      expect(extreme.workSecondsForRound(2), 4);
      expect(extreme.workSecondsForRound(3), 1);
      expect(extreme.workSecondsForRound(4), 1);
    });
  });

  group('meerdere sets', () {
    // Set 1 "Onderwaters": 2 × 10s werk, 5s rust, daarna 30s setrust.
    // Set 2 "Half onder half boven": 2 × 20s werk, 10s rust.
    // Tijdlijn: 0-10 prepare | 10-20 W1.1 | 20-25 rust | 25-35 W1.2 |
    // 35-65 setrust | 65-85 W2.1 | 85-95 rust | 95-115 W2.2 | klaar (115).
    const multi = Tabata(
      prepareSeconds: 10,
      sets: [
        TabataSet(
          title: 'Onderwaters',
          workSeconds: 10,
          restSeconds: 5,
          rounds: 2,
          setRestSeconds: 30,
        ),
        TabataSet(
          title: 'Half onder half boven',
          workSeconds: 20,
          restSeconds: 10,
          rounds: 2,
        ),
      ],
    );

    test('totale duur: setrust van de laatste set telt niet mee', () {
      expect(multi.totalDurationMillis, s(10 + (10 + 5 + 10) + 30 + (20 + 10 + 20)));
    });

    test('set 1 heeft eigen titel en rondetelling', () {
      final p = multi.progressAt(s(12));
      expect(p.phase, TabataPhase.work);
      expect(p.setIndex, 1);
      expect(p.totalSets, 2);
      expect(p.setTitle, 'Onderwaters');
      expect(p.round, 1);
      expect(p.totalRounds, 2);
    });

    test('na de laatste ronde van set 1 volgt setrust, geen gewone rust', () {
      final p = multi.progressAt(s(35));
      expect(p.phase, TabataPhase.setRest);
      expect(p.phaseTotal, const Duration(seconds: 30));
      expect(p.phaseRemaining, const Duration(seconds: 30));
    });

    test('setrust hoort al bij de volgende set', () {
      final p = multi.progressAt(s(40));
      expect(p.phase, TabataPhase.setRest);
      expect(p.setIndex, 2);
      expect(p.setTitle, 'Half onder half boven');
      expect(p.round, 1);
    });

    test('set 2 begint met een eigen rondetelling', () {
      final p = multi.progressAt(s(65));
      expect(p.phase, TabataPhase.work);
      expect(p.setIndex, 2);
      expect(p.round, 1);
      expect(p.totalRounds, 2);
      expect(p.phaseTotal, const Duration(seconds: 20));
    });

    test('klaar na de laatste werkronde van de laatste set', () {
      final p = multi.progressAt(s(115));
      expect(p.phase, TabataPhase.finished);
      expect(p.setIndex, 2);
      expect(p.totalRemaining, Duration.zero);
    });
  });

  group('TabataProgress.phaseRemainingFraction', () {
    test('halverwege een werkfase is de fractie 0.5', () {
      final p = tabata.progressAt(s(20));
      expect(p.phaseRemainingFraction, closeTo(0.5, 0.001));
    });
  });
}
