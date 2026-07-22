// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TabataExercise _$TabataExerciseFromJson(Map<String, dynamic> json) =>
    _TabataExercise(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 20,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 10,
      rounds: (json['rounds'] as num?)?.toInt() ?? 8,
      stepSeconds: (json['stepSeconds'] as num?)?.toInt() ?? 0,
      restAfter: (json['restAfter'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TabataExerciseToJson(_TabataExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'workSeconds': instance.workSeconds,
      'restSeconds': instance.restSeconds,
      'rounds': instance.rounds,
      'stepSeconds': instance.stepSeconds,
      'restAfter': instance.restAfter,
    };
