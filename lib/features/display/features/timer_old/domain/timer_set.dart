import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_core/core/data/firestore_converters.dart';

part 'timer_set.freezed.dart';
part 'timer_set.g.dart';

@freezed
sealed class TimerSet with _$TimerSet {
  @JsonSerializable(explicitToJson: true)
  const factory TimerSet({
    // Required parameters first
    required String title,
    required int restBetweenExercisesSeconds,
    required List<ExerciseInSet> exercises,
    required String ownerId,
    // Optional parameters last
    @Default('') String description,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @JsonKey(includeToJson: false) String? id,
  }) = _TimerSet;

  factory TimerSet.fromJson(Map<String, dynamic> json) =>
      _$TimerSetFromJson(json);

  /// Creates a TimerSet from a Firestore document snapshot.
  factory TimerSet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for timerSetId: ${snapshot.id}');
    }
    return TimerSet.fromJson(data).copyWith(id: snapshot.id);
  }
}

/// Represents an exercise embedded within a TimerSet.
///
/// This ensures that changes to the original Exercise template do not affect
/// already created TimerSets.
@freezed
sealed class ExerciseInSet with _$ExerciseInSet {
  @JsonSerializable()
  const factory ExerciseInSet({
    required String name,
    @Default('') String description,
    required int rounds,
    required int workSeconds,
    required int restSeconds,
  }) = _ExerciseInSet;

  factory ExerciseInSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseInSetFromJson(json);
}
