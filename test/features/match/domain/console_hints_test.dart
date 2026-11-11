import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/match/data/practice_match.dart';
import 'package:hs_coaching_app/features/match/domain/console_hints.dart';
import 'package:hs_coaching_app/features/match/presentation/match_texts.dart';
import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:hs_coaching_core/team/team_model.dart';

void main() {
  var now = 1700000000000;
  late MatchSession session;

  void wait(Duration duration) => now += duration.inMilliseconds;

  /// De hints van de overgang over [step], vanaf nu.
  Set<ConsoleHint> hintsOver(Duration step) {
    final before = session.clock;
    wait(step);
    return consoleHints(before, session.clock);
  }

  setUp(() async {
    session = await startPracticeMatch(
      config: practiceQuickConfig,
      nowMillis: () => now,
    );
  });

  tearDown(() => session.dispose());

  test('14.2 einde van de periode geeft één hint', () {
    session.add(const MatchEventData.playStarted());
    wait(const Duration(minutes: 1, seconds: 59));
    expect(hintsOver(const Duration(milliseconds: 500)), isEmpty);
    expect(hintsOver(const Duration(seconds: 1)), {ConsoleHint.periodExpired});
    expect(hintsOver(const Duration(seconds: 1)), isEmpty);
  });

  test('14.3 team time-out: hint op 0:45', () {
    session.add(const MatchEventData.playStarted());
    wait(const Duration(seconds: 10));
    session.add(const MatchEventData.playStopped());
    session.add(
      const MatchEventData.teamTimeOutRequested(team: TeamColor.white),
    );
    wait(const Duration(seconds: 44));
    expect(hintsOver(const Duration(seconds: 2)), {ConsoleHint.timeOutWarning});
    expect(hintsOver(const Duration(seconds: 2)), isEmpty);
    expect(mainClock(session.clock).label, 'Time-out White');
  });

  test('17.3 einde van een straf geeft een hint', () {
    session.add(const MatchEventData.playStarted());
    wait(const Duration(seconds: 5));
    session.add(const MatchEventData.playStopped());
    session.add(
      const MatchEventData.timePenaltyGiven(
        team: TeamColor.black,
        cap: 4,
        minutes: 1,
        infringementCode: '16.3.1',
      ),
    );
    session.add(const MatchEventData.playStarted());
    wait(const Duration(seconds: 59));
    expect(hintsOver(const Duration(seconds: 2)), {ConsoleHint.penaltyEnded});
    // Het spel loopt: de speler mag meteen terug, de straf is uitgezeten.
    expect(session.clock.penalties.single.status, PenaltyStatus.served);
  });

  test(
    '14.2.2 rust: waarschuwing 30 s voor het einde en hint bij het einde',
    () {
      session.add(const MatchEventData.playStarted());
      wait(const Duration(minutes: 2, seconds: 1));
      session.add(const MatchEventData.periodEnded(phase: MatchPhase.p1));
      // De rust van de oefenwedstrijd duurt net 30 s: korter dan de marge.
      expect(mainClock(session.clock).label, 'Half-time');
      wait(const Duration(seconds: 29));
      expect(hintsOver(const Duration(seconds: 2)), {ConsoleHint.breakEnded});
    },
  );

  test('klok: aftellen rondt naar boven af, optellen naar beneden', () {
    expect(
      formatClock(const Duration(minutes: 14, seconds: 59, milliseconds: 1)),
      '15:00',
    );
    expect(formatClock(Duration.zero), '0:00');
    expect(
      formatClock(
        const Duration(seconds: 61, milliseconds: 900),
        countingDown: false,
      ),
      '1:01',
    );
    expect(const MatchConfig().periodLength, const Duration(minutes: 15));
  });
}
