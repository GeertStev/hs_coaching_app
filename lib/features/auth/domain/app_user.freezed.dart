// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

@JsonKey(includeFromJson: false, includeToJson: false) String get uid; String get firstName; String get lastName; String? get email; String? get picture; String get role;@NullableTimestampConverter() DateTime? get lastLogin; List<PersonalInfo> get personalInfo;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&const DeepCollectionEquality().equals(other.personalInfo, personalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,email,picture,role,lastLogin,const DeepCollectionEquality().hash(personalInfo));

@override
String toString() {
  return 'AppUser(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, picture: $picture, role: $role, lastLogin: $lastLogin, personalInfo: $personalInfo)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String uid, String firstName, String lastName, String? email, String? picture, String role,@NullableTimestampConverter() DateTime? lastLogin, List<PersonalInfo> personalInfo
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? email = freezed,Object? picture = freezed,Object? role = null,Object? lastLogin = freezed,Object? personalInfo = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as DateTime?,personalInfo: null == personalInfo ? _self.personalInfo : personalInfo // ignore: cast_nullable_to_non_nullable
as List<PersonalInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String uid,  String firstName,  String lastName,  String? email,  String? picture,  String role, @NullableTimestampConverter()  DateTime? lastLogin,  List<PersonalInfo> personalInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.picture,_that.role,_that.lastLogin,_that.personalInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String uid,  String firstName,  String lastName,  String? email,  String? picture,  String role, @NullableTimestampConverter()  DateTime? lastLogin,  List<PersonalInfo> personalInfo)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.picture,_that.role,_that.lastLogin,_that.personalInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String uid,  String firstName,  String lastName,  String? email,  String? picture,  String role, @NullableTimestampConverter()  DateTime? lastLogin,  List<PersonalInfo> personalInfo)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.email,_that.picture,_that.role,_that.lastLogin,_that.personalInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({@JsonKey(includeFromJson: false, includeToJson: false) this.uid = '', required this.firstName, required this.lastName, this.email, this.picture, this.role = 'user', @NullableTimestampConverter() this.lastLogin, final  List<PersonalInfo> personalInfo = const []}): _personalInfo = personalInfo,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String uid;
@override final  String firstName;
@override final  String lastName;
@override final  String? email;
@override final  String? picture;
@override@JsonKey() final  String role;
@override@NullableTimestampConverter() final  DateTime? lastLogin;
 final  List<PersonalInfo> _personalInfo;
@override@JsonKey() List<PersonalInfo> get personalInfo {
  if (_personalInfo is EqualUnmodifiableListView) return _personalInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personalInfo);
}


/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&const DeepCollectionEquality().equals(other._personalInfo, _personalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,email,picture,role,lastLogin,const DeepCollectionEquality().hash(_personalInfo));

@override
String toString() {
  return 'AppUser(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, picture: $picture, role: $role, lastLogin: $lastLogin, personalInfo: $personalInfo)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String uid, String firstName, String lastName, String? email, String? picture, String role,@NullableTimestampConverter() DateTime? lastLogin, List<PersonalInfo> personalInfo
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? email = freezed,Object? picture = freezed,Object? role = null,Object? lastLogin = freezed,Object? personalInfo = null,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as DateTime?,personalInfo: null == personalInfo ? _self._personalInfo : personalInfo // ignore: cast_nullable_to_non_nullable
as List<PersonalInfo>,
  ));
}


}


/// @nodoc
mixin _$PersonalInfo {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String? get street; String? get number; String? get zipCode; String? get city; String? get country; String? get phoneNumber; String get email;@NullableTimestampConverter() DateTime? get birthday; String? get gender; List<EmergencyContact> get emergencyContacts;
/// Create a copy of PersonalInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalInfoCopyWith<PersonalInfo> get copyWith => _$PersonalInfoCopyWithImpl<PersonalInfo>(this as PersonalInfo, _$identity);

  /// Serializes this PersonalInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.emergencyContacts, emergencyContacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,street,number,zipCode,city,country,phoneNumber,email,birthday,gender,const DeepCollectionEquality().hash(emergencyContacts));

@override
String toString() {
  return 'PersonalInfo(id: $id, street: $street, number: $number, zipCode: $zipCode, city: $city, country: $country, phoneNumber: $phoneNumber, email: $email, birthday: $birthday, gender: $gender, emergencyContacts: $emergencyContacts)';
}


}

/// @nodoc
abstract mixin class $PersonalInfoCopyWith<$Res>  {
  factory $PersonalInfoCopyWith(PersonalInfo value, $Res Function(PersonalInfo) _then) = _$PersonalInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? street, String? number, String? zipCode, String? city, String? country, String? phoneNumber, String email,@NullableTimestampConverter() DateTime? birthday, String? gender, List<EmergencyContact> emergencyContacts
});




}
/// @nodoc
class _$PersonalInfoCopyWithImpl<$Res>
    implements $PersonalInfoCopyWith<$Res> {
  _$PersonalInfoCopyWithImpl(this._self, this._then);

  final PersonalInfo _self;
  final $Res Function(PersonalInfo) _then;

/// Create a copy of PersonalInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? street = freezed,Object? number = freezed,Object? zipCode = freezed,Object? city = freezed,Object? country = freezed,Object? phoneNumber = freezed,Object? email = null,Object? birthday = freezed,Object? gender = freezed,Object? emergencyContacts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContacts: null == emergencyContacts ? _self.emergencyContacts : emergencyContacts // ignore: cast_nullable_to_non_nullable
as List<EmergencyContact>,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalInfo].
extension PersonalInfoPatterns on PersonalInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalInfo value)  $default,){
final _that = this;
switch (_that) {
case _PersonalInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? street,  String? number,  String? zipCode,  String? city,  String? country,  String? phoneNumber,  String email, @NullableTimestampConverter()  DateTime? birthday,  String? gender,  List<EmergencyContact> emergencyContacts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalInfo() when $default != null:
return $default(_that.id,_that.street,_that.number,_that.zipCode,_that.city,_that.country,_that.phoneNumber,_that.email,_that.birthday,_that.gender,_that.emergencyContacts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? street,  String? number,  String? zipCode,  String? city,  String? country,  String? phoneNumber,  String email, @NullableTimestampConverter()  DateTime? birthday,  String? gender,  List<EmergencyContact> emergencyContacts)  $default,) {final _that = this;
switch (_that) {
case _PersonalInfo():
return $default(_that.id,_that.street,_that.number,_that.zipCode,_that.city,_that.country,_that.phoneNumber,_that.email,_that.birthday,_that.gender,_that.emergencyContacts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String? street,  String? number,  String? zipCode,  String? city,  String? country,  String? phoneNumber,  String email, @NullableTimestampConverter()  DateTime? birthday,  String? gender,  List<EmergencyContact> emergencyContacts)?  $default,) {final _that = this;
switch (_that) {
case _PersonalInfo() when $default != null:
return $default(_that.id,_that.street,_that.number,_that.zipCode,_that.city,_that.country,_that.phoneNumber,_that.email,_that.birthday,_that.gender,_that.emergencyContacts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalInfo implements PersonalInfo {
  const _PersonalInfo({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', this.street, this.number, this.zipCode, this.city, this.country, this.phoneNumber, required this.email, @NullableTimestampConverter() this.birthday, this.gender, final  List<EmergencyContact> emergencyContacts = const []}): _emergencyContacts = emergencyContacts;
  factory _PersonalInfo.fromJson(Map<String, dynamic> json) => _$PersonalInfoFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String? street;
@override final  String? number;
@override final  String? zipCode;
@override final  String? city;
@override final  String? country;
@override final  String? phoneNumber;
@override final  String email;
@override@NullableTimestampConverter() final  DateTime? birthday;
@override final  String? gender;
 final  List<EmergencyContact> _emergencyContacts;
@override@JsonKey() List<EmergencyContact> get emergencyContacts {
  if (_emergencyContacts is EqualUnmodifiableListView) return _emergencyContacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emergencyContacts);
}


/// Create a copy of PersonalInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalInfoCopyWith<_PersonalInfo> get copyWith => __$PersonalInfoCopyWithImpl<_PersonalInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._emergencyContacts, _emergencyContacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,street,number,zipCode,city,country,phoneNumber,email,birthday,gender,const DeepCollectionEquality().hash(_emergencyContacts));

@override
String toString() {
  return 'PersonalInfo(id: $id, street: $street, number: $number, zipCode: $zipCode, city: $city, country: $country, phoneNumber: $phoneNumber, email: $email, birthday: $birthday, gender: $gender, emergencyContacts: $emergencyContacts)';
}


}

/// @nodoc
abstract mixin class _$PersonalInfoCopyWith<$Res> implements $PersonalInfoCopyWith<$Res> {
  factory _$PersonalInfoCopyWith(_PersonalInfo value, $Res Function(_PersonalInfo) _then) = __$PersonalInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String? street, String? number, String? zipCode, String? city, String? country, String? phoneNumber, String email,@NullableTimestampConverter() DateTime? birthday, String? gender, List<EmergencyContact> emergencyContacts
});




}
/// @nodoc
class __$PersonalInfoCopyWithImpl<$Res>
    implements _$PersonalInfoCopyWith<$Res> {
  __$PersonalInfoCopyWithImpl(this._self, this._then);

  final _PersonalInfo _self;
  final $Res Function(_PersonalInfo) _then;

/// Create a copy of PersonalInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? street = freezed,Object? number = freezed,Object? zipCode = freezed,Object? city = freezed,Object? country = freezed,Object? phoneNumber = freezed,Object? email = null,Object? birthday = freezed,Object? gender = freezed,Object? emergencyContacts = null,}) {
  return _then(_PersonalInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContacts: null == emergencyContacts ? _self._emergencyContacts : emergencyContacts // ignore: cast_nullable_to_non_nullable
as List<EmergencyContact>,
  ));
}


}


/// @nodoc
mixin _$EmergencyContact {

@JsonKey(includeFromJson: false, includeToJson: false) String get id; String get firstName; String get lastName; String get phoneNumber;
/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyContactCopyWith<EmergencyContact> get copyWith => _$EmergencyContactCopyWithImpl<EmergencyContact>(this as EmergencyContact, _$identity);

  /// Serializes this EmergencyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,phoneNumber);

@override
String toString() {
  return 'EmergencyContact(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $EmergencyContactCopyWith<$Res>  {
  factory $EmergencyContactCopyWith(EmergencyContact value, $Res Function(EmergencyContact) _then) = _$EmergencyContactCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String firstName, String lastName, String phoneNumber
});




}
/// @nodoc
class _$EmergencyContactCopyWithImpl<$Res>
    implements $EmergencyContactCopyWith<$Res> {
  _$EmergencyContactCopyWithImpl(this._self, this._then);

  final EmergencyContact _self;
  final $Res Function(EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phoneNumber = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyContact].
extension EmergencyContactPatterns on EmergencyContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyContact value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyContact value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String firstName,  String lastName,  String phoneNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String firstName,  String lastName,  String phoneNumber)  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact():
return $default(_that.id,_that.firstName,_that.lastName,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  String id,  String firstName,  String lastName,  String phoneNumber)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phoneNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyContact implements EmergencyContact {
  const _EmergencyContact({@JsonKey(includeFromJson: false, includeToJson: false) this.id = '', required this.firstName, required this.lastName, required this.phoneNumber});
  factory _EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);

@override@JsonKey(includeFromJson: false, includeToJson: false) final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String phoneNumber;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyContactCopyWith<_EmergencyContact> get copyWith => __$EmergencyContactCopyWithImpl<_EmergencyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,phoneNumber);

@override
String toString() {
  return 'EmergencyContact(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class _$EmergencyContactCopyWith<$Res> implements $EmergencyContactCopyWith<$Res> {
  factory _$EmergencyContactCopyWith(_EmergencyContact value, $Res Function(_EmergencyContact) _then) = __$EmergencyContactCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) String id, String firstName, String lastName, String phoneNumber
});




}
/// @nodoc
class __$EmergencyContactCopyWithImpl<$Res>
    implements _$EmergencyContactCopyWith<$Res> {
  __$EmergencyContactCopyWithImpl(this._self, this._then);

  final _EmergencyContact _self;
  final $Res Function(_EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phoneNumber = null,}) {
  return _then(_EmergencyContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
