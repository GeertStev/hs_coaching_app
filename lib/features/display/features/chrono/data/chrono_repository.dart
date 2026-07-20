import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

class ChronoRepository {
  ChronoRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _chronoSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('chrono');
  }

  Stream<Chrono> watchChrono() {
    return _chronoSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const Chrono();
      }
      return Chrono.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<void> start(Chrono currentChrono, {int countdownMillis = 0}) async {
    // Verschuif de starttijd naar de toekomst als er een countdown is
    final eventTime = DateTime.now().millisecondsSinceEpoch + countdownMillis;
    await _chronoSettingsRef.set({
      'status': ChronoStatus.running.name,
      'authoritativeStartTimeMillis': eventTime,
      'serverWriteTimestamp': FieldValue.serverTimestamp(),
      'accumulatedElapsedMillis': currentChrono.accumulatedElapsedMillis,
      'laps': currentChrono.laps, // Behoud bestaande rondes
    });
  }

  Future<void> pause(Chrono currentChrono) async {
    if (currentChrono.status != ChronoStatus.running) return;

    final pauseEventTime = DateTime.now().millisecondsSinceEpoch;
    final newlyElapsed =
        pauseEventTime - currentChrono.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentChrono.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    await _chronoSettingsRef.update({
      'status': ChronoStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  Future<void> lap(Chrono currentChrono, List<int> newLaps) async {
    await _chronoSettingsRef.update({'laps': newLaps});
  }

  Future<void> reset() async {
    await _chronoSettingsRef.set({
      'status': ChronoStatus.stopped.name,
      'authoritativeStartTimeMillis': 0,
      'serverWriteTimestamp': null,
      'accumulatedElapsedMillis': 0,
      'laps': [], // Rondes resetten
    });
  }
}
