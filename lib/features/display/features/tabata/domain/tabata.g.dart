// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tabata _$TabataFromJson(Map<String, dynamic> json) => _Tabata(
  prepareSeconds: (json['prepareSeconds'] as num?)?.toInt() ?? 10,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TabataItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [TabataItem.exercise(TabataExercise(id: 'default'))],
  status:
      $enumDecodeNullable(_$TabataStatusEnumMap, json['status']) ??
      TabataStatus.stopped,
  authoritativeStartTimeMillis:
      (json['authoritativeStartTimeMillis'] as num?)?.toInt() ?? 0,
  serverWriteTimestamp: _$JsonConverterFromJson<Object, Timestamp?>(
    json['serverWriteTimestamp'],
    const ServerTimestampConverter().fromJson,
  ),
  accumulatedElapsedMillis:
      (json['accumulatedElapsedMillis'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TabataToJson(_Tabata instance) => <String, dynamic>{
  'prepareSeconds': instance.prepareSeconds,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'status': _$TabataStatusEnumMap[instance.status]!,
  'authoritativeStartTimeMillis': instance.authoritativeStartTimeMillis,
  'serverWriteTimestamp': const ServerTimestampConverter().toJson(
    instance.serverWriteTimestamp,
  ),
  'accumulatedElapsedMillis': instance.accumulatedElapsedMillis,
};

const _$TabataStatusEnumMap = {
  TabataStatus.stopped: 'stopped',
  TabataStatus.running: 'running',
  TabataStatus.paused: 'paused',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
