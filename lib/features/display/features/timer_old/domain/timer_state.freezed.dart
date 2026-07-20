// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimerState {

 TimerStatus get status;/// The full TimerSet being executed.
 TimerSet? get currentSet;/// The index of the active exercise in `currentSet.exercises`.
 int get currentExerciseIndex;/// The current round for the active exercise.
 int get currentRound;/// The current phase of the timer (e.g., work, rest).
 TimerPhase get currentPhase;/// The local timestamp from the coach's app when the current phase began.
 int get authoritativeStartTimeMillis;/// Time already elapsed in the current phase before a pause.
 int get accumulatedMillis;/// Firestore server timestamp of when the start event was written.
/// This is used to calculate the clock offset.
@ServerTimestampConverter() Timestamp? get serverWriteTimestamp;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);

  /// Serializes this TimerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.accumulatedMillis, accumulatedMillis) || other.accumulatedMillis == accumulatedMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,currentSet,currentExerciseIndex,currentRound,currentPhase,authoritativeStartTimeMillis,accumulatedMillis,serverWriteTimestamp);

@override
String toString() {
  return 'TimerState(status: $status, currentSet: $currentSet, currentExerciseIndex: $currentExerciseIndex, currentRound: $currentRound, currentPhase: $currentPhase, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, accumulatedMillis: $accumulatedMillis, serverWriteTimestamp: $serverWriteTimestamp)';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 TimerStatus status, TimerSet? currentSet, int currentExerciseIndex, int currentRound, TimerPhase currentPhase, int authoritativeStartTimeMillis, int accumulatedMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp
});


$TimerSetCopyWith<$Res>? get currentSet;

}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? currentSet = freezed,Object? currentExerciseIndex = null,Object? currentRound = null,Object? currentPhase = null,Object? authoritativeStartTimeMillis = null,Object? accumulatedMillis = null,Object? serverWriteTimestamp = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,currentSet: freezed == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as TimerSet?,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as TimerPhase,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,accumulatedMillis: null == accumulatedMillis ? _self.accumulatedMillis : accumulatedMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,
  ));
}
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerSetCopyWith<$Res>? get currentSet {
    if (_self.currentSet == null) {
    return null;
  }

  return $TimerSetCopyWith<$Res>(_self.currentSet!, (value) {
    return _then(_self.copyWith(currentSet: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimerStatus status,  TimerSet? currentSet,  int currentExerciseIndex,  int currentRound,  TimerPhase currentPhase,  int authoritativeStartTimeMillis,  int accumulatedMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.currentSet,_that.currentExerciseIndex,_that.currentRound,_that.currentPhase,_that.authoritativeStartTimeMillis,_that.accumulatedMillis,_that.serverWriteTimestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimerStatus status,  TimerSet? currentSet,  int currentExerciseIndex,  int currentRound,  TimerPhase currentPhase,  int authoritativeStartTimeMillis,  int accumulatedMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.status,_that.currentSet,_that.currentExerciseIndex,_that.currentRound,_that.currentPhase,_that.authoritativeStartTimeMillis,_that.accumulatedMillis,_that.serverWriteTimestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimerStatus status,  TimerSet? currentSet,  int currentExerciseIndex,  int currentRound,  TimerPhase currentPhase,  int authoritativeStartTimeMillis,  int accumulatedMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.currentSet,_that.currentExerciseIndex,_that.currentRound,_that.currentPhase,_that.authoritativeStartTimeMillis,_that.accumulatedMillis,_that.serverWriteTimestamp);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _TimerState implements TimerState {
  const _TimerState({this.status = TimerStatus.stopped, this.currentSet, this.currentExerciseIndex = 0, this.currentRound = 1, this.currentPhase = TimerPhase.preparing, this.authoritativeStartTimeMillis = 0, this.accumulatedMillis = 0, @ServerTimestampConverter() this.serverWriteTimestamp});
  factory _TimerState.fromJson(Map<String, dynamic> json) => _$TimerStateFromJson(json);

@override@JsonKey() final  TimerStatus status;
/// The full TimerSet being executed.
@override final  TimerSet? currentSet;
/// The index of the active exercise in `currentSet.exercises`.
@override@JsonKey() final  int currentExerciseIndex;
/// The current round for the active exercise.
@override@JsonKey() final  int currentRound;
/// The current phase of the timer (e.g., work, rest).
@override@JsonKey() final  TimerPhase currentPhase;
/// The local timestamp from the coach's app when the current phase began.
@override@JsonKey() final  int authoritativeStartTimeMillis;
/// Time already elapsed in the current phase before a pause.
@override@JsonKey() final  int accumulatedMillis;
/// Firestore server timestamp of when the start event was written.
/// This is used to calculate the clock offset.
@override@ServerTimestampConverter() final  Timestamp? serverWriteTimestamp;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.accumulatedMillis, accumulatedMillis) || other.accumulatedMillis == accumulatedMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,currentSet,currentExerciseIndex,currentRound,currentPhase,authoritativeStartTimeMillis,accumulatedMillis,serverWriteTimestamp);

@override
String toString() {
  return 'TimerState(status: $status, currentSet: $currentSet, currentExerciseIndex: $currentExerciseIndex, currentRound: $currentRound, currentPhase: $currentPhase, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, accumulatedMillis: $accumulatedMillis, serverWriteTimestamp: $serverWriteTimestamp)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 TimerStatus status, TimerSet? currentSet, int currentExerciseIndex, int currentRound, TimerPhase currentPhase, int authoritativeStartTimeMillis, int accumulatedMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp
});


@override $TimerSetCopyWith<$Res>? get currentSet;

}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? currentSet = freezed,Object? currentExerciseIndex = null,Object? currentRound = null,Object? currentPhase = null,Object? authoritativeStartTimeMillis = null,Object? accumulatedMillis = null,Object? serverWriteTimestamp = freezed,}) {
  return _then(_TimerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,currentSet: freezed == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as TimerSet?,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as TimerPhase,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,accumulatedMillis: null == accumulatedMillis ? _self.accumulatedMillis : accumulatedMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,
  ));
}

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerSetCopyWith<$Res>? get currentSet {
    if (_self.currentSet == null) {
    return null;
  }

  return $TimerSetCopyWith<$Res>(_self.currentSet!, (value) {
    return _then(_self.copyWith(currentSet: value));
  });
}
}

// dart format on
