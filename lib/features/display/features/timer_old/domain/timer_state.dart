import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_set.dart';

part 'timer_state.freezed.dart';
part 'timer_state.g.dart';

enum TimerStatus { stopped, running, paused, finished }

enum TimerPhase { preparing, work, exerciseRest, setRest }

@freezed
abstract class TimerState with _$TimerState {
  @JsonSerializable()
  const factory TimerState({
    @Default(TimerStatus.stopped) TimerStatus status,

    /// The full TimerSet being executed.
    TimerSet? currentSet,

    /// The index of the active exercise in `currentSet.exercises`.
    @Default(0) int currentExerciseIndex,

    /// The current round for the active exercise.
    @Default(1) int currentRound,

    /// The current phase of the timer (e.g., work, rest).
    @Default(TimerPhase.preparing) TimerPhase currentPhase,

    /// The local timestamp from the coach's app when the current phase began.
    @Default(0) int authoritativeStartTimeMillis,

    /// Time already elapsed in the current phase before a pause.
    @Default(0) int accumulatedMillis,

    /// Firestore server timestamp of when the start event was written.
    /// This is used to calculate the clock offset.
    @ServerTimestampConverter() Timestamp? serverWriteTimestamp,
  }) = _TimerState;

  factory TimerState.fromJson(Map<String, dynamic> json) =>
      _$TimerStateFromJson(json);
}
