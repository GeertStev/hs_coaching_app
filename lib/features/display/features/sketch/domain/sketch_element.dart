import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/offset_converter.dart';

part 'sketch_element.freezed.dart';
part 'sketch_element.g.dart';

enum SketchElementType { path, arrow, line, rectangle, polygon, circle, icon }

/// A map to hold available icons. This can be expanded easily.
const Map<String, IconData> availableIcons = {
  'person': Icons.person,
  'person_outlined': Icons.person_outlined,
  'album': Icons.album,
};

@freezed
sealed class SketchElement with _$SketchElement {
  const SketchElement._();

  @JsonSerializable(explicitToJson: true)
  const factory SketchElement.path({
    required String id,
    @Default(SketchElementType.path) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    required List<Point> points,
  }) = PathElement;

  const factory SketchElement.arrow({
    required String id,
    @Default(SketchElementType.arrow) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    @OffsetConverter() required Offset start,
    @OffsetConverter() required Offset end,
  }) = ArrowElement;

  const factory SketchElement.line({
    required String id,
    @Default(SketchElementType.line) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    @OffsetConverter() required Offset start,
    @OffsetConverter() required Offset end,
  }) = LineElement;

  const factory SketchElement.rectangle({
    required String id,
    @Default(SketchElementType.rectangle) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    @OffsetConverter() required Offset start,
    @OffsetConverter() required Offset end,
    @ColorConverter() Color? fillColor,
  }) = RectangleElement;

  @JsonSerializable(explicitToJson: true)
  const factory SketchElement.polygon({
    required String id,
    @Default(SketchElementType.polygon) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    required List<Point> points, // De hoekpunten van de veelhoek
    @ColorConverter() Color? fillColor,
  }) = PolygonElement;

  const factory SketchElement.circle({
    required String id,
    @Default(SketchElementType.circle) SketchElementType type,
    @ColorConverter() required Color color,
    required int strokeWidth,
    @OffsetConverter() required Offset center,
    required double radius,
    @ColorConverter() Color? fillColor,
  }) = CircleElement;

  const factory SketchElement.icon({
    required String id,
    @Default(SketchElementType.icon) SketchElementType type,
    @OffsetConverter() required Offset position,
    required String iconId, // e.g., a key to map to an IconData or image asset
    required double size,
    @Default(0.0) double rotation,
  }) = IconElement;

  factory SketchElement.fromJson(Map<String, dynamic> json) =>
      _$SketchElementFromJson(json);
}

@freezed
abstract class Point with _$Point {
  const factory Point({
    @OffsetConverter() required Offset offset,
    required double pressure,
  }) = _Point;

  factory Point.fromJson(Map<String, dynamic> json) => _Point.fromJson(json);
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.toARGB32();
}
