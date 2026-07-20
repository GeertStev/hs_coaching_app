import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_exercise.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_state.dart';

class TimerRepository {
  TimerRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  // --- Collection References ---

  CollectionReference<TimerExercise> get _timerExercisesRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('timerExercises')
        .withConverter<TimerExercise>(
          fromFirestore: (snapshot, _) => TimerExercise.fromFirestore(snapshot),
          toFirestore: (exercise, _) => exercise.toJson(),
        );
  }

  CollectionReference<TimerSet> get _timerSetsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('timerSets')
        .withConverter<TimerSet>(
          fromFirestore: (snapshot, _) => TimerSet.fromFirestore(snapshot),
          toFirestore: (set, _) => set.toJson(),
        );
  }

  DocumentReference get _timerStateRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('timer');
  }

  /// Reference to the document that stores timer settings like tags.
  /// Path: `.../settings/timer`
  DocumentReference get _timerSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('timer');
  }

  // --- TimerExercise Methods ---

  Stream<List<TimerExercise>> watchAllTimerExercises() {
    return _timerExercisesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTimerExercise(TimerExercise exercise) {
    return _timerExercisesRef.add(exercise);
  }

  Future<void> updateTimerExercise(TimerExercise exercise) {
    return _timerExercisesRef
        .doc(exercise.id)
        .update(exercise.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteTimerExercise(String exerciseId) {
    return _timerExercisesRef.doc(exerciseId).delete();
  }

  // --- TimerSet Methods ---

  Stream<List<TimerSet>> watchAllTimerSets({String? tag}) {
    Query<TimerSet> query = _timerSetsRef;

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTimerSet(TimerSet timerSet) {
    final batch = _firestore.batch();
    final newDoc = _timerSetsRef.doc();

    batch.set(newDoc, timerSet);

    if (timerSet.tags.isNotEmpty) {
      batch.set(_timerSettingsRef, {
        'timerTags': FieldValue.arrayUnion(timerSet.tags),
      }, SetOptions(merge: true));
    }

    return batch.commit();
  }

  Future<void> updateTimerSet(TimerSet timerSet) {
    final batch = _firestore.batch();
    final docRef = _timerSetsRef.doc(timerSet.id);

    batch.update(docRef, timerSet.copyWith(updatedAt: DateTime.now()).toJson());

    if (timerSet.tags.isNotEmpty) {
      batch.set(_timerSettingsRef, {
        'timerTags': FieldValue.arrayUnion(timerSet.tags),
      }, SetOptions(merge: true));
    }

    return batch.commit();
  }

  Future<void> deleteTimerSet(String setId) {
    return _timerSetsRef.doc(setId).delete();
  }

  // --- TimerState Methods ---

  Stream<TimerState> watchTimerState() {
    return _timerStateRef.snapshots().map(
      (snapshot) => snapshot.exists
          ? TimerState.fromJson(snapshot.data() as Map<String, dynamic>)
          : const TimerState(),
    );
  }

  /// Returns a stream of the list of all used timer set tags.
  Stream<List<String>> watchAllTimerSetTags() {
    return _timerSettingsRef.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['timerTags'] ?? []);
    });
  }
}
