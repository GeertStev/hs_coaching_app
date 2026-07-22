import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';

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

  /// Opgeslagen sessies (snelkoppelingen) op clubniveau, zoals de
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
      return Tabata.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Schrijft de configuratie (voorbereiding + kaarten). Alleen bedoeld
  /// terwijl de timer gestopt is.
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

  // ------------------------------------------------------ Opgeslagen sessies

  Stream<List<TabataPreset>> watchPresets() {
    return _presetsRef.orderBy('title').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return TabataPreset(
          id: doc.id,
          title: data['title'] as String? ?? '',
          items: (data['items'] as List)
              .map(
                (json) => TabataItem.fromJson(json as Map<String, dynamic>),
              )
              .toList(),
        );
      }).toList(),
    );
  }

  Future<void> savePreset(String title, List<TabataItem> items) async {
    await _presetsRef.add({
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
    });
  }

  Future<void> deletePreset(String presetId) async {
    await _presetsRef.doc(presetId).delete();
  }
}
