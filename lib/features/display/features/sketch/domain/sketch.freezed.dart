// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sketch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sketch {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String get title; String? get description;@TimestampOrNowConverter() DateTime get lastModified; String get userId; List<String> get tags;@JsonKey(unknownEnumValue: SketchStatus.active) SketchStatus get status;@JsonKey(includeIfNull: false) String? get backgroundUrl;
/// Create a copy of Sketch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SketchCopyWith<Sketch> get copyWith => _$SketchCopyWithImpl<Sketch>(this as Sketch, _$identity);

  /// Serializes this Sketch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sketch&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.backgroundUrl, backgroundUrl) || other.backgroundUrl == backgroundUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,lastModified,userId,const DeepCollectionEquality().hash(tags),status,backgroundUrl);

@override
String toString() {
  return 'Sketch(id: $id, title: $title, description: $description, lastModified: $lastModified, userId: $userId, tags: $tags, status: $status, backgroundUrl: $backgroundUrl)';
}


}

/// @nodoc
abstract mixin class $SketchCopyWith<$Res>  {
  factory $SketchCopyWith(Sketch value, $Res Function(Sketch) _then) = _$SketchCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String title, String? description,@TimestampOrNowConverter() DateTime lastModified, String userId, List<String> tags,@JsonKey(unknownEnumValue: SketchStatus.active) SketchStatus status,@JsonKey(includeIfNull: false) String? backgroundUrl
});




}
/// @nodoc
class _$SketchCopyWithImpl<$Res>
    implements $SketchCopyWith<$Res> {
  _$SketchCopyWithImpl(this._self, this._then);

  final Sketch _self;
  final $Res Function(Sketch) _then;

/// Create a copy of Sketch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? lastModified = null,Object? userId = null,Object? tags = null,Object? status = null,Object? backgroundUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SketchStatus,backgroundUrl: freezed == backgroundUrl ? _self.backgroundUrl : backgroundUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Sketch].
extension SketchPatterns on Sketch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sketch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sketch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sketch value)  $default,){
final _that = this;
switch (_that) {
case _Sketch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sketch value)?  $default,){
final _that = this;
switch (_that) {
case _Sketch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String title,  String? description, @TimestampOrNowConverter()  DateTime lastModified,  String userId,  List<String> tags, @JsonKey(unknownEnumValue: SketchStatus.active)  SketchStatus status, @JsonKey(includeIfNull: false)  String? backgroundUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sketch() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lastModified,_that.userId,_that.tags,_that.status,_that.backgroundUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String title,  String? description, @TimestampOrNowConverter()  DateTime lastModified,  String userId,  List<String> tags, @JsonKey(unknownEnumValue: SketchStatus.active)  SketchStatus status, @JsonKey(includeIfNull: false)  String? backgroundUrl)  $default,) {final _that = this;
switch (_that) {
case _Sketch():
return $default(_that.id,_that.title,_that.description,_that.lastModified,_that.userId,_that.tags,_that.status,_that.backgroundUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String title,  String? description, @TimestampOrNowConverter()  DateTime lastModified,  String userId,  List<String> tags, @JsonKey(unknownEnumValue: SketchStatus.active)  SketchStatus status, @JsonKey(includeIfNull: false)  String? backgroundUrl)?  $default,) {final _that = this;
switch (_that) {
case _Sketch() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lastModified,_that.userId,_that.tags,_that.status,_that.backgroundUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sketch implements Sketch {
  const _Sketch({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', required this.title, this.description, @TimestampOrNowConverter() required this.lastModified, required this.userId, final  List<String> tags = const <String>[], @JsonKey(unknownEnumValue: SketchStatus.active) this.status = SketchStatus.active, @JsonKey(includeIfNull: false) this.backgroundUrl}): _tags = tags;
  factory _Sketch.fromJson(Map<String, dynamic> json) => _$SketchFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String title;
@override final  String? description;
@override@TimestampOrNowConverter() final  DateTime lastModified;
@override final  String userId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(unknownEnumValue: SketchStatus.active) final  SketchStatus status;
@override@JsonKey(includeIfNull: false) final  String? backgroundUrl;

/// Create a copy of Sketch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SketchCopyWith<_Sketch> get copyWith => __$SketchCopyWithImpl<_Sketch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SketchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sketch&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.backgroundUrl, backgroundUrl) || other.backgroundUrl == backgroundUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,lastModified,userId,const DeepCollectionEquality().hash(_tags),status,backgroundUrl);

@override
String toString() {
  return 'Sketch(id: $id, title: $title, description: $description, lastModified: $lastModified, userId: $userId, tags: $tags, status: $status, backgroundUrl: $backgroundUrl)';
}


}

/// @nodoc
abstract mixin class _$SketchCopyWith<$Res> implements $SketchCopyWith<$Res> {
  factory _$SketchCopyWith(_Sketch value, $Res Function(_Sketch) _then) = __$SketchCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String title, String? description,@TimestampOrNowConverter() DateTime lastModified, String userId, List<String> tags,@JsonKey(unknownEnumValue: SketchStatus.active) SketchStatus status,@JsonKey(includeIfNull: false) String? backgroundUrl
});




}
/// @nodoc
class __$SketchCopyWithImpl<$Res>
    implements _$SketchCopyWith<$Res> {
  __$SketchCopyWithImpl(this._self, this._then);

  final _Sketch _self;
  final $Res Function(_Sketch) _then;

/// Create a copy of Sketch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? lastModified = null,Object? userId = null,Object? tags = null,Object? status = null,Object? backgroundUrl = freezed,}) {
  return _then(_Sketch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SketchStatus,backgroundUrl: freezed == backgroundUrl ? _self.backgroundUrl : backgroundUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
