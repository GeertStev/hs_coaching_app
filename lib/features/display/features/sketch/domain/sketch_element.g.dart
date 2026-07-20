// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sketch_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathElement _$PathElementFromJson(Map<String, dynamic> json) => PathElement(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
      SketchElementType.path,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  strokeWidth: (json['strokeWidth'] as num).toInt(),
  points: (json['points'] as List<dynamic>)
      .map((e) => Point.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$PathElementToJson(PathElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'points': instance.points.map((e) => e.toJson()).toList(),
      'runtimeType': instance.$type,
    };

const _$SketchElementTypeEnumMap = {
  SketchElementType.path: 'path',
  SketchElementType.arrow: 'arrow',
  SketchElementType.line: 'line',
  SketchElementType.rectangle: 'rectangle',
  SketchElementType.polygon: 'polygon',
  SketchElementType.circle: 'circle',
  SketchElementType.icon: 'icon',
};

ArrowElement _$ArrowElementFromJson(Map<String, dynamic> json) => ArrowElement(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
      SketchElementType.arrow,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  strokeWidth: (json['strokeWidth'] as num).toInt(),
  start: const OffsetConverter().fromJson(
    json['start'] as Map<String, dynamic>,
  ),
  end: const OffsetConverter().fromJson(json['end'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ArrowElementToJson(ArrowElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'start': const OffsetConverter().toJson(instance.start),
      'end': const OffsetConverter().toJson(instance.end),
      'runtimeType': instance.$type,
    };

LineElement _$LineElementFromJson(Map<String, dynamic> json) => LineElement(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
      SketchElementType.line,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  strokeWidth: (json['strokeWidth'] as num).toInt(),
  start: const OffsetConverter().fromJson(
    json['start'] as Map<String, dynamic>,
  ),
  end: const OffsetConverter().fromJson(json['end'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LineElementToJson(LineElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'start': const OffsetConverter().toJson(instance.start),
      'end': const OffsetConverter().toJson(instance.end),
      'runtimeType': instance.$type,
    };

RectangleElement _$RectangleElementFromJson(Map<String, dynamic> json) =>
    RectangleElement(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
          SketchElementType.rectangle,
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
      strokeWidth: (json['strokeWidth'] as num).toInt(),
      start: const OffsetConverter().fromJson(
        json['start'] as Map<String, dynamic>,
      ),
      end: const OffsetConverter().fromJson(
        json['end'] as Map<String, dynamic>,
      ),
      fillColor: _$JsonConverterFromJson<int, Color>(
        json['fillColor'],
        const ColorConverter().fromJson,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$RectangleElementToJson(RectangleElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'start': const OffsetConverter().toJson(instance.start),
      'end': const OffsetConverter().toJson(instance.end),
      'fillColor': _$JsonConverterToJson<int, Color>(
        instance.fillColor,
        const ColorConverter().toJson,
      ),
      'runtimeType': instance.$type,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

PolygonElement _$PolygonElementFromJson(Map<String, dynamic> json) =>
    PolygonElement(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
          SketchElementType.polygon,
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
      strokeWidth: (json['strokeWidth'] as num).toInt(),
      points: (json['points'] as List<dynamic>)
          .map((e) => Point.fromJson(e as Map<String, dynamic>))
          .toList(),
      fillColor: _$JsonConverterFromJson<int, Color>(
        json['fillColor'],
        const ColorConverter().fromJson,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$PolygonElementToJson(PolygonElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'points': instance.points.map((e) => e.toJson()).toList(),
      'fillColor': _$JsonConverterToJson<int, Color>(
        instance.fillColor,
        const ColorConverter().toJson,
      ),
      'runtimeType': instance.$type,
    };

CircleElement _$CircleElementFromJson(Map<String, dynamic> json) =>
    CircleElement(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
          SketchElementType.circle,
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
      strokeWidth: (json['strokeWidth'] as num).toInt(),
      center: const OffsetConverter().fromJson(
        json['center'] as Map<String, dynamic>,
      ),
      radius: (json['radius'] as num).toDouble(),
      fillColor: _$JsonConverterFromJson<int, Color>(
        json['fillColor'],
        const ColorConverter().fromJson,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CircleElementToJson(CircleElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'center': const OffsetConverter().toJson(instance.center),
      'radius': instance.radius,
      'fillColor': _$JsonConverterToJson<int, Color>(
        instance.fillColor,
        const ColorConverter().toJson,
      ),
      'runtimeType': instance.$type,
    };

IconElement _$IconElementFromJson(Map<String, dynamic> json) => IconElement(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$SketchElementTypeEnumMap, json['type']) ??
      SketchElementType.icon,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  iconId: json['iconId'] as String,
  size: (json['size'] as num).toDouble(),
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$IconElementToJson(IconElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SketchElementTypeEnumMap[instance.type]!,
      'position': const OffsetConverter().toJson(instance.position),
      'iconId': instance.iconId,
      'size': instance.size,
      'rotation': instance.rotation,
      'runtimeType': instance.$type,
    };

_Point _$PointFromJson(Map<String, dynamic> json) => _Point(
  offset: const OffsetConverter().fromJson(
    json['offset'] as Map<String, dynamic>,
  ),
  pressure: (json['pressure'] as num).toDouble(),
);

Map<String, dynamic> _$PointToJson(_Point instance) => <String, dynamic>{
  'offset': const OffsetConverter().toJson(instance.offset),
  'pressure': instance.pressure,
};
