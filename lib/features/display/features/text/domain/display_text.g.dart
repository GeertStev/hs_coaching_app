// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayText _$DisplayTextFromJson(Map<String, dynamic> json) => _DisplayText(
  title: json['title'] as String?,
  text: json['text'] as String,
  userId: json['userId'] as String,
  timestamp: const ServerWriteTimestampConverter().fromJson(json['timestamp']),
  status:
      $enumDecodeNullable(
        _$DisplayTextStatusEnumMap,
        json['status'],
        unknownValue: DisplayTextStatus.active,
      ) ??
      DisplayTextStatus.active,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$DisplayTextToJson(
  _DisplayText instance,
) => <String, dynamic>{
  'title': instance.title,
  'text': instance.text,
  'userId': instance.userId,
  'timestamp': const ServerWriteTimestampConverter().toJson(instance.timestamp),
  'status': _$DisplayTextStatusEnumMap[instance.status]!,
  'tags': instance.tags,
};

const _$DisplayTextStatusEnumMap = {
  DisplayTextStatus.active: 'active',
  DisplayTextStatus.archived: 'archived',
};
