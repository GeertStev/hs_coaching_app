// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabata_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TabataGroup {

 String get id; String get title; int get rounds; int get restBetweenRepeats; List<TabataExercise> get children; int get restAfter;
/// Create a copy of TabataGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataGroupCopyWith<TabataGroup> get copyWith => _$TabataGroupCopyWithImpl<TabataGroup>(this as TabataGroup, _$identity);

  /// Serializes this TabataGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.restBetweenRepeats, restBetweenRepeats) || other.restBetweenRepeats == restBetweenRepeats)&&const DeepCollectionEquality().equals(other.children, children)&&(identical(other.restAfter, restAfter) || other.restAfter == restAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,rounds,restBetweenRepeats,const DeepCollectionEquality().hash(children),restAfter);

@override
String toString() {
  return 'TabataGroup(id: $id, title: $title, rounds: $rounds, restBetweenRepeats: $restBetweenRepeats, children: $children, restAfter: $restAfter)';
}


}

/// @nodoc
abstract mixin class $TabataGroupCopyWith<$Res>  {
  factory $TabataGroupCopyWith(TabataGroup value, $Res Function(TabataGroup) _then) = _$TabataGroupCopyWithImpl;
@useResult
$Res call({
 String id, String title, int rounds, int restBetweenRepeats, List<TabataExercise> children, int restAfter
});




}
/// @nodoc
class _$TabataGroupCopyWithImpl<$Res>
    implements $TabataGroupCopyWith<$Res> {
  _$TabataGroupCopyWithImpl(this._self, this._then);

  final TabataGroup _self;
  final $Res Function(TabataGroup) _then;

/// Create a copy of TabataGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? rounds = null,Object? restBetweenRepeats = null,Object? children = null,Object? restAfter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,restBetweenRepeats: null == restBetweenRepeats ? _self.restBetweenRepeats : restBetweenRepeats // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<TabataExercise>,restAfter: null == restAfter ? _self.restAfter : restAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TabataGroup].
extension TabataGroupPatterns on TabataGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TabataGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TabataGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TabataGroup value)  $default,){
final _that = this;
switch (_that) {
case _TabataGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TabataGroup value)?  $default,){
final _that = this;
switch (_that) {
case _TabataGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int rounds,  int restBetweenRepeats,  List<TabataExercise> children,  int restAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TabataGroup() when $default != null:
return $default(_that.id,_that.title,_that.rounds,_that.restBetweenRepeats,_that.children,_that.restAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int rounds,  int restBetweenRepeats,  List<TabataExercise> children,  int restAfter)  $default,) {final _that = this;
switch (_that) {
case _TabataGroup():
return $default(_that.id,_that.title,_that.rounds,_that.restBetweenRepeats,_that.children,_that.restAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int rounds,  int restBetweenRepeats,  List<TabataExercise> children,  int restAfter)?  $default,) {final _that = this;
switch (_that) {
case _TabataGroup() when $default != null:
return $default(_that.id,_that.title,_that.rounds,_that.restBetweenRepeats,_that.children,_that.restAfter);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TabataGroup extends TabataGroup {
  const _TabataGroup({required this.id, this.title = '', this.rounds = 1, this.restBetweenRepeats = 0, final  List<TabataExercise> children = const <TabataExercise>[], this.restAfter = 0}): _children = children,super._();
  factory _TabataGroup.fromJson(Map<String, dynamic> json) => _$TabataGroupFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  int rounds;
@override@JsonKey() final  int restBetweenRepeats;
 final  List<TabataExercise> _children;
@override@JsonKey() List<TabataExercise> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override@JsonKey() final  int restAfter;

/// Create a copy of TabataGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabataGroupCopyWith<_TabataGroup> get copyWith => __$TabataGroupCopyWithImpl<_TabataGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabataGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.restBetweenRepeats, restBetweenRepeats) || other.restBetweenRepeats == restBetweenRepeats)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.restAfter, restAfter) || other.restAfter == restAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,rounds,restBetweenRepeats,const DeepCollectionEquality().hash(_children),restAfter);

@override
String toString() {
  return 'TabataGroup(id: $id, title: $title, rounds: $rounds, restBetweenRepeats: $restBetweenRepeats, children: $children, restAfter: $restAfter)';
}


}

/// @nodoc
abstract mixin class _$TabataGroupCopyWith<$Res> implements $TabataGroupCopyWith<$Res> {
  factory _$TabataGroupCopyWith(_TabataGroup value, $Res Function(_TabataGroup) _then) = __$TabataGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int rounds, int restBetweenRepeats, List<TabataExercise> children, int restAfter
});




}
/// @nodoc
class __$TabataGroupCopyWithImpl<$Res>
    implements _$TabataGroupCopyWith<$Res> {
  __$TabataGroupCopyWithImpl(this._self, this._then);

  final _TabataGroup _self;
  final $Res Function(_TabataGroup) _then;

/// Create a copy of TabataGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? rounds = null,Object? restBetweenRepeats = null,Object? children = null,Object? restAfter = null,}) {
  return _then(_TabataGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,restBetweenRepeats: null == restBetweenRepeats ? _self.restBetweenRepeats : restBetweenRepeats // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<TabataExercise>,restAfter: null == restAfter ? _self.restAfter : restAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
