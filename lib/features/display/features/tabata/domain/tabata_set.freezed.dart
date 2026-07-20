// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabata_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TabataSet {

/// Titel van de set (bv. "Onderwaters" of "Half onder half boven").
 String get title; int get workSeconds; int get restSeconds; int get rounds;/// Beeptest: elke werkronde duurt zoveel seconden korter dan de vorige.
 int get workDecrementSeconds;/// Rust ná deze set, vóór de volgende set. Genegeerd bij de laatste set.
 int get setRestSeconds;
/// Create a copy of TabataSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataSetCopyWith<TabataSet> get copyWith => _$TabataSetCopyWithImpl<TabataSet>(this as TabataSet, _$identity);

  /// Serializes this TabataSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataSet&&(identical(other.title, title) || other.title == title)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workDecrementSeconds, workDecrementSeconds) || other.workDecrementSeconds == workDecrementSeconds)&&(identical(other.setRestSeconds, setRestSeconds) || other.setRestSeconds == setRestSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,workSeconds,restSeconds,rounds,workDecrementSeconds,setRestSeconds);

@override
String toString() {
  return 'TabataSet(title: $title, workSeconds: $workSeconds, restSeconds: $restSeconds, rounds: $rounds, workDecrementSeconds: $workDecrementSeconds, setRestSeconds: $setRestSeconds)';
}


}

/// @nodoc
abstract mixin class $TabataSetCopyWith<$Res>  {
  factory $TabataSetCopyWith(TabataSet value, $Res Function(TabataSet) _then) = _$TabataSetCopyWithImpl;
@useResult
$Res call({
 String title, int workSeconds, int restSeconds, int rounds, int workDecrementSeconds, int setRestSeconds
});




}
/// @nodoc
class _$TabataSetCopyWithImpl<$Res>
    implements $TabataSetCopyWith<$Res> {
  _$TabataSetCopyWithImpl(this._self, this._then);

  final TabataSet _self;
  final $Res Function(TabataSet) _then;

/// Create a copy of TabataSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? workSeconds = null,Object? restSeconds = null,Object? rounds = null,Object? workDecrementSeconds = null,Object? setRestSeconds = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workDecrementSeconds: null == workDecrementSeconds ? _self.workDecrementSeconds : workDecrementSeconds // ignore: cast_nullable_to_non_nullable
as int,setRestSeconds: null == setRestSeconds ? _self.setRestSeconds : setRestSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TabataSet].
extension TabataSetPatterns on TabataSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TabataSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TabataSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TabataSet value)  $default,){
final _that = this;
switch (_that) {
case _TabataSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TabataSet value)?  $default,){
final _that = this;
switch (_that) {
case _TabataSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  int workSeconds,  int restSeconds,  int rounds,  int workDecrementSeconds,  int setRestSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TabataSet() when $default != null:
return $default(_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.workDecrementSeconds,_that.setRestSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  int workSeconds,  int restSeconds,  int rounds,  int workDecrementSeconds,  int setRestSeconds)  $default,) {final _that = this;
switch (_that) {
case _TabataSet():
return $default(_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.workDecrementSeconds,_that.setRestSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  int workSeconds,  int restSeconds,  int rounds,  int workDecrementSeconds,  int setRestSeconds)?  $default,) {final _that = this;
switch (_that) {
case _TabataSet() when $default != null:
return $default(_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.workDecrementSeconds,_that.setRestSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TabataSet extends TabataSet {
  const _TabataSet({this.title = '', this.workSeconds = 20, this.restSeconds = 10, this.rounds = 8, this.workDecrementSeconds = 0, this.setRestSeconds = 60}): super._();
  factory _TabataSet.fromJson(Map<String, dynamic> json) => _$TabataSetFromJson(json);

/// Titel van de set (bv. "Onderwaters" of "Half onder half boven").
@override@JsonKey() final  String title;
@override@JsonKey() final  int workSeconds;
@override@JsonKey() final  int restSeconds;
@override@JsonKey() final  int rounds;
/// Beeptest: elke werkronde duurt zoveel seconden korter dan de vorige.
@override@JsonKey() final  int workDecrementSeconds;
/// Rust ná deze set, vóór de volgende set. Genegeerd bij de laatste set.
@override@JsonKey() final  int setRestSeconds;

/// Create a copy of TabataSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabataSetCopyWith<_TabataSet> get copyWith => __$TabataSetCopyWithImpl<_TabataSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabataSet&&(identical(other.title, title) || other.title == title)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workDecrementSeconds, workDecrementSeconds) || other.workDecrementSeconds == workDecrementSeconds)&&(identical(other.setRestSeconds, setRestSeconds) || other.setRestSeconds == setRestSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,workSeconds,restSeconds,rounds,workDecrementSeconds,setRestSeconds);

@override
String toString() {
  return 'TabataSet(title: $title, workSeconds: $workSeconds, restSeconds: $restSeconds, rounds: $rounds, workDecrementSeconds: $workDecrementSeconds, setRestSeconds: $setRestSeconds)';
}


}

/// @nodoc
abstract mixin class _$TabataSetCopyWith<$Res> implements $TabataSetCopyWith<$Res> {
  factory _$TabataSetCopyWith(_TabataSet value, $Res Function(_TabataSet) _then) = __$TabataSetCopyWithImpl;
@override @useResult
$Res call({
 String title, int workSeconds, int restSeconds, int rounds, int workDecrementSeconds, int setRestSeconds
});




}
/// @nodoc
class __$TabataSetCopyWithImpl<$Res>
    implements _$TabataSetCopyWith<$Res> {
  __$TabataSetCopyWithImpl(this._self, this._then);

  final _TabataSet _self;
  final $Res Function(_TabataSet) _then;

/// Create a copy of TabataSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? workSeconds = null,Object? restSeconds = null,Object? rounds = null,Object? workDecrementSeconds = null,Object? setRestSeconds = null,}) {
  return _then(_TabataSet(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workDecrementSeconds: null == workDecrementSeconds ? _self.workDecrementSeconds : workDecrementSeconds // ignore: cast_nullable_to_non_nullable
as int,setRestSeconds: null == setRestSeconds ? _self.setRestSeconds : setRestSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
