// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayImage {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String? get title; String? get description; String get url; String get userId;@ServerWriteTimestampConverter() DateTime get timestamp;@JsonKey(unknownEnumValue: DisplayImageStatus.active) DisplayImageStatus get status; List<String> get tags;
/// Create a copy of DisplayImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayImageCopyWith<DisplayImage> get copyWith => _$DisplayImageCopyWithImpl<DisplayImage>(this as DisplayImage, _$identity);

  /// Serializes this DisplayImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayImage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,url,userId,timestamp,status,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'DisplayImage(id: $id, title: $title, description: $description, url: $url, userId: $userId, timestamp: $timestamp, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $DisplayImageCopyWith<$Res>  {
  factory $DisplayImageCopyWith(DisplayImage value, $Res Function(DisplayImage) _then) = _$DisplayImageCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? title, String? description, String url, String userId,@ServerWriteTimestampConverter() DateTime timestamp,@JsonKey(unknownEnumValue: DisplayImageStatus.active) DisplayImageStatus status, List<String> tags
});




}
/// @nodoc
class _$DisplayImageCopyWithImpl<$Res>
    implements $DisplayImageCopyWith<$Res> {
  _$DisplayImageCopyWithImpl(this._self, this._then);

  final DisplayImage _self;
  final $Res Function(DisplayImage) _then;

/// Create a copy of DisplayImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? url = null,Object? userId = null,Object? timestamp = null,Object? status = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisplayImageStatus,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayImage].
extension DisplayImagePatterns on DisplayImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayImage value)  $default,){
final _that = this;
switch (_that) {
case _DisplayImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayImage value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String? description,  String url,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayImageStatus.active)  DisplayImageStatus status,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayImage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.url,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String? description,  String url,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayImageStatus.active)  DisplayImageStatus status,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _DisplayImage():
return $default(_that.id,_that.title,_that.description,_that.url,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? title,  String? description,  String url,  String userId, @ServerWriteTimestampConverter()  DateTime timestamp, @JsonKey(unknownEnumValue: DisplayImageStatus.active)  DisplayImageStatus status,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _DisplayImage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.url,_that.userId,_that.timestamp,_that.status,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplayImage implements DisplayImage {
  const _DisplayImage({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', this.title, this.description, required this.url, required this.userId, @ServerWriteTimestampConverter() required this.timestamp, @JsonKey(unknownEnumValue: DisplayImageStatus.active) this.status = DisplayImageStatus.active, final  List<String> tags = const <String>[]}): _tags = tags;
  factory _DisplayImage.fromJson(Map<String, dynamic> json) => _$DisplayImageFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String? title;
@override final  String? description;
@override final  String url;
@override final  String userId;
@override@ServerWriteTimestampConverter() final  DateTime timestamp;
@override@JsonKey(unknownEnumValue: DisplayImageStatus.active) final  DisplayImageStatus status;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of DisplayImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayImageCopyWith<_DisplayImage> get copyWith => __$DisplayImageCopyWithImpl<_DisplayImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayImage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,url,userId,timestamp,status,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'DisplayImage(id: $id, title: $title, description: $description, url: $url, userId: $userId, timestamp: $timestamp, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$DisplayImageCopyWith<$Res> implements $DisplayImageCopyWith<$Res> {
  factory _$DisplayImageCopyWith(_DisplayImage value, $Res Function(_DisplayImage) _then) = __$DisplayImageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? title, String? description, String url, String userId,@ServerWriteTimestampConverter() DateTime timestamp,@JsonKey(unknownEnumValue: DisplayImageStatus.active) DisplayImageStatus status, List<String> tags
});




}
/// @nodoc
class __$DisplayImageCopyWithImpl<$Res>
    implements _$DisplayImageCopyWith<$Res> {
  __$DisplayImageCopyWithImpl(this._self, this._then);

  final _DisplayImage _self;
  final $Res Function(_DisplayImage) _then;

/// Create a copy of DisplayImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? url = null,Object? userId = null,Object? timestamp = null,Object? status = null,Object? tags = null,}) {
  return _then(_DisplayImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisplayImageStatus,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
