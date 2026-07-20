// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_text.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayText {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String? get title; String get text; String get userId;@ServerWriteTimestampConverter() DateTime get timestamp;@JsonKey(unknownEnumValue: DisplayTextStatus.active) DisplayTextStatus get status; List<String> get tags;
/// Create a copy of DisplayText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayTextCopyWith<DisplayText> get copyWith => _$DisplayTextCopyWithImpl<DisplayText>(this as DisplayText, _$identity);

  /// Serializes this DisplayText to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayText&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,text,userId,timestamp,status,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'DisplayText(id: $id, title: $title, text: $text, userId: $userId, timestamp: $timestamp, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $DisplayTextCopyWith<$Res>  {
  factory $DisplayTextCopyWith(DisplayText value, $Res Function(DisplayText) _then) = _$DisplayTextCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? title, String text, String userId,@ServerWriteTimestampConverter() DateTime timestamp,@JsonKey(unknownEnumValue: DisplayTextStatus.active) DisplayTextStatus status, List<String> tags
});




}
/// @nodoc
class _$DisplayTextCopyWithImpl<$Res>
    implements $DisplayTextCopyWith<$Res> {
  _$DisplayTextCopyWithImpl(this._self, this._then);

  final DisplayText _self;
  final $Res Function(DisplayText) _then;

/// Create a copy of DisplayText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? text = null,Object? userId = null,Object? timestamp = null,Object? status = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisplayTextStatus,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayText].
extension DisplayTextPatterns on DisplayText {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayText value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayText() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayText value)  $default,){
final _that = this;
switch (_that) {
case _DisplayText():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayText value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayText() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String text,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayTextStatus.active)  DisplayTextStatus status,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayText() when $default != null:
return $default(_that.id,_that.title,_that.text,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String text,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayTextStatus.active)  DisplayTextStatus status,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _DisplayText():
return $default(_that.id,_that.title,_that.text,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String text,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayTextStatus.active)  DisplayTextStatus status,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _DisplayText() when $default != null:
return $default(_that.id,_that.title,_that.text,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplayText implements DisplayText {
  const _DisplayText({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', this.title, required this.text, required this.userId, @ServerWriteTimestampConverter() required this.timestamp, @JsonKey(unknownEnumValue: DisplayTextStatus.active) this.status = DisplayTextStatus.active, final  List<String> tags = const <String>[]}): _tags = tags;
  factory _DisplayText.fromJson(Map<String, dynamic> json) => _$DisplayTextFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String? title;
@override final  String text;
@override final  String userId;
@override@ServerWriteTimestampConverter() final  DateTime timestamp;
@override@JsonKey(unknownEnumValue: DisplayTextStatus.active) final  DisplayTextStatus status;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of DisplayText
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayTextCopyWith<_DisplayText> get copyWith => __$DisplayTextCopyWithImpl<_DisplayText>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayTextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayText&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,text,userId,timestamp,status,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'DisplayText(id: $id, title: $title, text: $text, userId: $userId, timestamp: $timestamp, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$DisplayTextCopyWith<$Res> implements $DisplayTextCopyWith<$Res> {
  factory _$DisplayTextCopyWith(_DisplayText value, $Res Function(_DisplayText) _then) = __$DisplayTextCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? title, String text, String userId,@ServerWriteTimestampConverter() DateTime timestamp,@JsonKey(unknownEnumValue: DisplayTextStatus.active) DisplayTextStatus status, List<String> tags
});




}
/// @nodoc
class __$DisplayTextCopyWithImpl<$Res>
    implements _$DisplayTextCopyWith<$Res> {
  __$DisplayTextCopyWithImpl(this._self, this._then);

  final _DisplayText _self;
  final $Res Function(_DisplayText) _then;

/// Create a copy of DisplayText
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? text = null,Object? userId = null,Object? timestamp = null,Object? status = null,Object? tags = null,}) {
  return _then(_DisplayText(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisplayTextStatus,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
