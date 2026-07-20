// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chrono.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chrono {

 ChronoStatus get status;/// The local timestamp from the control app when the button was pressed.
 int get authoritativeStartTimeMillis;/// Firestore server timestamp of when the start event was written.
@ServerTimestampConverter() Timestamp? get serverWriteTimestamp;/// Time accumulated before the current running session.
 int get accumulatedElapsedMillis;/// Lijst met rondetijden (opgeslagen als geaccumuleerde verstreken tijd in millis)
 List<int> get laps;
/// Create a copy of Chrono
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChronoCopyWith<Chrono> get copyWith => _$ChronoCopyWithImpl<Chrono>(this as Chrono, _$identity);

  /// Serializes this Chrono to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chrono&&(identical(other.status, status) || other.status == status)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp)&&(identical(other.accumulatedElapsedMillis, accumulatedElapsedMillis) || other.accumulatedElapsedMillis == accumulatedElapsedMillis)&&const DeepCollectionEquality().equals(other.laps, laps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,authoritativeStartTimeMillis,serverWriteTimestamp,accumulatedElapsedMillis,const DeepCollectionEquality().hash(laps));

@override
String toString() {
  return 'Chrono(status: $status, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, serverWriteTimestamp: $serverWriteTimestamp, accumulatedElapsedMillis: $accumulatedElapsedMillis, laps: $laps)';
}


}

/// @nodoc
abstract mixin class $ChronoCopyWith<$Res>  {
  factory $ChronoCopyWith(Chrono value, $Res Function(Chrono) _then) = _$ChronoCopyWithImpl;
@useResult
$Res call({
 ChronoStatus status, int authoritativeStartTimeMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp, int accumulatedElapsedMillis, List<int> laps
});




}
/// @nodoc
class _$ChronoCopyWithImpl<$Res>
    implements $ChronoCopyWith<$Res> {
  _$ChronoCopyWithImpl(this._self, this._then);

  final Chrono _self;
  final $Res Function(Chrono) _then;

/// Create a copy of Chrono
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? authoritativeStartTimeMillis = null,Object? serverWriteTimestamp = freezed,Object? accumulatedElapsedMillis = null,Object? laps = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChronoStatus,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,accumulatedElapsedMillis: null == accumulatedElapsedMillis ? _self.accumulatedElapsedMillis : accumulatedElapsedMillis // ignore: cast_nullable_to_non_nullable
as int,laps: null == laps ? _self.laps : laps // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [Chrono].
extension ChronoPatterns on Chrono {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chrono value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chrono() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chrono value)  $default,){
final _that = this;
switch (_that) {
case _Chrono():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chrono value)?  $default,){
final _that = this;
switch (_that) {
case _Chrono() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChronoStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis,  List<int> laps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chrono() when $default != null:
return $default(_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis,_that.laps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChronoStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis,  List<int> laps)  $default,) {final _that = this;
switch (_that) {
case _Chrono():
return $default(_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis,_that.laps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChronoStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis,  List<int> laps)?  $default,) {final _that = this;
switch (_that) {
case _Chrono() when $default != null:
return $default(_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis,_that.laps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Chrono implements Chrono {
  const _Chrono({this.status = ChronoStatus.stopped, this.authoritativeStartTimeMillis = 0, @ServerTimestampConverter() this.serverWriteTimestamp, this.accumulatedElapsedMillis = 0, final  List<int> laps = const []}): _laps = laps;
  factory _Chrono.fromJson(Map<String, dynamic> json) => _$ChronoFromJson(json);

@override@JsonKey() final  ChronoStatus status;
/// The local timestamp from the control app when the button was pressed.
@override@JsonKey() final  int authoritativeStartTimeMillis;
/// Firestore server timestamp of when the start event was written.
@override@ServerTimestampConverter() final  Timestamp? serverWriteTimestamp;
/// Time accumulated before the current running session.
@override@JsonKey() final  int accumulatedElapsedMillis;
/// Lijst met rondetijden (opgeslagen als geaccumuleerde verstreken tijd in millis)
 final  List<int> _laps;
/// Lijst met rondetijden (opgeslagen als geaccumuleerde verstreken tijd in millis)
@override@JsonKey() List<int> get laps {
  if (_laps is EqualUnmodifiableListView) return _laps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_laps);
}


/// Create a copy of Chrono
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChronoCopyWith<_Chrono> get copyWith => __$ChronoCopyWithImpl<_Chrono>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChronoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chrono&&(identical(other.status, status) || other.status == status)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp)&&(identical(other.accumulatedElapsedMillis, accumulatedElapsedMillis) || other.accumulatedElapsedMillis == accumulatedElapsedMillis)&&const DeepCollectionEquality().equals(other._laps, _laps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,authoritativeStartTimeMillis,serverWriteTimestamp,accumulatedElapsedMillis,const DeepCollectionEquality().hash(_laps));

@override
String toString() {
  return 'Chrono(status: $status, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, serverWriteTimestamp: $serverWriteTimestamp, accumulatedElapsedMillis: $accumulatedElapsedMillis, laps: $laps)';
}


}

/// @nodoc
abstract mixin class _$ChronoCopyWith<$Res> implements $ChronoCopyWith<$Res> {
  factory _$ChronoCopyWith(_Chrono value, $Res Function(_Chrono) _then) = __$ChronoCopyWithImpl;
@override @useResult
$Res call({
 ChronoStatus status, int authoritativeStartTimeMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp, int accumulatedElapsedMillis, List<int> laps
});




}
/// @nodoc
class __$ChronoCopyWithImpl<$Res>
    implements _$ChronoCopyWith<$Res> {
  __$ChronoCopyWithImpl(this._self, this._then);

  final _Chrono _self;
  final $Res Function(_Chrono) _then;

/// Create a copy of Chrono
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? authoritativeStartTimeMillis = null,Object? serverWriteTimestamp = freezed,Object? accumulatedElapsedMillis = null,Object? laps = null,}) {
  return _then(_Chrono(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChronoStatus,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,accumulatedElapsedMillis: null == accumulatedElapsedMillis ? _self.accumulatedElapsedMillis : accumulatedElapsedMillis // ignore: cast_nullable_to_non_nullable
as int,laps: null == laps ? _self._laps : laps // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
