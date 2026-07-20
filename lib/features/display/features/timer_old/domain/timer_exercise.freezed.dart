// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimerExercise {

@JsonKey(includeToJson: false) String? get id; String get name; String get description; int get rounds; int get workSeconds; int get restSeconds; String get ownerId;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of TimerExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerExerciseCopyWith<TimerExercise> get copyWith => _$TimerExerciseCopyWithImpl<TimerExercise>(this as TimerExercise, _$identity);

  /// Serializes this TimerExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,rounds,workSeconds,restSeconds,ownerId,createdAt,updatedAt);

@override
String toString() {
  return 'TimerExercise(id: $id, name: $name, description: $description, rounds: $rounds, workSeconds: $workSeconds, restSeconds: $restSeconds, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TimerExerciseCopyWith<$Res>  {
  factory $TimerExerciseCopyWith(TimerExercise value, $Res Function(TimerExercise) _then) = _$TimerExerciseCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, String description, int rounds, int workSeconds, int restSeconds, String ownerId,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$TimerExerciseCopyWithImpl<$Res>
    implements $TimerExerciseCopyWith<$Res> {
  _$TimerExerciseCopyWithImpl(this._self, this._then);

  final TimerExercise _self;
  final $Res Function(TimerExercise) _then;

/// Create a copy of TimerExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? description = null,Object? rounds = null,Object? workSeconds = null,Object? restSeconds = null,Object? ownerId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerExercise].
extension TimerExercisePatterns on TimerExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerExercise value)  $default,){
final _that = this;
switch (_that) {
case _TimerExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerExercise value)?  $default,){
final _that = this;
switch (_that) {
case _TimerExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  String description,  int rounds,  int workSeconds,  int restSeconds,  String ownerId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerExercise() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds,_that.ownerId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  String description,  int rounds,  int workSeconds,  int restSeconds,  String ownerId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TimerExercise():
return $default(_that.id,_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds,_that.ownerId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String? id,  String name,  String description,  int rounds,  int workSeconds,  int restSeconds,  String ownerId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TimerExercise() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds,_that.ownerId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimerExercise implements TimerExercise {
  const _TimerExercise({@JsonKey(includeToJson: false) this.id, required this.name, this.description = '', required this.rounds, required this.workSeconds, required this.restSeconds, required this.ownerId, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt});
  factory _TimerExercise.fromJson(Map<String, dynamic> json) => _$TimerExerciseFromJson(json);

@override@JsonKey(includeToJson: false) final  String? id;
@override final  String name;
@override@JsonKey() final  String description;
@override final  int rounds;
@override final  int workSeconds;
@override final  int restSeconds;
@override final  String ownerId;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of TimerExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerExerciseCopyWith<_TimerExercise> get copyWith => __$TimerExerciseCopyWithImpl<_TimerExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,rounds,workSeconds,restSeconds,ownerId,createdAt,updatedAt);

@override
String toString() {
  return 'TimerExercise(id: $id, name: $name, description: $description, rounds: $rounds, workSeconds: $workSeconds, restSeconds: $restSeconds, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TimerExerciseCopyWith<$Res> implements $TimerExerciseCopyWith<$Res> {
  factory _$TimerExerciseCopyWith(_TimerExercise value, $Res Function(_TimerExercise) _then) = __$TimerExerciseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, String description, int rounds, int workSeconds, int restSeconds, String ownerId,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$TimerExerciseCopyWithImpl<$Res>
    implements _$TimerExerciseCopyWith<$Res> {
  __$TimerExerciseCopyWithImpl(this._self, this._then);

  final _TimerExercise _self;
  final $Res Function(_TimerExercise) _then;

/// Create a copy of TimerExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? description = null,Object? rounds = null,Object? workSeconds = null,Object? restSeconds = null,Object? ownerId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_TimerExercise(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
