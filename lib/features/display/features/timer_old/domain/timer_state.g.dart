// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimerState _$TimerStateFromJson(Map<String, dynamic> json) => _TimerState(
  status:
      $enumDecodeNullable(_$TimerStatusEnumMap, json['status']) ??
      TimerStatus.stopped,
  currentSet: json['currentSet'] == null
      ? null
      : TimerSet.fromJson(json['currentSet'] as Map<String, dynamic>),
  currentExerciseIndex: (json['currentExerciseIndex'] as num?)?.toInt() ?? 0,
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
  currentPhase:
      $enumDecodeNullable(_$TimerPhaseEnumMap, json['currentPhase']) ??
      TimerPhase.preparing,
  authoritativeStartTimeMillis:
      (json['authoritativeStartTimeMillis'] as num?)?.toInt() ?? 0,
  accumulatedMillis: (json['accumulatedMillis'] as num?)?.toInt() ?? 0,
  serverWriteTimestamp: _$JsonConverterFromJson<Object, Timestamp?>(
    json['serverWriteTimestamp'],
    const ServerTimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$TimerStateToJson(_TimerState instance) =>
    <String, dynamic>{
      'status': _$TimerStatusEnumMap[instance.status]!,
      'currentSet': instance.currentSet,
      'currentExerciseIndex': instance.currentExerciseIndex,
      'currentRound': instance.currentRound,
      'currentPhase': _$TimerPhaseEnumMap[instance.currentPhase]!,
      'authoritativeStartTimeMillis': instance.authoritativeStartTimeMillis,
      'accumulatedMillis': instance.accumulatedMillis,
      'serverWriteTimestamp': const ServerTimestampConverter().toJson(
        instance.serverWriteTimestamp,
      ),
    };

const _$TimerStatusEnumMap = {
  TimerStatus.stopped: 'stopped',
  TimerStatus.running: 'running',
  TimerStatus.paused: 'paused',
  TimerStatus.finished: 'finished',
};

const _$TimerPhaseEnumMap = {
  TimerPhase.preparing: 'preparing',
  TimerPhase.work: 'work',
  TimerPhase.exerciseRest: 'exerciseRest',
  TimerPhase.setRest: 'setRest',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
