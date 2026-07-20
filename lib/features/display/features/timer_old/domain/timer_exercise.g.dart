// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimerExercise _$TimerExerciseFromJson(Map<String, dynamic> json) =>
    _TimerExercise(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rounds: (json['rounds'] as num).toInt(),
      workSeconds: (json['workSeconds'] as num).toInt(),
      restSeconds: (json['restSeconds'] as num).toInt(),
      ownerId: json['ownerId'] as String,
      createdAt: _$JsonConverterFromJson<Object, DateTime?>(
        json['createdAt'],
        const TimestampConverter().fromJson,
      ),
      updatedAt: _$JsonConverterFromJson<Object, DateTime?>(
        json['updatedAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$TimerExerciseToJson(_TimerExercise instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'rounds': instance.rounds,
      'workSeconds': instance.workSeconds,
      'restSeconds': instance.restSeconds,
      'ownerId': instance.ownerId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
