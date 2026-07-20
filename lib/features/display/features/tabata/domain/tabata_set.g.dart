// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TabataSet _$TabataSetFromJson(Map<String, dynamic> json) => _TabataSet(
  title: json['title'] as String? ?? '',
  workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 20,
  restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 10,
  rounds: (json['rounds'] as num?)?.toInt() ?? 8,
  workDecrementSeconds: (json['workDecrementSeconds'] as num?)?.toInt() ?? 0,
  setRestSeconds: (json['setRestSeconds'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$TabataSetToJson(_TabataSet instance) =>
    <String, dynamic>{
      'title': instance.title,
      'workSeconds': instance.workSeconds,
      'restSeconds': instance.restSeconds,
      'rounds': instance.rounds,
      'workDecrementSeconds': instance.workDecrementSeconds,
      'setRestSeconds': instance.setRestSeconds,
    };
