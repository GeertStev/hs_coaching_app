import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';

class TabataRepository {
  TabataRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _tabataSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('tabata');
  }

  /// Standaard sets (snelkoppelingen) op clubniveau, zoals de
  /// timer-bibliotheek.
  CollectionReference<Map<String, dynamic>> get _presetsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('tabataPresets');
  }

  Stream<Tabata> watchTabata() {
    return _tabataSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const Tabata();
      }
      return Tabata.fromJson(
        _normalizeLegacySets(snapshot.data() as Map<String, dynamic>),
      );
    });
  }

  /// Oude platte structuur (workSeconds/restSeconds/rounds op topniveau)
  /// → dezelfde configuratie als één set. Normalisatie hoort in de
  /// repository zodat [Tabata.fromJson] canoniek blijft (zie CLAUDE.md).
  Map<String, dynamic> _normalizeLegacySets(Map<String, dynamic> data) {
    if (data['sets'] != null) return data;
    return {
      ...data,
      'sets': [
        {
          if (data['workSeconds'] != null) 'workSeconds': data['workSeconds'],
          if (data['restSeconds'] != null) 'restSeconds': data['restSeconds'],
          if (data['rounds'] != null) 'rounds': data['rounds'],
        },
      ],
    };
  }

  /// Schrijft de configuratie (voorbereiding + sets). Alleen bedoeld terwijl
  /// de timer gestopt is.
  Future<void> saveConfig(Tabata tabata) async {
    await _tabataSettingsRef.set(
      tabata.copyWith(serverWriteTimestamp: null).toJson(),
    );
  }

  /// Start of hervat de timer. [accumulatedElapsedMillis] blijft behouden,
  /// dus hervatten na een pauze gebruikt dezelfde methode.
  Future<void> start(Tabata currentTabata) async {
    final eventTime = DateTime.now().millisecondsSinceEpoch;
    // serverWriteTimestamp: null → converter schrijft FieldValue.serverTimestamp()
    await _tabataSettingsRef.set(
      currentTabata
          .copyWith(
            status: TabataStatus.running,
            authoritativeStartTimeMillis: eventTime,
            serverWriteTimestamp: null,
          )
          .toJson(),
    );
  }

  Future<void> pause(Tabata currentTabata) async {
    if (currentTabata.status != TabataStatus.running) return;

    final pauseEventTime = DateTime.now().millisecondsSinceEpoch;
    final newlyElapsed =
        pauseEventTime - currentTabata.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentTabata.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    await _tabataSettingsRef.update({
      'status': TabataStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  /// Zet de timer terug naar gestopt; de configuratie blijft behouden.
  Future<void> reset(Tabata currentTabata) async {
    await _tabataSettingsRef.set(
      currentTabata
          .copyWith(
            status: TabataStatus.stopped,
            authoritativeStartTimeMillis: 0,
            serverWriteTimestamp: null,
            accumulatedElapsedMillis: 0,
          )
          .toJson(),
    );
  }

  // ------------------------------------------------------ Standaard sets

  Stream<List<TabataPreset>> watchPresets() {
    return _presetsRef.orderBy('title').snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => TabataPreset(
              id: doc.id,
              set: TabataSet.fromJson(doc.data()),
            ),
          )
          .toList(),
    );
  }

  Future<void> savePreset(TabataSet set) async {
    await _presetsRef.add(set.toJson());
  }

  Future<void> deletePreset(String presetId) async {
    await _presetsRef.doc(presetId).delete();
  }
}
