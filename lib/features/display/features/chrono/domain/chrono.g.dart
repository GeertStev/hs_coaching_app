// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrono.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chrono _$ChronoFromJson(Map<String, dynamic> json) => _Chrono(
  status:
      $enumDecodeNullable(_$ChronoStatusEnumMap, json['status']) ??
      ChronoStatus.stopped,
  authoritativeStartTimeMillis:
      (json['authoritativeStartTimeMillis'] as num?)?.toInt() ?? 0,
  serverWriteTimestamp: _$JsonConverterFromJson<Object, Timestamp?>(
    json['serverWriteTimestamp'],
    const ServerTimestampConverter().fromJson,
  ),
  accumulatedElapsedMillis:
      (json['accumulatedElapsedMillis'] as num?)?.toInt() ?? 0,
  laps:
      (json['laps'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
);

Map<String, dynamic> _$ChronoToJson(_Chrono instance) => <String, dynamic>{
  'status': _$ChronoStatusEnumMap[instance.status]!,
  'authoritativeStartTimeMillis': instance.authoritativeStartTimeMillis,
  'serverWriteTimestamp': const ServerTimestampConverter().toJson(
    instance.serverWriteTimestamp,
  ),
  'accumulatedElapsedMillis': instance.accumulatedElapsedMillis,
  'laps': instance.laps,
};

const _$ChronoStatusEnumMap = {
  ChronoStatus.stopped: 'stopped',
  ChronoStatus.running: 'running',
  ChronoStatus.paused: 'paused',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
