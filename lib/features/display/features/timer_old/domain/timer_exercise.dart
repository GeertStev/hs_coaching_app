import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_core/core/data/firestore_converters.dart';

part 'timer_exercise.freezed.dart';
part 'timer_exercise.g.dart';

@freezed
abstract class TimerExercise with _$TimerExercise {
  const factory TimerExercise({
    @JsonKey(includeToJson: false) String? id,
    required String name,
    @Default('') String description,
    required int rounds,
    required int workSeconds,
    required int restSeconds,
    required String ownerId,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _TimerExercise;

  factory TimerExercise.fromJson(Map<String, dynamic> json) =>
      _$TimerExerciseFromJson(json);

  /// Creates an Exercise from a Firestore document snapshot.
  factory TimerExercise.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for timerExerciseId: ${snapshot.id}');
    }
    return TimerExercise.fromJson(data).copyWith(id: snapshot.id);
  }
}
