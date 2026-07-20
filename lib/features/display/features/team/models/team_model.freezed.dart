// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Team {

 TeamColor get teamColor; List<Player> get front; List<Player> get center; List<Player> get wing; List<Player> get goalie;
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamCopyWith<Team> get copyWith => _$TeamCopyWithImpl<Team>(this as Team, _$identity);

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Team&&(identical(other.teamColor, teamColor) || other.teamColor == teamColor)&&const DeepCollectionEquality().equals(other.front, front)&&const DeepCollectionEquality().equals(other.center, center)&&const DeepCollectionEquality().equals(other.wing, wing)&&const DeepCollectionEquality().equals(other.goalie, goalie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamColor,const DeepCollectionEquality().hash(front),const DeepCollectionEquality().hash(center),const DeepCollectionEquality().hash(wing),const DeepCollectionEquality().hash(goalie));

@override
String toString() {
  return 'Team(teamColor: $teamColor, front: $front, center: $center, wing: $wing, goalie: $goalie)';
}


}

/// @nodoc
abstract mixin class $TeamCopyWith<$Res>  {
  factory $TeamCopyWith(Team value, $Res Function(Team) _then) = _$TeamCopyWithImpl;
@useResult
$Res call({
 TeamColor teamColor, List<Player> front, List<Player> center, List<Player> wing, List<Player> goalie
});




}
/// @nodoc
class _$TeamCopyWithImpl<$Res>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._self, this._then);

  final Team _self;
  final $Res Function(Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamColor = null,Object? front = null,Object? center = null,Object? wing = null,Object? goalie = null,}) {
  return _then(_self.copyWith(
teamColor: null == teamColor ? _self.teamColor : teamColor // ignore: cast_nullable_to_non_nullable
as TeamColor,front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as List<Player>,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as List<Player>,wing: null == wing ? _self.wing : wing // ignore: cast_nullable_to_non_nullable
as List<Player>,goalie: null == goalie ? _self.goalie : goalie // ignore: cast_nullable_to_non_nullable
as List<Player>,
  ));
}

}


/// Adds pattern-matching-related methods to [Team].
extension TeamPatterns on Team {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Team value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Team value)  $default,){
final _that = this;
switch (_that) {
case _Team():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Team value)?  $default,){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TeamColor teamColor,  List<Player> front,  List<Player> center,  List<Player> wing,  List<Player> goalie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.teamColor,_that.front,_that.center,_that.wing,_that.goalie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TeamColor teamColor,  List<Player> front,  List<Player> center,  List<Player> wing,  List<Player> goalie)  $default,) {final _that = this;
switch (_that) {
case _Team():
return $default(_that.teamColor,_that.front,_that.center,_that.wing,_that.goalie);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TeamColor teamColor,  List<Player> front,  List<Player> center,  List<Player> wing,  List<Player> goalie)?  $default,) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.teamColor,_that.front,_that.center,_that.wing,_that.goalie);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Team implements Team {
  const _Team({required this.teamColor, required final  List<Player> front, required final  List<Player> center, required final  List<Player> wing, required final  List<Player> goalie}): _front = front,_center = center,_wing = wing,_goalie = goalie;
  factory _Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

@override final  TeamColor teamColor;
 final  List<Player> _front;
@override List<Player> get front {
  if (_front is EqualUnmodifiableListView) return _front;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_front);
}

 final  List<Player> _center;
@override List<Player> get center {
  if (_center is EqualUnmodifiableListView) return _center;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_center);
}

 final  List<Player> _wing;
@override List<Player> get wing {
  if (_wing is EqualUnmodifiableListView) return _wing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wing);
}

 final  List<Player> _goalie;
@override List<Player> get goalie {
  if (_goalie is EqualUnmodifiableListView) return _goalie;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goalie);
}


/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamCopyWith<_Team> get copyWith => __$TeamCopyWithImpl<_Team>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Team&&(identical(other.teamColor, teamColor) || other.teamColor == teamColor)&&const DeepCollectionEquality().equals(other._front, _front)&&const DeepCollectionEquality().equals(other._center, _center)&&const DeepCollectionEquality().equals(other._wing, _wing)&&const DeepCollectionEquality().equals(other._goalie, _goalie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamColor,const DeepCollectionEquality().hash(_front),const DeepCollectionEquality().hash(_center),const DeepCollectionEquality().hash(_wing),const DeepCollectionEquality().hash(_goalie));

@override
String toString() {
  return 'Team(teamColor: $teamColor, front: $front, center: $center, wing: $wing, goalie: $goalie)';
}


}

/// @nodoc
abstract mixin class _$TeamCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$TeamCopyWith(_Team value, $Res Function(_Team) _then) = __$TeamCopyWithImpl;
@override @useResult
$Res call({
 TeamColor teamColor, List<Player> front, List<Player> center, List<Player> wing, List<Player> goalie
});




}
/// @nodoc
class __$TeamCopyWithImpl<$Res>
    implements _$TeamCopyWith<$Res> {
  __$TeamCopyWithImpl(this._self, this._then);

  final _Team _self;
  final $Res Function(_Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamColor = null,Object? front = null,Object? center = null,Object? wing = null,Object? goalie = null,}) {
  return _then(_Team(
teamColor: null == teamColor ? _self.teamColor : teamColor // ignore: cast_nullable_to_non_nullable
as TeamColor,front: null == front ? _self._front : front // ignore: cast_nullable_to_non_nullable
as List<Player>,center: null == center ? _self._center : center // ignore: cast_nullable_to_non_nullable
as List<Player>,wing: null == wing ? _self._wing : wing // ignore: cast_nullable_to_non_nullable
as List<Player>,goalie: null == goalie ? _self._goalie : goalie // ignore: cast_nullable_to_non_nullable
as List<Player>,
  ));
}


}

// dart format on
