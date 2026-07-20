// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayImage _$DisplayImageFromJson(Map<String, dynamic> json) =>
    _DisplayImage(
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String,
      userId: json['userId'] as String,
      timestamp: const ServerWriteTimestampConverter().fromJson(
        json['timestamp'],
      ),
      status:
          $enumDecodeNullable(
            _$DisplayImageStatusEnumMap,
            json['status'],
            unknownValue: DisplayImageStatus.active,
          ) ??
          DisplayImageStatus.active,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$DisplayImageToJson(
  _DisplayImage instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'url': instance.url,
  'userId': instance.userId,
  'timestamp': const ServerWriteTimestampConverter().toJson(instance.timestamp),
  'status': _$DisplayImageStatusEnumMap[instance.status]!,
  'tags': instance.tags,
};

const _$DisplayImageStatusEnumMap = {
  DisplayImageStatus.active: 'active',
  DisplayImageStatus.archived: 'archived',
};
