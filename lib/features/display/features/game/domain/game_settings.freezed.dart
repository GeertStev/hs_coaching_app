// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameSettings {

 int get blackScore; int get whiteScore;
/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSettingsCopyWith<GameSettings> get copyWith => _$GameSettingsCopyWithImpl<GameSettings>(this as GameSettings, _$identity);

  /// Serializes this GameSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSettings&&(identical(other.blackScore, blackScore) || other.blackScore == blackScore)&&(identical(other.whiteScore, whiteScore) || other.whiteScore == whiteScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blackScore,whiteScore);

@override
String toString() {
  return 'GameSettings(blackScore: $blackScore, whiteScore: $whiteScore)';
}


}

/// @nodoc
abstract mixin class $GameSettingsCopyWith<$Res>  {
  factory $GameSettingsCopyWith(GameSettings value, $Res Function(GameSettings) _then) = _$GameSettingsCopyWithImpl;
@useResult
$Res call({
 int blackScore, int whiteScore
});




}
/// @nodoc
class _$GameSettingsCopyWithImpl<$Res>
    implements $GameSettingsCopyWith<$Res> {
  _$GameSettingsCopyWithImpl(this._self, this._then);

  final GameSettings _self;
  final $Res Function(GameSettings) _then;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blackScore = null,Object? whiteScore = null,}) {
  return _then(_self.copyWith(
blackScore: null == blackScore ? _self.blackScore : blackScore // ignore: cast_nullable_to_non_nullable
as int,whiteScore: null == whiteScore ? _self.whiteScore : whiteScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSettings].
extension GameSettingsPatterns on GameSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSettings value)  $default,){
final _that = this;
switch (_that) {
case _GameSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSettings value)?  $default,){
final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int blackScore,  int whiteScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
return $default(_that.blackScore,_that.whiteScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int blackScore,  int whiteScore)  $default,) {final _that = this;
switch (_that) {
case _GameSettings():
return $default(_that.blackScore,_that.whiteScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int blackScore,  int whiteScore)?  $default,) {final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
return $default(_that.blackScore,_that.whiteScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameSettings implements GameSettings {
  const _GameSettings({this.blackScore = 0, this.whiteScore = 0});
  factory _GameSettings.fromJson(Map<String, dynamic> json) => _$GameSettingsFromJson(json);

@override@JsonKey() final  int blackScore;
@override@JsonKey() final  int whiteScore;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSettingsCopyWith<_GameSettings> get copyWith => __$GameSettingsCopyWithImpl<_GameSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSettings&&(identical(other.blackScore, blackScore) || other.blackScore == blackScore)&&(identical(other.whiteScore, whiteScore) || other.whiteScore == whiteScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blackScore,whiteScore);

@override
String toString() {
  return 'GameSettings(blackScore: $blackScore, whiteScore: $whiteScore)';
}


}

/// @nodoc
abstract mixin class _$GameSettingsCopyWith<$Res> implements $GameSettingsCopyWith<$Res> {
  factory _$GameSettingsCopyWith(_GameSettings value, $Res Function(_GameSettings) _then) = __$GameSettingsCopyWithImpl;
@override @useResult
$Res call({
 int blackScore, int whiteScore
});




}
/// @nodoc
class __$GameSettingsCopyWithImpl<$Res>
    implements _$GameSettingsCopyWith<$Res> {
  __$GameSettingsCopyWithImpl(this._self, this._then);

  final _GameSettings _self;
  final $Res Function(_GameSettings) _then;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blackScore = null,Object? whiteScore = null,}) {
  return _then(_GameSettings(
blackScore: null == blackScore ? _self.blackScore : blackScore // ignore: cast_nullable_to_non_nullable
as int,whiteScore: null == whiteScore ? _self.whiteScore : whiteScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
