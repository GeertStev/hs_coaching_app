// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimerSet _$TimerSetFromJson(Map<String, dynamic> json) => _TimerSet(
  title: json['title'] as String,
  restBetweenExercisesSeconds: (json['restBetweenExercisesSeconds'] as num)
      .toInt(),
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => ExerciseInSet.fromJson(e as Map<String, dynamic>))
      .toList(),
  ownerId: json['ownerId'] as String,
  description: json['description'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: _$JsonConverterFromJson<Object, DateTime?>(
    json['createdAt'],
    const TimestampConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<Object, DateTime?>(
    json['updatedAt'],
    const TimestampConverter().fromJson,
  ),
  id: json['id'] as String?,
);

Map<String, dynamic> _$TimerSetToJson(_TimerSet instance) => <String, dynamic>{
  'title': instance.title,
  'restBetweenExercisesSeconds': instance.restBetweenExercisesSeconds,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'ownerId': instance.ownerId,
  'description': instance.description,
  'tags': instance.tags,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

_ExerciseInSet _$ExerciseInSetFromJson(Map<String, dynamic> json) =>
    _ExerciseInSet(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rounds: (json['rounds'] as num).toInt(),
      workSeconds: (json['workSeconds'] as num).toInt(),
      restSeconds: (json['restSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$ExerciseInSetToJson(_ExerciseInSet instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'rounds': instance.rounds,
      'workSeconds': instance.workSeconds,
      'restSeconds': instance.restSeconds,
    };
