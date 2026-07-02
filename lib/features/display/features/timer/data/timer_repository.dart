import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_exercise.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_state.dart';

class TimerRepository {
  TimerRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);

  // --- Collection References ---

  CollectionReference<TimerExercise> _timerExercisesRef(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('timerExercises')
        .withConverter<TimerExercise>(
          fromFirestore: (snapshot, _) => TimerExercise.fromFirestore(snapshot),
          toFirestore: (exercise, _) => exercise.toJson(),
        );
  }

  CollectionReference<TimerSet> _timerSetsRef(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('timerSets')
        .withConverter<TimerSet>(
          fromFirestore: (snapshot, _) => TimerSet.fromFirestore(snapshot),
          toFirestore: (set, _) => set.toJson(),
        );
  }

  DocumentReference _timerStateRef(String clubId, String displayId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('timer');
  }

  /// Reference to the document that stores timer settings like tags.
  /// Path: `.../settings/timer`
  DocumentReference _timerSettingsRef(String clubId, String displayId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('timer');
  }

  // --- TimerExercise Methods ---

  Stream<List<TimerExercise>> watchAllTimerExercises() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _timerExercisesRef(ids.clubId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTimerExercise(TimerExercise exercise) {
    final ids = _ref.read(displayDeviceIdsProvider);
    return _timerExercisesRef(ids.clubId).add(exercise);
  }

  Future<void> updateTimerExercise(TimerExercise exercise) {
    final ids = _ref.read(displayDeviceIdsProvider);
    return _timerExercisesRef(ids.clubId)
        .doc(exercise.id)
        .update(exercise.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteTimerExercise(String exerciseId) {
    final ids = _ref.read(displayDeviceIdsProvider);
    return _timerExercisesRef(ids.clubId).doc(exerciseId).delete();
  }

  // --- TimerSet Methods ---

  Stream<List<TimerSet>> watchAllTimerSets({String? tag}) {
    final ids = _ref.watch(displayDeviceIdsProvider);
    Query<TimerSet> query = _timerSetsRef(ids.clubId);

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTimerSet(TimerSet timerSet) {
    final ids = _ref.read(displayDeviceIdsProvider);
    final batch = _firestore.batch();
    final newDoc = _timerSetsRef(ids.clubId).doc();

    batch.set(newDoc, timerSet);

    if (timerSet.tags.isNotEmpty) {
      batch.set(_timerSettingsRef(ids.clubId, ids.displayDeviceId), {
        'timerTags': FieldValue.arrayUnion(timerSet.tags),
      }, SetOptions(merge: true));
    }

    return batch.commit();
  }

  Future<void> updateTimerSet(TimerSet timerSet) {
    final ids = _ref.read(displayDeviceIdsProvider);
    final batch = _firestore.batch();
    final docRef = _timerSetsRef(ids.clubId).doc(timerSet.id);

    batch.update(docRef, timerSet.copyWith(updatedAt: DateTime.now()).toJson());

    if (timerSet.tags.isNotEmpty) {
      batch.set(_timerSettingsRef(ids.clubId, ids.displayDeviceId), {
        'timerTags': FieldValue.arrayUnion(timerSet.tags),
      }, SetOptions(merge: true));
    }

    return batch.commit();
  }

  Future<void> deleteTimerSet(String setId) {
    final ids = _ref.read(displayDeviceIdsProvider);
    return _timerSetsRef(ids.clubId).doc(setId).delete();
  }

  // --- TimerState Methods ---

  Stream<TimerState> watchTimerState() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _timerStateRef(ids.clubId, ids.displayDeviceId).snapshots().map(
      (snapshot) => snapshot.exists
          ? TimerState.fromJson(snapshot.data() as Map<String, dynamic>)
          : const TimerState(),
    );
  }

  /// Returns a stream of the list of all used timer set tags.
  Stream<List<String>> watchAllTimerSetTags() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _timerSettingsRef(ids.clubId, ids.displayDeviceId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['timerTags'] ?? []);
    });
  }
}
