// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sketch_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SketchElement _$SketchElementFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'path':
          return PathElement.fromJson(
            json
          );
                case 'arrow':
          return ArrowElement.fromJson(
            json
          );
                case 'line':
          return LineElement.fromJson(
            json
          );
                case 'rectangle':
          return RectangleElement.fromJson(
            json
          );
                case 'polygon':
          return PolygonElement.fromJson(
            json
          );
                case 'circle':
          return CircleElement.fromJson(
            json
          );
                case 'icon':
          return IconElement.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'SketchElement',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$SketchElement {

 String get id; SketchElementType get type;
/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SketchElementCopyWith<SketchElement> get copyWith => _$SketchElementCopyWithImpl<SketchElement>(this as SketchElement, _$identity);

  /// Serializes this SketchElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SketchElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type);

@override
String toString() {
  return 'SketchElement(id: $id, type: $type)';
}


}

/// @nodoc
abstract mixin class $SketchElementCopyWith<$Res>  {
  factory $SketchElementCopyWith(SketchElement value, $Res Function(SketchElement) _then) = _$SketchElementCopyWithImpl;
@useResult
$Res call({
 String id, SketchElementType type
});




}
/// @nodoc
class _$SketchElementCopyWithImpl<$Res>
    implements $SketchElementCopyWith<$Res> {
  _$SketchElementCopyWithImpl(this._self, this._then);

  final SketchElement _self;
  final $Res Function(SketchElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,
  ));
}

}


/// Adds pattern-matching-related methods to [SketchElement].
extension SketchElementPatterns on SketchElement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PathElement value)?  path,TResult Function( ArrowElement value)?  arrow,TResult Function( LineElement value)?  line,TResult Function( RectangleElement value)?  rectangle,TResult Function( PolygonElement value)?  polygon,TResult Function( CircleElement value)?  circle,TResult Function( IconElement value)?  icon,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PathElement() when path != null:
return path(_that);case ArrowElement() when arrow != null:
return arrow(_that);case LineElement() when line != null:
return line(_that);case RectangleElement() when rectangle != null:
return rectangle(_that);case PolygonElement() when polygon != null:
return polygon(_that);case CircleElement() when circle != null:
return circle(_that);case IconElement() when icon != null:
return icon(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PathElement value)  path,required TResult Function( ArrowElement value)  arrow,required TResult Function( LineElement value)  line,required TResult Function( RectangleElement value)  rectangle,required TResult Function( PolygonElement value)  polygon,required TResult Function( CircleElement value)  circle,required TResult Function( IconElement value)  icon,}){
final _that = this;
switch (_that) {
case PathElement():
return path(_that);case ArrowElement():
return arrow(_that);case LineElement():
return line(_that);case RectangleElement():
return rectangle(_that);case PolygonElement():
return polygon(_that);case CircleElement():
return circle(_that);case IconElement():
return icon(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PathElement value)?  path,TResult? Function( ArrowElement value)?  arrow,TResult? Function( LineElement value)?  line,TResult? Function( RectangleElement value)?  rectangle,TResult? Function( PolygonElement value)?  polygon,TResult? Function( CircleElement value)?  circle,TResult? Function( IconElement value)?  icon,}){
final _that = this;
switch (_that) {
case PathElement() when path != null:
return path(_that);case ArrowElement() when arrow != null:
return arrow(_that);case LineElement() when line != null:
return line(_that);case RectangleElement() when rectangle != null:
return rectangle(_that);case PolygonElement() when polygon != null:
return polygon(_that);case CircleElement() when circle != null:
return circle(_that);case IconElement() when icon != null:
return icon(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points)?  path,TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)?  arrow,TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)?  line,TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @ColorConverter()  Color? fillColor)?  rectangle,TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points, @ColorConverter()  Color? fillColor)?  polygon,TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset center,  double radius, @ColorConverter()  Color? fillColor)?  circle,TResult Function( String id,  SketchElementType type, @OffsetConverter()  Offset position,  String iconId,  double size,  double rotation)?  icon,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PathElement() when path != null:
return path(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points);case ArrowElement() when arrow != null:
return arrow(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case LineElement() when line != null:
return line(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case RectangleElement() when rectangle != null:
return rectangle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end,_that.fillColor);case PolygonElement() when polygon != null:
return polygon(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points,_that.fillColor);case CircleElement() when circle != null:
return circle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.center,_that.radius,_that.fillColor);case IconElement() when icon != null:
return icon(_that.id,_that.type,_that.position,_that.iconId,_that.size,_that.rotation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points)  path,required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)  arrow,required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)  line,required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @ColorConverter()  Color? fillColor)  rectangle,required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points, @ColorConverter()  Color? fillColor)  polygon,required TResult Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset center,  double radius, @ColorConverter()  Color? fillColor)  circle,required TResult Function( String id,  SketchElementType type, @OffsetConverter()  Offset position,  String iconId,  double size,  double rotation)  icon,}) {final _that = this;
switch (_that) {
case PathElement():
return path(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points);case ArrowElement():
return arrow(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case LineElement():
return line(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case RectangleElement():
return rectangle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end,_that.fillColor);case PolygonElement():
return polygon(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points,_that.fillColor);case CircleElement():
return circle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.center,_that.radius,_that.fillColor);case IconElement():
return icon(_that.id,_that.type,_that.position,_that.iconId,_that.size,_that.rotation);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points)?  path,TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)?  arrow,TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end)?  line,TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @ColorConverter()  Color? fillColor)?  rectangle,TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth,  List<Point> points, @ColorConverter()  Color? fillColor)?  polygon,TResult? Function( String id,  SketchElementType type, @ColorConverter()  Color color,  int strokeWidth, @OffsetConverter()  Offset center,  double radius, @ColorConverter()  Color? fillColor)?  circle,TResult? Function( String id,  SketchElementType type, @OffsetConverter()  Offset position,  String iconId,  double size,  double rotation)?  icon,}) {final _that = this;
switch (_that) {
case PathElement() when path != null:
return path(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points);case ArrowElement() when arrow != null:
return arrow(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case LineElement() when line != null:
return line(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end);case RectangleElement() when rectangle != null:
return rectangle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.start,_that.end,_that.fillColor);case PolygonElement() when polygon != null:
return polygon(_that.id,_that.type,_that.color,_that.strokeWidth,_that.points,_that.fillColor);case CircleElement() when circle != null:
return circle(_that.id,_that.type,_that.color,_that.strokeWidth,_that.center,_that.radius,_that.fillColor);case IconElement() when icon != null:
return icon(_that.id,_that.type,_that.position,_that.iconId,_that.size,_that.rotation);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class PathElement extends SketchElement {
  const PathElement({required this.id, this.type = SketchElementType.path, @ColorConverter() required this.color, required this.strokeWidth, required final  List<Point> points, final  String? $type}): _points = points,$type = $type ?? 'path',super._();
  factory PathElement.fromJson(Map<String, dynamic> json) => _$PathElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
 final  List<Point> _points;
 List<Point> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathElementCopyWith<PathElement> get copyWith => _$PathElementCopyWithImpl<PathElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PathElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'SketchElement.path(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, points: $points)';
}


}

/// @nodoc
abstract mixin class $PathElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $PathElementCopyWith(PathElement value, $Res Function(PathElement) _then) = _$PathElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth, List<Point> points
});




}
/// @nodoc
class _$PathElementCopyWithImpl<$Res>
    implements $PathElementCopyWith<$Res> {
  _$PathElementCopyWithImpl(this._self, this._then);

  final PathElement _self;
  final $Res Function(PathElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? points = null,}) {
  return _then(PathElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Point>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ArrowElement extends SketchElement {
  const ArrowElement({required this.id, this.type = SketchElementType.arrow, @ColorConverter() required this.color, required this.strokeWidth, @OffsetConverter() required this.start, @OffsetConverter() required this.end, final  String? $type}): $type = $type ?? 'arrow',super._();
  factory ArrowElement.fromJson(Map<String, dynamic> json) => _$ArrowElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
@OffsetConverter() final  Offset start;
@OffsetConverter() final  Offset end;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArrowElementCopyWith<ArrowElement> get copyWith => _$ArrowElementCopyWithImpl<ArrowElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArrowElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArrowElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,start,end);

@override
String toString() {
  return 'SketchElement.arrow(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $ArrowElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $ArrowElementCopyWith(ArrowElement value, $Res Function(ArrowElement) _then) = _$ArrowElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth,@OffsetConverter() Offset start,@OffsetConverter() Offset end
});




}
/// @nodoc
class _$ArrowElementCopyWithImpl<$Res>
    implements $ArrowElementCopyWith<$Res> {
  _$ArrowElementCopyWithImpl(this._self, this._then);

  final ArrowElement _self;
  final $Res Function(ArrowElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? start = null,Object? end = null,}) {
  return _then(ArrowElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LineElement extends SketchElement {
  const LineElement({required this.id, this.type = SketchElementType.line, @ColorConverter() required this.color, required this.strokeWidth, @OffsetConverter() required this.start, @OffsetConverter() required this.end, final  String? $type}): $type = $type ?? 'line',super._();
  factory LineElement.fromJson(Map<String, dynamic> json) => _$LineElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
@OffsetConverter() final  Offset start;
@OffsetConverter() final  Offset end;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineElementCopyWith<LineElement> get copyWith => _$LineElementCopyWithImpl<LineElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,start,end);

@override
String toString() {
  return 'SketchElement.line(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $LineElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $LineElementCopyWith(LineElement value, $Res Function(LineElement) _then) = _$LineElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth,@OffsetConverter() Offset start,@OffsetConverter() Offset end
});




}
/// @nodoc
class _$LineElementCopyWithImpl<$Res>
    implements $LineElementCopyWith<$Res> {
  _$LineElementCopyWithImpl(this._self, this._then);

  final LineElement _self;
  final $Res Function(LineElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? start = null,Object? end = null,}) {
  return _then(LineElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RectangleElement extends SketchElement {
  const RectangleElement({required this.id, this.type = SketchElementType.rectangle, @ColorConverter() required this.color, required this.strokeWidth, @OffsetConverter() required this.start, @OffsetConverter() required this.end, @ColorConverter() this.fillColor, final  String? $type}): $type = $type ?? 'rectangle',super._();
  factory RectangleElement.fromJson(Map<String, dynamic> json) => _$RectangleElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
@OffsetConverter() final  Offset start;
@OffsetConverter() final  Offset end;
@ColorConverter() final  Color? fillColor;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RectangleElementCopyWith<RectangleElement> get copyWith => _$RectangleElementCopyWithImpl<RectangleElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RectangleElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RectangleElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,start,end,fillColor);

@override
String toString() {
  return 'SketchElement.rectangle(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, start: $start, end: $end, fillColor: $fillColor)';
}


}

/// @nodoc
abstract mixin class $RectangleElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $RectangleElementCopyWith(RectangleElement value, $Res Function(RectangleElement) _then) = _$RectangleElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth,@OffsetConverter() Offset start,@OffsetConverter() Offset end,@ColorConverter() Color? fillColor
});




}
/// @nodoc
class _$RectangleElementCopyWithImpl<$Res>
    implements $RectangleElementCopyWith<$Res> {
  _$RectangleElementCopyWithImpl(this._self, this._then);

  final RectangleElement _self;
  final $Res Function(RectangleElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? start = null,Object? end = null,Object? fillColor = freezed,}) {
  return _then(RectangleElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,fillColor: freezed == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}


}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class PolygonElement extends SketchElement {
  const PolygonElement({required this.id, this.type = SketchElementType.polygon, @ColorConverter() required this.color, required this.strokeWidth, required final  List<Point> points, @ColorConverter() this.fillColor, final  String? $type}): _points = points,$type = $type ?? 'polygon',super._();
  factory PolygonElement.fromJson(Map<String, dynamic> json) => _$PolygonElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
 final  List<Point> _points;
 List<Point> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

// De hoekpunten van de veelhoek
@ColorConverter() final  Color? fillColor;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PolygonElementCopyWith<PolygonElement> get copyWith => _$PolygonElementCopyWithImpl<PolygonElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PolygonElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PolygonElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,const DeepCollectionEquality().hash(_points),fillColor);

@override
String toString() {
  return 'SketchElement.polygon(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, points: $points, fillColor: $fillColor)';
}


}

/// @nodoc
abstract mixin class $PolygonElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $PolygonElementCopyWith(PolygonElement value, $Res Function(PolygonElement) _then) = _$PolygonElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth, List<Point> points,@ColorConverter() Color? fillColor
});




}
/// @nodoc
class _$PolygonElementCopyWithImpl<$Res>
    implements $PolygonElementCopyWith<$Res> {
  _$PolygonElementCopyWithImpl(this._self, this._then);

  final PolygonElement _self;
  final $Res Function(PolygonElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? points = null,Object? fillColor = freezed,}) {
  return _then(PolygonElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Point>,fillColor: freezed == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CircleElement extends SketchElement {
  const CircleElement({required this.id, this.type = SketchElementType.circle, @ColorConverter() required this.color, required this.strokeWidth, @OffsetConverter() required this.center, required this.radius, @ColorConverter() this.fillColor, final  String? $type}): $type = $type ?? 'circle',super._();
  factory CircleElement.fromJson(Map<String, dynamic> json) => _$CircleElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@ColorConverter() final  Color color;
 final  int strokeWidth;
@OffsetConverter() final  Offset center;
 final  double radius;
@ColorConverter() final  Color? fillColor;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleElementCopyWith<CircleElement> get copyWith => _$CircleElementCopyWithImpl<CircleElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CircleElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircleElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.center, center) || other.center == center)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,color,strokeWidth,center,radius,fillColor);

@override
String toString() {
  return 'SketchElement.circle(id: $id, type: $type, color: $color, strokeWidth: $strokeWidth, center: $center, radius: $radius, fillColor: $fillColor)';
}


}

/// @nodoc
abstract mixin class $CircleElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $CircleElementCopyWith(CircleElement value, $Res Function(CircleElement) _then) = _$CircleElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@ColorConverter() Color color, int strokeWidth,@OffsetConverter() Offset center, double radius,@ColorConverter() Color? fillColor
});




}
/// @nodoc
class _$CircleElementCopyWithImpl<$Res>
    implements $CircleElementCopyWith<$Res> {
  _$CircleElementCopyWithImpl(this._self, this._then);

  final CircleElement _self;
  final $Res Function(CircleElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? color = null,Object? strokeWidth = null,Object? center = null,Object? radius = null,Object? fillColor = freezed,}) {
  return _then(CircleElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as int,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as Offset,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,fillColor: freezed == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class IconElement extends SketchElement {
  const IconElement({required this.id, this.type = SketchElementType.icon, @OffsetConverter() required this.position, required this.iconId, required this.size, this.rotation = 0.0, final  String? $type}): $type = $type ?? 'icon',super._();
  factory IconElement.fromJson(Map<String, dynamic> json) => _$IconElementFromJson(json);

@override final  String id;
@override@JsonKey() final  SketchElementType type;
@OffsetConverter() final  Offset position;
 final  String iconId;
// e.g., a key to map to an IconData or image asset
 final  double size;
@JsonKey() final  double rotation;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IconElementCopyWith<IconElement> get copyWith => _$IconElementCopyWithImpl<IconElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IconElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IconElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.position, position) || other.position == position)&&(identical(other.iconId, iconId) || other.iconId == iconId)&&(identical(other.size, size) || other.size == size)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,position,iconId,size,rotation);

@override
String toString() {
  return 'SketchElement.icon(id: $id, type: $type, position: $position, iconId: $iconId, size: $size, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class $IconElementCopyWith<$Res> implements $SketchElementCopyWith<$Res> {
  factory $IconElementCopyWith(IconElement value, $Res Function(IconElement) _then) = _$IconElementCopyWithImpl;
@override @useResult
$Res call({
 String id, SketchElementType type,@OffsetConverter() Offset position, String iconId, double size, double rotation
});




}
/// @nodoc
class _$IconElementCopyWithImpl<$Res>
    implements $IconElementCopyWith<$Res> {
  _$IconElementCopyWithImpl(this._self, this._then);

  final IconElement _self;
  final $Res Function(IconElement) _then;

/// Create a copy of SketchElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? position = null,Object? iconId = null,Object? size = null,Object? rotation = null,}) {
  return _then(IconElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SketchElementType,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Offset,iconId: null == iconId ? _self.iconId : iconId // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Point {

@OffsetConverter() Offset get offset; double get pressure;
/// Create a copy of Point
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointCopyWith<Point> get copyWith => _$PointCopyWithImpl<Point>(this as Point, _$identity);

  /// Serializes this Point to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Point&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.pressure, pressure) || other.pressure == pressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offset,pressure);

@override
String toString() {
  return 'Point(offset: $offset, pressure: $pressure)';
}


}

/// @nodoc
abstract mixin class $PointCopyWith<$Res>  {
  factory $PointCopyWith(Point value, $Res Function(Point) _then) = _$PointCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset offset, double pressure
});




}
/// @nodoc
class _$PointCopyWithImpl<$Res>
    implements $PointCopyWith<$Res> {
  _$PointCopyWithImpl(this._self, this._then);

  final Point _self;
  final $Res Function(Point) _then;

/// Create a copy of Point
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = null,Object? pressure = null,}) {
  return _then(_self.copyWith(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Point].
extension PointPatterns on Point {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Point value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Point() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Point value)  $default,){
final _that = this;
switch (_that) {
case _Point():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Point value)?  $default,){
final _that = this;
switch (_that) {
case _Point() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@OffsetConverter()  Offset offset,  double pressure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Point() when $default != null:
return $default(_that.offset,_that.pressure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@OffsetConverter()  Offset offset,  double pressure)  $default,) {final _that = this;
switch (_that) {
case _Point():
return $default(_that.offset,_that.pressure);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@OffsetConverter()  Offset offset,  double pressure)?  $default,) {final _that = this;
switch (_that) {
case _Point() when $default != null:
return $default(_that.offset,_that.pressure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Point implements Point {
  const _Point({@OffsetConverter() required this.offset, required this.pressure});
  factory _Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

@override@OffsetConverter() final  Offset offset;
@override final  double pressure;

/// Create a copy of Point
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointCopyWith<_Point> get copyWith => __$PointCopyWithImpl<_Point>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Point&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.pressure, pressure) || other.pressure == pressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offset,pressure);

@override
String toString() {
  return 'Point(offset: $offset, pressure: $pressure)';
}


}

/// @nodoc
abstract mixin class _$PointCopyWith<$Res> implements $PointCopyWith<$Res> {
  factory _$PointCopyWith(_Point value, $Res Function(_Point) _then) = __$PointCopyWithImpl;
@override @useResult
$Res call({
@OffsetConverter() Offset offset, double pressure
});




}
/// @nodoc
class __$PointCopyWithImpl<$Res>
    implements _$PointCopyWith<$Res> {
  __$PointCopyWithImpl(this._self, this._then);

  final _Point _self;
  final $Res Function(_Point) _then;

/// Create a copy of Point
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = null,Object? pressure = null,}) {
  return _then(_Point(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
