// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TabataGroup _$TabataGroupFromJson(Map<String, dynamic> json) => _TabataGroup(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  rounds: (json['rounds'] as num?)?.toInt() ?? 1,
  restBetweenRepeats: (json['restBetweenRepeats'] as num?)?.toInt() ?? 0,
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => TabataExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TabataExercise>[],
  restAfter: (json['restAfter'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TabataGroupToJson(_TabataGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'rounds': instance.rounds,
      'restBetweenRepeats': instance.restBetweenRepeats,
      'children': instance.children.map((e) => e.toJson()).toList(),
      'restAfter': instance.restAfter,
    };
