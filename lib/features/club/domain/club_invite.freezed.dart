// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClubInvite {

/// De code is tevens de document-id.
@JsonKey(includeFromJson: false, includeToJson: false) String get code; String get clubId;@JsonKey(unknownEnumValue: ClubRole.player) ClubRole get role; String get createdByUid; bool get active;@NullableTimestampConverter() DateTime? get createdAt;@NullableTimestampConverter() DateTime? get expiresAt;
/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubInviteCopyWith<ClubInvite> get copyWith => _$ClubInviteCopyWithImpl<ClubInvite>(this as ClubInvite, _$identity);

  /// Serializes this ClubInvite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubInvite&&(identical(other.code, code) || other.code == code)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,clubId,role,createdByUid,active,createdAt,expiresAt);

@override
String toString() {
  return 'ClubInvite(code: $code, clubId: $clubId, role: $role, createdByUid: $createdByUid, active: $active, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ClubInviteCopyWith<$Res>  {
  factory $ClubInviteCopyWith(ClubInvite value, $Res Function(ClubInvite) _then) = _$ClubInviteCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String code, String clubId,@JsonKey(unknownEnumValue: ClubRole.player) ClubRole role, String createdByUid, bool active,@NullableTimestampConverter() DateTime? createdAt,@NullableTimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class _$ClubInviteCopyWithImpl<$Res>
    implements $ClubInviteCopyWith<$Res> {
  _$ClubInviteCopyWithImpl(this._self, this._then);

  final ClubInvite _self;
  final $Res Function(ClubInvite) _then;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? clubId = null,Object? role = null,Object? createdByUid = null,Object? active = null,Object? createdAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubInvite].
extension ClubInvitePatterns on ClubInvite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubInvite value)  $default,){
final _that = this;
switch (_that) {
case _ClubInvite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubInvite value)?  $default,){
final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String code,  String clubId, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role,  String createdByUid,  bool active, @NullableTimestampConverter()  DateTime? createdAt, @NullableTimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
return $default(_that.code,_that.clubId,_that.role,_that.createdByUid,_that.active,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String code,  String clubId, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role,  String createdByUid,  bool active, @NullableTimestampConverter()  DateTime? createdAt, @NullableTimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ClubInvite():
return $default(_that.code,_that.clubId,_that.role,_that.createdByUid,_that.active,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String code,  String clubId, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role,  String createdByUid,  bool active, @NullableTimestampConverter()  DateTime? createdAt, @NullableTimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
return $default(_that.code,_that.clubId,_that.role,_that.createdByUid,_that.active,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubInvite extends ClubInvite {
  const _ClubInvite({@JsonKey(includeFromJson: false, includeToJson: false) this.code = '', required this.clubId, @JsonKey(unknownEnumValue: ClubRole.player) this.role = ClubRole.player, required this.createdByUid, this.active = true, @NullableTimestampConverter() this.createdAt, @NullableTimestampConverter() this.expiresAt}): super._();
  factory _ClubInvite.fromJson(Map<String, dynamic> json) => _$ClubInviteFromJson(json);

/// De code is tevens de document-id.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  String code;
@override final  String clubId;
@override@JsonKey(unknownEnumValue: ClubRole.player) final  ClubRole role;
@override final  String createdByUid;
@override@JsonKey() final  bool active;
@override@NullableTimestampConverter() final  DateTime? createdAt;
@override@NullableTimestampConverter() final  DateTime? expiresAt;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubInviteCopyWith<_ClubInvite> get copyWith => __$ClubInviteCopyWithImpl<_ClubInvite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubInviteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubInvite&&(identical(other.code, code) || other.code == code)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,clubId,role,createdByUid,active,createdAt,expiresAt);

@override
String toString() {
  return 'ClubInvite(code: $code, clubId: $clubId, role: $role, createdByUid: $createdByUid, active: $active, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ClubInviteCopyWith<$Res> implements $ClubInviteCopyWith<$Res> {
  factory _$ClubInviteCopyWith(_ClubInvite value, $Res Function(_ClubInvite) _then) = __$ClubInviteCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String code, String clubId,@JsonKey(unknownEnumValue: ClubRole.player) ClubRole role, String createdByUid, bool active,@NullableTimestampConverter() DateTime? createdAt,@NullableTimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class __$ClubInviteCopyWithImpl<$Res>
    implements _$ClubInviteCopyWith<$Res> {
  __$ClubInviteCopyWithImpl(this._self, this._then);

  final _ClubInvite _self;
  final $Res Function(_ClubInvite) _then;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? clubId = null,Object? role = null,Object? createdByUid = null,Object? active = null,Object? createdAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_ClubInvite(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
