import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Merge: bestaande rondetijden blijven staan.
    await chronoSettingsRef.set({
      'status': ChronoStatus.running.name,
      'authoritativeStartTimeMillis': eventTime,
      'accumulatedElapsedMillis': currentChrono.accumulatedElapsedMillis,
    }, SetOptions(merge: true));
  }

  Future<void> pause(
    Chrono currentChrono, {
    required int nowServerMillis,
  }) async {
    if (currentChrono.status != ChronoStatus.running) return;

    final newlyElapsed =
        nowServerMillis - currentChrono.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentChrono.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    await chronoSettingsRef.update({
      'status': ChronoStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  /// arrayUnion i.p.v. de hele lijst herschrijven: twee baanknoppen vlak na
  /// elkaar mogen elkaars tijd niet overschrijven.
  ///
  /// Met [finish] (de laatste finale tijd, zie `isChronoFinished`) pauzeert
  /// de chrono in dezelfde schrijfactie, precies op de tijd van die lap.
  Future<void> addLap(ChronoLap lap, {bool finish = false}) async {
    await chronoSettingsRef.update({
      'lapTimes': FieldValue.arrayUnion([lap.toJson()]),
      if (finish) ...{
        'status': ChronoStatus.paused.name,
        'accumulatedElapsedMillis': lap.elapsedMillis,
      },
    });
  }

  /// Null = geen maximum.
  Future<void> setMaxLaps(int? maxLaps) async {
    await chronoSettingsRef.set({'maxLaps': maxLaps}, SetOptions(merge: true));
  }

  /// [maxLaps] blijft staan: het is een instelling, geen resultaat.
  Future<void> reset({int? maxLaps}) async {
    await chronoSettingsRef.set({
      'maxLaps': maxLaps,
      'status': ChronoStatus.stopped.name,
      'authoritativeStartTimeMillis': 0,
      'accumulatedElapsedMillis': 0,
      'lapTimes': <Map<String, dynamic>>[], // Rondes resetten
    });
  }
}
