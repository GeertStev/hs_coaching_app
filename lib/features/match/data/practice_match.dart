import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/in_memory_match_repository.dart';
import 'package:hs_coaching_core/match/match_session.dart';

/// Start een oefenwedstrijd die alleen in het geheugen bestaat: geen
/// Firebase, niets wordt bewaard. Bedoeld om de tafel uit te proberen.
///
/// [nowMillis] is de klok van de wedstrijd; tests geven een nepklok mee.
Future<MatchSession> startPracticeMatch({
  required MatchConfig config,
  required int Function() nowMillis,
  String teamWhite = 'White',
  String teamBlack = 'Black',
}) async {
  const matchId = 'practice';
  const deviceId = 'practice-device';
  final repository = InMemoryMatchRepository();
  var ids = 0;
  final session = MatchSession(
    matchId: matchId,
    repository: repository,
    deviceId: deviceId,
    nowServerMs: nowMillis,
    newEventId: () => 'practice-${++ids}',
  );
  await repository.createMatch(matchId, createdAtMillis: nowMillis());
  await session.takeLease();
  // De sessie hoort van de lease via haar stream; wacht tot die er is.
  for (var i = 0; i < 20 && !session.holdsLease; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  session.add(
    MatchEventData.matchCreated(
      config: config,
      teamWhite: teamWhite,
      teamBlack: teamBlack,
    ),
  );
  return session;
}

/// Korte wedstrijd om de hele flow in een paar minuten te doorlopen.
const practiceQuickConfig = MatchConfig(
  periodLength: Duration(minutes: 2),
  halfTimeBreak: Duration(seconds: 30),
  presetName: 'Practice 2 x 2 min',
);
