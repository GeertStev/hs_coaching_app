import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/chrono/chrono_repository.dart' as core;

class DisplayChronoRepository extends core.DisplayChronoRepository {
  DisplayChronoRepository({
    required super.firestore,
    required super.clubId,
    required super.displayId,
  });

  /// [nowServerMillis] moet al gecorrigeerd zijn voor het klokverschil van
  /// dit apparaat (zie `serverNowMillis`/`serverTimeOffsetProvider`), zodat
  /// `authoritativeStartTimeMillis` voor elke lezer in dezelfde RTDB-server-
  /// klok is uitgedrukt, ongeacht wiens apparaatklok afwijkt — ook al staat
  /// het document zelf in Firestore.
  Future<void> start(
    Chrono currentChrono, {
    required int nowServerMillis,
    int countdownMillis = 0,
  }) async {
    final eventTime = nowServerMillis + countdownMillis;
    await chronoSettingsRef.set({
      'status': ChronoStatus.running.name,
      'authoritativeStartTimeMillis': eventTime,
      'accumulatedElapsedMillis': currentChrono.accumulatedElapsedMillis,
      'laps': currentChrono.laps, // Behoud bestaande rondes
    });
  }

  Future<void> pause(Chrono currentChrono, {required int nowServerMillis}) async {
    if (currentChrono.status != ChronoStatus.running) return;

    final newlyElapsed = nowServerMillis - currentChrono.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentChrono.accumulatedElapsedMillis + (newlyElapsed > 0 ? newlyElapsed : 0);

    await chronoSettingsRef.update({
      'status': ChronoStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  Future<void> lap(Chrono currentChrono, List<int> newLaps) async {
    await chronoSettingsRef.update({'laps': newLaps});
  }

  Future<void> reset() async {
    await chronoSettingsRef.set({
      'status': ChronoStatus.stopped.name,
      'authoritativeStartTimeMillis': 0,
      'accumulatedElapsedMillis': 0,
      'laps': <int>[], // Rondes resetten
    });
  }
}
