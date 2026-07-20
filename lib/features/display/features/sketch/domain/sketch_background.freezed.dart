// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sketch_background.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SketchBackground {

 String get title; String get url;
/// Create a copy of SketchBackground
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SketchBackgroundCopyWith<SketchBackground> get copyWith => _$SketchBackgroundCopyWithImpl<SketchBackground>(this as SketchBackground, _$identity);

  /// Serializes this SketchBackground to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SketchBackground&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,url);

@override
String toString() {
  return 'SketchBackground(title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class $SketchBackgroundCopyWith<$Res>  {
  factory $SketchBackgroundCopyWith(SketchBackground value, $Res Function(SketchBackground) _then) = _$SketchBackgroundCopyWithImpl;
@useResult
$Res call({
 String title, String url
});




}
/// @nodoc
class _$SketchBackgroundCopyWithImpl<$Res>
    implements $SketchBackgroundCopyWith<$Res> {
  _$SketchBackgroundCopyWithImpl(this._self, this._then);

  final SketchBackground _self;
  final $Res Function(SketchBackground) _then;

/// Create a copy of SketchBackground
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? url = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SketchBackground].
extension SketchBackgroundPatterns on SketchBackground {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SketchBackground value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SketchBackground() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SketchBackground value)  $default,){
final _that = this;
switch (_that) {
case _SketchBackground():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SketchBackground value)?  $default,){
final _that = this;
switch (_that) {
case _SketchBackground() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SketchBackground() when $default != null:
return $default(_that.title,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String url)  $default,) {final _that = this;
switch (_that) {
case _SketchBackground():
return $default(_that.title,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String url)?  $default,) {final _that = this;
switch (_that) {
case _SketchBackground() when $default != null:
return $default(_that.title,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SketchBackground implements SketchBackground {
  const _SketchBackground({this.title = 'Untitled', this.url = ''});
  factory _SketchBackground.fromJson(Map<String, dynamic> json) => _$SketchBackgroundFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  String url;

/// Create a copy of SketchBackground
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SketchBackgroundCopyWith<_SketchBackground> get copyWith => __$SketchBackgroundCopyWithImpl<_SketchBackground>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SketchBackgroundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SketchBackground&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,url);

@override
String toString() {
  return 'SketchBackground(title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class _$SketchBackgroundCopyWith<$Res> implements $SketchBackgroundCopyWith<$Res> {
  factory _$SketchBackgroundCopyWith(_SketchBackground value, $Res Function(_SketchBackground) _then) = __$SketchBackgroundCopyWithImpl;
@override @useResult
$Res call({
 String title, String url
});




}
/// @nodoc
class __$SketchBackgroundCopyWithImpl<$Res>
    implements _$SketchBackgroundCopyWith<$Res> {
  __$SketchBackgroundCopyWithImpl(this._self, this._then);

  final _SketchBackground _self;
  final $Res Function(_SketchBackground) _then;

/// Create a copy of SketchBackground
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? url = null,}) {
  return _then(_SketchBackground(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
