// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClubTeam {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String get name; String? get description;@NullableTimestampConverter() DateTime? get createdAt;
/// Create a copy of ClubTeam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubTeamCopyWith<ClubTeam> get copyWith => _$ClubTeamCopyWithImpl<ClubTeam>(this as ClubTeam, _$identity);

  /// Serializes this ClubTeam to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubTeam&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,createdAt);

@override
String toString() {
  return 'ClubTeam(id: $id, name: $name, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClubTeamCopyWith<$Res>  {
  factory $ClubTeamCopyWith(ClubTeam value, $Res Function(ClubTeam) _then) = _$ClubTeamCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String name, String? description,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ClubTeamCopyWithImpl<$Res>
    implements $ClubTeamCopyWith<$Res> {
  _$ClubTeamCopyWithImpl(this._self, this._then);

  final ClubTeam _self;
  final $Res Function(ClubTeam) _then;

/// Create a copy of ClubTeam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubTeam].
extension ClubTeamPatterns on ClubTeam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubTeam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubTeam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubTeam value)  $default,){
final _that = this;
switch (_that) {
case _ClubTeam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubTeam value)?  $default,){
final _that = this;
switch (_that) {
case _ClubTeam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String name,  String? description, @NullableTimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubTeam() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String name,  String? description, @NullableTimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ClubTeam():
return $default(_that.id,_that.name,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String name,  String? description, @NullableTimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubTeam() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubTeam implements ClubTeam {
  const _ClubTeam({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', required this.name, this.description, @NullableTimestampConverter() this.createdAt});
  factory _ClubTeam.fromJson(Map<String, dynamic> json) => _$ClubTeamFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String name;
@override final  String? description;
@override@NullableTimestampConverter() final  DateTime? createdAt;

/// Create a copy of ClubTeam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubTeamCopyWith<_ClubTeam> get copyWith => __$ClubTeamCopyWithImpl<_ClubTeam>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubTeamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubTeam&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,createdAt);

@override
String toString() {
  return 'ClubTeam(id: $id, name: $name, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClubTeamCopyWith<$Res> implements $ClubTeamCopyWith<$Res> {
  factory _$ClubTeamCopyWith(_ClubTeam value, $Res Function(_ClubTeam) _then) = __$ClubTeamCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String name, String? description,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ClubTeamCopyWithImpl<$Res>
    implements _$ClubTeamCopyWith<$Res> {
  __$ClubTeamCopyWithImpl(this._self, this._then);

  final _ClubTeam _self;
  final $Res Function(_ClubTeam) _then;

/// Create a copy of ClubTeam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,}) {
  return _then(_ClubTeam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
