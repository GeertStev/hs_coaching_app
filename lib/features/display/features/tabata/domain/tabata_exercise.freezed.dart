// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabata_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TabataExercise {

 String get id; String get title; int get workSeconds; int get restSeconds; int get rounds; int get stepSeconds; int get restAfter;
/// Create a copy of TabataExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataExerciseCopyWith<TabataExercise> get copyWith => _$TabataExerciseCopyWithImpl<TabataExercise>(this as TabataExercise, _$identity);

  /// Serializes this TabataExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.stepSeconds, stepSeconds) || other.stepSeconds == stepSeconds)&&(identical(other.restAfter, restAfter) || other.restAfter == restAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,workSeconds,restSeconds,rounds,stepSeconds,restAfter);

@override
String toString() {
  return 'TabataExercise(id: $id, title: $title, workSeconds: $workSeconds, restSeconds: $restSeconds, rounds: $rounds, stepSeconds: $stepSeconds, restAfter: $restAfter)';
}


}

/// @nodoc
abstract mixin class $TabataExerciseCopyWith<$Res>  {
  factory $TabataExerciseCopyWith(TabataExercise value, $Res Function(TabataExercise) _then) = _$TabataExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String title, int workSeconds, int restSeconds, int rounds, int stepSeconds, int restAfter
});




}
/// @nodoc
class _$TabataExerciseCopyWithImpl<$Res>
    implements $TabataExerciseCopyWith<$Res> {
  _$TabataExerciseCopyWithImpl(this._self, this._then);

  final TabataExercise _self;
  final $Res Function(TabataExercise) _then;

/// Create a copy of TabataExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? workSeconds = null,Object? restSeconds = null,Object? rounds = null,Object? stepSeconds = null,Object? restAfter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,stepSeconds: null == stepSeconds ? _self.stepSeconds : stepSeconds // ignore: cast_nullable_to_non_nullable
as int,restAfter: null == restAfter ? _self.restAfter : restAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TabataExercise].
extension TabataExercisePatterns on TabataExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TabataExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TabataExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TabataExercise value)  $default,){
final _that = this;
switch (_that) {
case _TabataExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TabataExercise value)?  $default,){
final _that = this;
switch (_that) {
case _TabataExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int workSeconds,  int restSeconds,  int rounds,  int stepSeconds,  int restAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TabataExercise() when $default != null:
return $default(_that.id,_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.stepSeconds,_that.restAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int workSeconds,  int restSeconds,  int rounds,  int stepSeconds,  int restAfter)  $default,) {final _that = this;
switch (_that) {
case _TabataExercise():
return $default(_that.id,_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.stepSeconds,_that.restAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int workSeconds,  int restSeconds,  int rounds,  int stepSeconds,  int restAfter)?  $default,) {final _that = this;
switch (_that) {
case _TabataExercise() when $default != null:
return $default(_that.id,_that.title,_that.workSeconds,_that.restSeconds,_that.rounds,_that.stepSeconds,_that.restAfter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TabataExercise extends TabataExercise {
  const _TabataExercise({required this.id, this.title = '', this.workSeconds = 20, this.restSeconds = 10, this.rounds = 8, this.stepSeconds = 0, this.restAfter = 0}): super._();
  factory _TabataExercise.fromJson(Map<String, dynamic> json) => _$TabataExerciseFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  int workSeconds;
@override@JsonKey() final  int restSeconds;
@override@JsonKey() final  int rounds;
@override@JsonKey() final  int stepSeconds;
@override@JsonKey() final  int restAfter;

/// Create a copy of TabataExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabataExerciseCopyWith<_TabataExercise> get copyWith => __$TabataExerciseCopyWithImpl<_TabataExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabataExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.stepSeconds, stepSeconds) || other.stepSeconds == stepSeconds)&&(identical(other.restAfter, restAfter) || other.restAfter == restAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,workSeconds,restSeconds,rounds,stepSeconds,restAfter);

@override
String toString() {
  return 'TabataExercise(id: $id, title: $title, workSeconds: $workSeconds, restSeconds: $restSeconds, rounds: $rounds, stepSeconds: $stepSeconds, restAfter: $restAfter)';
}


}

/// @nodoc
abstract mixin class _$TabataExerciseCopyWith<$Res> implements $TabataExerciseCopyWith<$Res> {
  factory _$TabataExerciseCopyWith(_TabataExercise value, $Res Function(_TabataExercise) _then) = __$TabataExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int workSeconds, int restSeconds, int rounds, int stepSeconds, int restAfter
});




}
/// @nodoc
class __$TabataExerciseCopyWithImpl<$Res>
    implements _$TabataExerciseCopyWith<$Res> {
  __$TabataExerciseCopyWithImpl(this._self, this._then);

  final _TabataExercise _self;
  final $Res Function(_TabataExercise) _then;

/// Create a copy of TabataExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? workSeconds = null,Object? restSeconds = null,Object? rounds = null,Object? stepSeconds = null,Object? restAfter = null,}) {
  return _then(_TabataExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,stepSeconds: null == stepSeconds ? _self.stepSeconds : stepSeconds // ignore: cast_nullable_to_non_nullable
as int,restAfter: null == restAfter ? _self.restAfter : restAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
