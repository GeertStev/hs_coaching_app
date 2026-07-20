// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tabata {

// --- Configuratie ---
 int get prepareSeconds; List<TabataSet> get sets;// --- Runtime status (zelfde mechanisme als Chrono) ---
 TabataStatus get status;/// The local timestamp from the control app when the button was pressed.
 int get authoritativeStartTimeMillis;/// Firestore server timestamp of when the start event was written.
@ServerTimestampConverter() Timestamp? get serverWriteTimestamp;/// Time accumulated before the current running session.
 int get accumulatedElapsedMillis;
/// Create a copy of Tabata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataCopyWith<Tabata> get copyWith => _$TabataCopyWithImpl<Tabata>(this as Tabata, _$identity);

  /// Serializes this Tabata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tabata&&(identical(other.prepareSeconds, prepareSeconds) || other.prepareSeconds == prepareSeconds)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.status, status) || other.status == status)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp)&&(identical(other.accumulatedElapsedMillis, accumulatedElapsedMillis) || other.accumulatedElapsedMillis == accumulatedElapsedMillis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prepareSeconds,const DeepCollectionEquality().hash(sets),status,authoritativeStartTimeMillis,serverWriteTimestamp,accumulatedElapsedMillis);

@override
String toString() {
  return 'Tabata(prepareSeconds: $prepareSeconds, sets: $sets, status: $status, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, serverWriteTimestamp: $serverWriteTimestamp, accumulatedElapsedMillis: $accumulatedElapsedMillis)';
}


}

/// @nodoc
abstract mixin class $TabataCopyWith<$Res>  {
  factory $TabataCopyWith(Tabata value, $Res Function(Tabata) _then) = _$TabataCopyWithImpl;
@useResult
$Res call({
 int prepareSeconds, List<TabataSet> sets, TabataStatus status, int authoritativeStartTimeMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp, int accumulatedElapsedMillis
});




}
/// @nodoc
class _$TabataCopyWithImpl<$Res>
    implements $TabataCopyWith<$Res> {
  _$TabataCopyWithImpl(this._self, this._then);

  final Tabata _self;
  final $Res Function(Tabata) _then;

/// Create a copy of Tabata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prepareSeconds = null,Object? sets = null,Object? status = null,Object? authoritativeStartTimeMillis = null,Object? serverWriteTimestamp = freezed,Object? accumulatedElapsedMillis = null,}) {
  return _then(_self.copyWith(
prepareSeconds: null == prepareSeconds ? _self.prepareSeconds : prepareSeconds // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<TabataSet>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TabataStatus,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,accumulatedElapsedMillis: null == accumulatedElapsedMillis ? _self.accumulatedElapsedMillis : accumulatedElapsedMillis // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Tabata].
extension TabataPatterns on Tabata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tabata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tabata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tabata value)  $default,){
final _that = this;
switch (_that) {
case _Tabata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tabata value)?  $default,){
final _that = this;
switch (_that) {
case _Tabata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int prepareSeconds,  List<TabataSet> sets,  TabataStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tabata() when $default != null:
return $default(_that.prepareSeconds,_that.sets,_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int prepareSeconds,  List<TabataSet> sets,  TabataStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis)  $default,) {final _that = this;
switch (_that) {
case _Tabata():
return $default(_that.prepareSeconds,_that.sets,_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int prepareSeconds,  List<TabataSet> sets,  TabataStatus status,  int authoritativeStartTimeMillis, @ServerTimestampConverter()  Timestamp? serverWriteTimestamp,  int accumulatedElapsedMillis)?  $default,) {final _that = this;
switch (_that) {
case _Tabata() when $default != null:
return $default(_that.prepareSeconds,_that.sets,_that.status,_that.authoritativeStartTimeMillis,_that.serverWriteTimestamp,_that.accumulatedElapsedMillis);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Tabata extends Tabata {
  const _Tabata({this.prepareSeconds = 10, final  List<TabataSet> sets = const [TabataSet()], this.status = TabataStatus.stopped, this.authoritativeStartTimeMillis = 0, @ServerTimestampConverter() this.serverWriteTimestamp, this.accumulatedElapsedMillis = 0}): _sets = sets,super._();
  factory _Tabata.fromJson(Map<String, dynamic> json) => _$TabataFromJson(json);

// --- Configuratie ---
@override@JsonKey() final  int prepareSeconds;
 final  List<TabataSet> _sets;
@override@JsonKey() List<TabataSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

// --- Runtime status (zelfde mechanisme als Chrono) ---
@override@JsonKey() final  TabataStatus status;
/// The local timestamp from the control app when the button was pressed.
@override@JsonKey() final  int authoritativeStartTimeMillis;
/// Firestore server timestamp of when the start event was written.
@override@ServerTimestampConverter() final  Timestamp? serverWriteTimestamp;
/// Time accumulated before the current running session.
@override@JsonKey() final  int accumulatedElapsedMillis;

/// Create a copy of Tabata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabataCopyWith<_Tabata> get copyWith => __$TabataCopyWithImpl<_Tabata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tabata&&(identical(other.prepareSeconds, prepareSeconds) || other.prepareSeconds == prepareSeconds)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.status, status) || other.status == status)&&(identical(other.authoritativeStartTimeMillis, authoritativeStartTimeMillis) || other.authoritativeStartTimeMillis == authoritativeStartTimeMillis)&&(identical(other.serverWriteTimestamp, serverWriteTimestamp) || other.serverWriteTimestamp == serverWriteTimestamp)&&(identical(other.accumulatedElapsedMillis, accumulatedElapsedMillis) || other.accumulatedElapsedMillis == accumulatedElapsedMillis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prepareSeconds,const DeepCollectionEquality().hash(_sets),status,authoritativeStartTimeMillis,serverWriteTimestamp,accumulatedElapsedMillis);

@override
String toString() {
  return 'Tabata(prepareSeconds: $prepareSeconds, sets: $sets, status: $status, authoritativeStartTimeMillis: $authoritativeStartTimeMillis, serverWriteTimestamp: $serverWriteTimestamp, accumulatedElapsedMillis: $accumulatedElapsedMillis)';
}


}

/// @nodoc
abstract mixin class _$TabataCopyWith<$Res> implements $TabataCopyWith<$Res> {
  factory _$TabataCopyWith(_Tabata value, $Res Function(_Tabata) _then) = __$TabataCopyWithImpl;
@override @useResult
$Res call({
 int prepareSeconds, List<TabataSet> sets, TabataStatus status, int authoritativeStartTimeMillis,@ServerTimestampConverter() Timestamp? serverWriteTimestamp, int accumulatedElapsedMillis
});




}
/// @nodoc
class __$TabataCopyWithImpl<$Res>
    implements _$TabataCopyWith<$Res> {
  __$TabataCopyWithImpl(this._self, this._then);

  final _Tabata _self;
  final $Res Function(_Tabata) _then;

/// Create a copy of Tabata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prepareSeconds = null,Object? sets = null,Object? status = null,Object? authoritativeStartTimeMillis = null,Object? serverWriteTimestamp = freezed,Object? accumulatedElapsedMillis = null,}) {
  return _then(_Tabata(
prepareSeconds: null == prepareSeconds ? _self.prepareSeconds : prepareSeconds // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<TabataSet>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TabataStatus,authoritativeStartTimeMillis: null == authoritativeStartTimeMillis ? _self.authoritativeStartTimeMillis : authoritativeStartTimeMillis // ignore: cast_nullable_to_non_nullable
as int,serverWriteTimestamp: freezed == serverWriteTimestamp ? _self.serverWriteTimestamp : serverWriteTimestamp // ignore: cast_nullable_to_non_nullable
as Timestamp?,accumulatedElapsedMillis: null == accumulatedElapsedMillis ? _self.accumulatedElapsedMillis : accumulatedElapsedMillis // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
