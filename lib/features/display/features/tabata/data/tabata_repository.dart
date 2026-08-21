import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_repository.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';

/// Adds config/start/pause/reset writes and the club-level preset library on
/// top of core's read-only [DisplayTabataRepository] base. Drift correction
/// on start/pause comes from RTDB's `.info/serverTimeOffset` (via
/// `nowServerMillis`), even though the document itself lives in Firestore —
/// see `DisplayTabataRepository`'s doc comment.
class TabataRepository extends DisplayTabataRepository {
  TabataRepository({
    required super.firestore,
    required super.clubId,
    required super.displayId,
  });

  /// Opgeslagen sessies (snelkoppelingen) op clubniveau, zoals de
  /// timer-bibliotheek.
  CollectionReference<Map<String, dynamic>> get _presetsRef {
    return firestore.collection('clubs').doc(clubId).collection('tabataPresets');
  }

  /// Schrijft de configuratie (voorbereiding + kaarten). Alleen bedoeld
  /// terwijl de timer gestopt is.
  Future<void> saveConfig(Tabata tabata) async {
    await tabataSettingsRef.set(tabata.toJson());
  }

  /// Start of hervat de timer. [accumulatedElapsedMillis] blijft behouden,
  /// dus hervatten na een pauze gebruikt dezelfde methode. [nowServerMillis]
  /// moet al gecorrigeerd zijn voor het klokverschil van dit apparaat (zie
  /// `serverNowMillis`/`serverTimeOffsetProvider`).
  Future<void> start(Tabata currentTabata, {required int nowServerMillis}) async {
    await tabataSettingsRef.set(
      currentTabata
          .copyWith(
            status: TabataStatus.running,
            authoritativeStartTimeMillis: nowServerMillis,
          )
          .toJson(),
    );
  }

  Future<void> pause(Tabata currentTabata, {required int nowServerMillis}) async {
    if (currentTabata.status != TabataStatus.running) return;

    final newlyElapsed = nowServerMillis - currentTabata.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentTabata.accumulatedElapsedMillis + (newlyElapsed > 0 ? newlyElapsed : 0);

    await tabataSettingsRef.update({
      'status': TabataStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  /// Zet de timer terug naar gestopt; de configuratie blijft behouden.
  Future<void> reset(Tabata currentTabata) async {
    await tabataSettingsRef.set(
      currentTabata
          .copyWith(
            status: TabataStatus.stopped,
            authoritativeStartTimeMillis: 0,
            accumulatedElapsedMillis: 0,
          )
          .toJson(),
    );
  }

  // ------------------------------------------------------ Opgeslagen sessies

  Stream<List<TabataPreset>> watchPresets() {
    return _presetsRef.orderBy('title').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return TabataPreset(
          id: doc.id,
          title: data['title'] as String? ?? '',
          workSeconds: data['workSeconds'] as int? ?? 20,
          restSeconds: data['restSeconds'] as int? ?? 10,
          stepSeconds: data['stepSeconds'] as int? ?? 0,
          rounds: data['rounds'] as int? ?? 8,
          sets: data['sets'] as int? ?? 1,
          restBetweenSets: data['restBetweenSets'] as int? ?? 0,
        );
      }).toList(),
    );
  }

  Future<void> savePreset(
    String title, {
    required int workSeconds,
    required int restSeconds,
    required int stepSeconds,
    required int rounds,
    required int sets,
    required int restBetweenSets,
  }) async {
    await _presetsRef.add({
      'title': title,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'stepSeconds': stepSeconds,
      'rounds': rounds,
      'sets': sets,
      'restBetweenSets': restBetweenSets,
    });
  }

  Future<void> deletePreset(String presetId) async {
    await _presetsRef.doc(presetId).delete();
  }
}
