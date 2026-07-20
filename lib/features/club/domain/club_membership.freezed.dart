// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClubMembership {

 String get uid; String get clubId; String get firstName; String get lastName; String? get picture;@JsonKey(unknownEnumValue: ClubRole.player) ClubRole get role;@JsonKey(unknownEnumValue: MembershipStatus.pending) MembershipStatus get status; List<String> get teamIds;/// Code waarmee dit lid via een uitnodiging is toegetreden (indien van
/// toepassing) — wordt door de security rules gevalideerd.
 String? get inviteCode;@NullableTimestampConverter() DateTime? get requestedAt;@NullableTimestampConverter() DateTime? get joinedAt;
/// Create a copy of ClubMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubMembershipCopyWith<ClubMembership> get copyWith => _$ClubMembershipCopyWithImpl<ClubMembership>(this as ClubMembership, _$identity);

  /// Serializes this ClubMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubMembership&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.teamIds, teamIds)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,clubId,firstName,lastName,picture,role,status,const DeepCollectionEquality().hash(teamIds),inviteCode,requestedAt,joinedAt);

@override
String toString() {
  return 'ClubMembership(uid: $uid, clubId: $clubId, firstName: $firstName, lastName: $lastName, picture: $picture, role: $role, status: $status, teamIds: $teamIds, inviteCode: $inviteCode, requestedAt: $requestedAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $ClubMembershipCopyWith<$Res>  {
  factory $ClubMembershipCopyWith(ClubMembership value, $Res Function(ClubMembership) _then) = _$ClubMembershipCopyWithImpl;
@useResult
$Res call({
 String uid, String clubId, String firstName, String lastName, String? picture,@JsonKey(unknownEnumValue: ClubRole.player) ClubRole role,@JsonKey(unknownEnumValue: MembershipStatus.pending) MembershipStatus status, List<String> teamIds, String? inviteCode,@NullableTimestampConverter() DateTime? requestedAt,@NullableTimestampConverter() DateTime? joinedAt
});




}
/// @nodoc
class _$ClubMembershipCopyWithImpl<$Res>
    implements $ClubMembershipCopyWith<$Res> {
  _$ClubMembershipCopyWithImpl(this._self, this._then);

  final ClubMembership _self;
  final $Res Function(ClubMembership) _then;

/// Create a copy of ClubMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? clubId = null,Object? firstName = null,Object? lastName = null,Object? picture = freezed,Object? role = null,Object? status = null,Object? teamIds = null,Object? inviteCode = freezed,Object? requestedAt = freezed,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,teamIds: null == teamIds ? _self.teamIds : teamIds // ignore: cast_nullable_to_non_nullable
as List<String>,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubMembership].
extension ClubMembershipPatterns on ClubMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubMembership value)  $default,){
final _that = this;
switch (_that) {
case _ClubMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubMembership value)?  $default,){
final _that = this;
switch (_that) {
case _ClubMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String clubId,  String firstName,  String lastName,  String? picture, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role, @JsonKey(unknownEnumValue: MembershipStatus.pending)  MembershipStatus status,  List<String> teamIds,  String? inviteCode, @NullableTimestampConverter()  DateTime? requestedAt, @NullableTimestampConverter()  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubMembership() when $default != null:
return $default(_that.uid,_that.clubId,_that.firstName,_that.lastName,_that.picture,_that.role,_that.status,_that.teamIds,_that.inviteCode,_that.requestedAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String clubId,  String firstName,  String lastName,  String? picture, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role, @JsonKey(unknownEnumValue: MembershipStatus.pending)  MembershipStatus status,  List<String> teamIds,  String? inviteCode, @NullableTimestampConverter()  DateTime? requestedAt, @NullableTimestampConverter()  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _ClubMembership():
return $default(_that.uid,_that.clubId,_that.firstName,_that.lastName,_that.picture,_that.role,_that.status,_that.teamIds,_that.inviteCode,_that.requestedAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String clubId,  String firstName,  String lastName,  String? picture, @JsonKey(unknownEnumValue: ClubRole.player)  ClubRole role, @JsonKey(unknownEnumValue: MembershipStatus.pending)  MembershipStatus status,  List<String> teamIds,  String? inviteCode, @NullableTimestampConverter()  DateTime? requestedAt, @NullableTimestampConverter()  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubMembership() when $default != null:
return $default(_that.uid,_that.clubId,_that.firstName,_that.lastName,_that.picture,_that.role,_that.status,_that.teamIds,_that.inviteCode,_that.requestedAt,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubMembership extends ClubMembership {
  const _ClubMembership({required this.uid, required this.clubId, required this.firstName, required this.lastName, this.picture, @JsonKey(unknownEnumValue: ClubRole.player) this.role = ClubRole.player, @JsonKey(unknownEnumValue: MembershipStatus.pending) this.status = MembershipStatus.pending, final  List<String> teamIds = const [], this.inviteCode, @NullableTimestampConverter() this.requestedAt, @NullableTimestampConverter() this.joinedAt}): _teamIds = teamIds,super._();
  factory _ClubMembership.fromJson(Map<String, dynamic> json) => _$ClubMembershipFromJson(json);

@override final  String uid;
@override final  String clubId;
@override final  String firstName;
@override final  String lastName;
@override final  String? picture;
@override@JsonKey(unknownEnumValue: ClubRole.player) final  ClubRole role;
@override@JsonKey(unknownEnumValue: MembershipStatus.pending) final  MembershipStatus status;
 final  List<String> _teamIds;
@override@JsonKey() List<String> get teamIds {
  if (_teamIds is EqualUnmodifiableListView) return _teamIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamIds);
}

/// Code waarmee dit lid via een uitnodiging is toegetreden (indien van
/// toepassing) — wordt door de security rules gevalideerd.
@override final  String? inviteCode;
@override@NullableTimestampConverter() final  DateTime? requestedAt;
@override@NullableTimestampConverter() final  DateTime? joinedAt;

/// Create a copy of ClubMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubMembershipCopyWith<_ClubMembership> get copyWith => __$ClubMembershipCopyWithImpl<_ClubMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubMembership&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._teamIds, _teamIds)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,clubId,firstName,lastName,picture,role,status,const DeepCollectionEquality().hash(_teamIds),inviteCode,requestedAt,joinedAt);

@override
String toString() {
  return 'ClubMembership(uid: $uid, clubId: $clubId, firstName: $firstName, lastName: $lastName, picture: $picture, role: $role, status: $status, teamIds: $teamIds, inviteCode: $inviteCode, requestedAt: $requestedAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$ClubMembershipCopyWith<$Res> implements $ClubMembershipCopyWith<$Res> {
  factory _$ClubMembershipCopyWith(_ClubMembership value, $Res Function(_ClubMembership) _then) = __$ClubMembershipCopyWithImpl;
@override @useResult
$Res call({
 String uid, String clubId, String firstName, String lastName, String? picture,@JsonKey(unknownEnumValue: ClubRole.player) ClubRole role,@JsonKey(unknownEnumValue: MembershipStatus.pending) MembershipStatus status, List<String> teamIds, String? inviteCode,@NullableTimestampConverter() DateTime? requestedAt,@NullableTimestampConverter() DateTime? joinedAt
});




}
/// @nodoc
class __$ClubMembershipCopyWithImpl<$Res>
    implements _$ClubMembershipCopyWith<$Res> {
  __$ClubMembershipCopyWithImpl(this._self, this._then);

  final _ClubMembership _self;
  final $Res Function(_ClubMembership) _then;

/// Create a copy of ClubMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? clubId = null,Object? firstName = null,Object? lastName = null,Object? picture = freezed,Object? role = null,Object? status = null,Object? teamIds = null,Object? inviteCode = freezed,Object? requestedAt = freezed,Object? joinedAt = freezed,}) {
  return _then(_ClubMembership(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,teamIds: null == teamIds ? _self._teamIds : teamIds // ignore: cast_nullable_to_non_nullable
as List<String>,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
