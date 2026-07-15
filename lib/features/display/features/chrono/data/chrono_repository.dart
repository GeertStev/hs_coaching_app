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
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/chrono
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('chrono');
  }

  /// Returns a stream of the current chrono settings.
  Stream<Chrono> watchChrono() {
    return _chronoSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const Chrono(); // Default settings if document doesn't exist
      }
      return Chrono.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Starts or resumes the stopwatch.
  ///
  /// Writes the authoritative start time from the control app's clock and
  /// requests a server timestamp for synchronization.
  Future<void> start(Chrono currentChrono) async {
    final eventTime = DateTime.now().millisecondsSinceEpoch;

    await _chronoSettingsRef.set({
      'status': ChronoStatus.running.name,
      'authoritativeStartTimeMillis': eventTime,
      'serverWriteTimestamp': FieldValue.serverTimestamp(),
      // Carry over the previously accumulated time if we are resuming
      'accumulatedElapsedMillis': currentChrono.accumulatedElapsedMillis,
    });
  }

  /// Pauses the stopwatch.
  ///
  /// Calculates the elapsed time since the last start event and adds it to the
  /// accumulated total.
  Future<void> pause(Chrono currentChrono) async {
    if (currentChrono.status != ChronoStatus.running) return;

    final pauseEventTime = DateTime.now().millisecondsSinceEpoch;
    final newlyElapsed =
        pauseEventTime - currentChrono.authoritativeStartTimeMillis;

    // Ensure newlyElapsed is not negative due to clock sync edge cases
    final totalAccumulated =
        currentChrono.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    await _chronoSettingsRef.update({
      'status': ChronoStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  /// Resets the stopwatch to its initial state.
  Future<void> reset() async {
    await _chronoSettingsRef.set({
      'status': ChronoStatus.stopped.name,
      'authoritativeStartTimeMillis': 0,
      'serverWriteTimestamp': null,
      'accumulatedElapsedMillis': 0,
    });
  }
}
