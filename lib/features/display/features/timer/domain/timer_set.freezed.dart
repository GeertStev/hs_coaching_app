// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimerSet {

// Required parameters first
 String get title; int get restBetweenExercisesSeconds; List<ExerciseInSet> get exercises; String get ownerId;// Optional parameters last
 String get description; List<String> get tags;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@JsonKey(includeToJson: false) String? get id;
/// Create a copy of TimerSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerSetCopyWith<TimerSet> get copyWith => _$TimerSetCopyWithImpl<TimerSet>(this as TimerSet, _$identity);

  /// Serializes this TimerSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerSet&&(identical(other.title, title) || other.title == title)&&(identical(other.restBetweenExercisesSeconds, restBetweenExercisesSeconds) || other.restBetweenExercisesSeconds == restBetweenExercisesSeconds)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,restBetweenExercisesSeconds,const DeepCollectionEquality().hash(exercises),ownerId,description,const DeepCollectionEquality().hash(tags),createdAt,updatedAt,id);

@override
String toString() {
  return 'TimerSet(title: $title, restBetweenExercisesSeconds: $restBetweenExercisesSeconds, exercises: $exercises, ownerId: $ownerId, description: $description, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
}


}

/// @nodoc
abstract mixin class $TimerSetCopyWith<$Res>  {
  factory $TimerSetCopyWith(TimerSet value, $Res Function(TimerSet) _then) = _$TimerSetCopyWithImpl;
@useResult
$Res call({
 String title, int restBetweenExercisesSeconds, List<ExerciseInSet> exercises, String ownerId, String description, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@JsonKey(includeToJson: false) String? id
});




}
/// @nodoc
class _$TimerSetCopyWithImpl<$Res>
    implements $TimerSetCopyWith<$Res> {
  _$TimerSetCopyWithImpl(this._self, this._then);

  final TimerSet _self;
  final $Res Function(TimerSet) _then;

/// Create a copy of TimerSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? restBetweenExercisesSeconds = null,Object? exercises = null,Object? ownerId = null,Object? description = null,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? id = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,restBetweenExercisesSeconds: null == restBetweenExercisesSeconds ? _self.restBetweenExercisesSeconds : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseInSet>,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerSet].
extension TimerSetPatterns on TimerSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerSet value)  $default,){
final _that = this;
switch (_that) {
case _TimerSet():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerSet value)?  $default,){
final _that = this;
switch (_that) {
case _TimerSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  int restBetweenExercisesSeconds,  List<ExerciseInSet> exercises,  String ownerId,  String description,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @JsonKey(includeToJson: false)  String? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerSet() when $default != null:
return $default(_that.title,_that.restBetweenExercisesSeconds,_that.exercises,_that.ownerId,_that.description,_that.tags,_that.createdAt,_that.updatedAt,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  int restBetweenExercisesSeconds,  List<ExerciseInSet> exercises,  String ownerId,  String description,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @JsonKey(includeToJson: false)  String? id)  $default,) {final _that = this;
switch (_that) {
case _TimerSet():
return $default(_that.title,_that.restBetweenExercisesSeconds,_that.exercises,_that.ownerId,_that.description,_that.tags,_that.createdAt,_that.updatedAt,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  int restBetweenExercisesSeconds,  List<ExerciseInSet> exercises,  String ownerId,  String description,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @JsonKey(includeToJson: false)  String? id)?  $default,) {final _that = this;
switch (_that) {
case _TimerSet() when $default != null:
return $default(_that.title,_that.restBetweenExercisesSeconds,_that.exercises,_that.ownerId,_that.description,_that.tags,_that.createdAt,_that.updatedAt,_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TimerSet implements TimerSet {
  const _TimerSet({required this.title, required this.restBetweenExercisesSeconds, required final  List<ExerciseInSet> exercises, required this.ownerId, this.description = '', final  List<String> tags = const [], @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @JsonKey(includeToJson: false) this.id}): _exercises = exercises,_tags = tags;
  factory _TimerSet.fromJson(Map<String, dynamic> json) => _$TimerSetFromJson(json);

// Required parameters first
@override final  String title;
@override final  int restBetweenExercisesSeconds;
 final  List<ExerciseInSet> _exercises;
@override List<ExerciseInSet> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override final  String ownerId;
// Optional parameters last
@override@JsonKey() final  String description;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey(includeToJson: false) final  String? id;

/// Create a copy of TimerSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerSetCopyWith<_TimerSet> get copyWith => __$TimerSetCopyWithImpl<_TimerSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerSet&&(identical(other.title, title) || other.title == title)&&(identical(other.restBetweenExercisesSeconds, restBetweenExercisesSeconds) || other.restBetweenExercisesSeconds == restBetweenExercisesSeconds)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,restBetweenExercisesSeconds,const DeepCollectionEquality().hash(_exercises),ownerId,description,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt,id);

@override
String toString() {
  return 'TimerSet(title: $title, restBetweenExercisesSeconds: $restBetweenExercisesSeconds, exercises: $exercises, ownerId: $ownerId, description: $description, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
}


}

/// @nodoc
abstract mixin class _$TimerSetCopyWith<$Res> implements $TimerSetCopyWith<$Res> {
  factory _$TimerSetCopyWith(_TimerSet value, $Res Function(_TimerSet) _then) = __$TimerSetCopyWithImpl;
@override @useResult
$Res call({
 String title, int restBetweenExercisesSeconds, List<ExerciseInSet> exercises, String ownerId, String description, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@JsonKey(includeToJson: false) String? id
});




}
/// @nodoc
class __$TimerSetCopyWithImpl<$Res>
    implements _$TimerSetCopyWith<$Res> {
  __$TimerSetCopyWithImpl(this._self, this._then);

  final _TimerSet _self;
  final $Res Function(_TimerSet) _then;

/// Create a copy of TimerSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? restBetweenExercisesSeconds = null,Object? exercises = null,Object? ownerId = null,Object? description = null,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? id = freezed,}) {
  return _then(_TimerSet(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,restBetweenExercisesSeconds: null == restBetweenExercisesSeconds ? _self.restBetweenExercisesSeconds : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseInSet>,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExerciseInSet {

 String get name; String get description; int get rounds; int get workSeconds; int get restSeconds;
/// Create a copy of ExerciseInSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseInSetCopyWith<ExerciseInSet> get copyWith => _$ExerciseInSetCopyWithImpl<ExerciseInSet>(this as ExerciseInSet, _$identity);

  /// Serializes this ExerciseInSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseInSet&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,rounds,workSeconds,restSeconds);

@override
String toString() {
  return 'ExerciseInSet(name: $name, description: $description, rounds: $rounds, workSeconds: $workSeconds, restSeconds: $restSeconds)';
}


}

/// @nodoc
abstract mixin class $ExerciseInSetCopyWith<$Res>  {
  factory $ExerciseInSetCopyWith(ExerciseInSet value, $Res Function(ExerciseInSet) _then) = _$ExerciseInSetCopyWithImpl;
@useResult
$Res call({
 String name, String description, int rounds, int workSeconds, int restSeconds
});




}
/// @nodoc
class _$ExerciseInSetCopyWithImpl<$Res>
    implements $ExerciseInSetCopyWith<$Res> {
  _$ExerciseInSetCopyWithImpl(this._self, this._then);

  final ExerciseInSet _self;
  final $Res Function(ExerciseInSet) _then;

/// Create a copy of ExerciseInSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? rounds = null,Object? workSeconds = null,Object? restSeconds = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseInSet].
extension ExerciseInSetPatterns on ExerciseInSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseInSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseInSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseInSet value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseInSet():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseInSet value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseInSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  int rounds,  int workSeconds,  int restSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseInSet() when $default != null:
return $default(_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  int rounds,  int workSeconds,  int restSeconds)  $default,) {final _that = this;
switch (_that) {
case _ExerciseInSet():
return $default(_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  int rounds,  int workSeconds,  int restSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseInSet() when $default != null:
return $default(_that.name,_that.description,_that.rounds,_that.workSeconds,_that.restSeconds);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _ExerciseInSet implements ExerciseInSet {
  const _ExerciseInSet({required this.name, this.description = '', required this.rounds, required this.workSeconds, required this.restSeconds});
  factory _ExerciseInSet.fromJson(Map<String, dynamic> json) => _$ExerciseInSetFromJson(json);

@override final  String name;
@override@JsonKey() final  String description;
@override final  int rounds;
@override final  int workSeconds;
@override final  int restSeconds;

/// Create a copy of ExerciseInSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseInSetCopyWith<_ExerciseInSet> get copyWith => __$ExerciseInSetCopyWithImpl<_ExerciseInSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseInSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseInSet&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,rounds,workSeconds,restSeconds);

@override
String toString() {
  return 'ExerciseInSet(name: $name, description: $description, rounds: $rounds, workSeconds: $workSeconds, restSeconds: $restSeconds)';
}


}

/// @nodoc
abstract mixin class _$ExerciseInSetCopyWith<$Res> implements $ExerciseInSetCopyWith<$Res> {
  factory _$ExerciseInSetCopyWith(_ExerciseInSet value, $Res Function(_ExerciseInSet) _then) = __$ExerciseInSetCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, int rounds, int workSeconds, int restSeconds
});




}
/// @nodoc
class __$ExerciseInSetCopyWithImpl<$Res>
    implements _$ExerciseInSetCopyWith<$Res> {
  __$ExerciseInSetCopyWithImpl(this._self, this._then);

  final _ExerciseInSet _self;
  final $Res Function(_ExerciseInSet) _then;

/// Create a copy of ExerciseInSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? rounds = null,Object? workSeconds = null,Object? restSeconds = null,}) {
  return _then(_ExerciseInSet(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
