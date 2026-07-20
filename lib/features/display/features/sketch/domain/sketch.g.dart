// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sketch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sketch _$SketchFromJson(Map<String, dynamic> json) => _Sketch(
  title: json['title'] as String,
  description: json['description'] as String?,
  lastModified: const TimestampOrNowConverter().fromJson(json['lastModified']),
  userId: json['userId'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  status:
      $enumDecodeNullable(
        _$SketchStatusEnumMap,
        json['status'],
        unknownValue: SketchStatus.active,
      ) ??
      SketchStatus.active,
  backgroundUrl: json['backgroundUrl'] as String?,
);

Map<String, dynamic> _$SketchToJson(_Sketch instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'lastModified': const TimestampOrNowConverter().toJson(instance.lastModified),
  'userId': instance.userId,
  'tags': instance.tags,
  'status': _$SketchStatusEnumMap[instance.status]!,
  'backgroundUrl': ?instance.backgroundUrl,
};

const _$SketchStatusEnumMap = {
  SketchStatus.active: 'active',
  SketchStatus.archived: 'archived',
};
