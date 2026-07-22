// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabata_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
TabataItem _$TabataItemFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'exercise':
          return TabataItemExercise.fromJson(
            json
          );
                case 'group':
          return TabataItemGroup.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'TabataItem',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$TabataItem {



  /// Serializes this TabataItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataItem);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TabataItem()';
}


}

/// @nodoc
class $TabataItemCopyWith<$Res>  {
$TabataItemCopyWith(TabataItem _, $Res Function(TabataItem) __);
}


/// Adds pattern-matching-related methods to [TabataItem].
extension TabataItemPatterns on TabataItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TabataItemExercise value)?  exercise,TResult Function( TabataItemGroup value)?  group,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TabataItemExercise() when exercise != null:
return exercise(_that);case TabataItemGroup() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TabataItemExercise value)  exercise,required TResult Function( TabataItemGroup value)  group,}){
final _that = this;
switch (_that) {
case TabataItemExercise():
return exercise(_that);case TabataItemGroup():
return group(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TabataItemExercise value)?  exercise,TResult? Function( TabataItemGroup value)?  group,}){
final _that = this;
switch (_that) {
case TabataItemExercise() when exercise != null:
return exercise(_that);case TabataItemGroup() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TabataExercise exercise)?  exercise,TResult Function( TabataGroup group)?  group,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TabataItemExercise() when exercise != null:
return exercise(_that.exercise);case TabataItemGroup() when group != null:
return group(_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TabataExercise exercise)  exercise,required TResult Function( TabataGroup group)  group,}) {final _that = this;
switch (_that) {
case TabataItemExercise():
return exercise(_that.exercise);case TabataItemGroup():
return group(_that.group);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TabataExercise exercise)?  exercise,TResult? Function( TabataGroup group)?  group,}) {final _that = this;
switch (_that) {
case TabataItemExercise() when exercise != null:
return exercise(_that.exercise);case TabataItemGroup() when group != null:
return group(_that.group);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class TabataItemExercise extends TabataItem {
  const TabataItemExercise(this.exercise, {final  String? $type}): $type = $type ?? 'exercise',super._();
  factory TabataItemExercise.fromJson(Map<String, dynamic> json) => _$TabataItemExerciseFromJson(json);

 final  TabataExercise exercise;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataItemExerciseCopyWith<TabataItemExercise> get copyWith => _$TabataItemExerciseCopyWithImpl<TabataItemExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataItemExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataItemExercise&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exercise);

@override
String toString() {
  return 'TabataItem.exercise(exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class $TabataItemExerciseCopyWith<$Res> implements $TabataItemCopyWith<$Res> {
  factory $TabataItemExerciseCopyWith(TabataItemExercise value, $Res Function(TabataItemExercise) _then) = _$TabataItemExerciseCopyWithImpl;
@useResult
$Res call({
 TabataExercise exercise
});


$TabataExerciseCopyWith<$Res> get exercise;

}
/// @nodoc
class _$TabataItemExerciseCopyWithImpl<$Res>
    implements $TabataItemExerciseCopyWith<$Res> {
  _$TabataItemExerciseCopyWithImpl(this._self, this._then);

  final TabataItemExercise _self;
  final $Res Function(TabataItemExercise) _then;

/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exercise = null,}) {
  return _then(TabataItemExercise(
null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as TabataExercise,
  ));
}

/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TabataExerciseCopyWith<$Res> get exercise {
  
  return $TabataExerciseCopyWith<$Res>(_self.exercise, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class TabataItemGroup extends TabataItem {
  const TabataItemGroup(this.group, {final  String? $type}): $type = $type ?? 'group',super._();
  factory TabataItemGroup.fromJson(Map<String, dynamic> json) => _$TabataItemGroupFromJson(json);

 final  TabataGroup group;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabataItemGroupCopyWith<TabataItemGroup> get copyWith => _$TabataItemGroupCopyWithImpl<TabataItemGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TabataItemGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabataItemGroup&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,group);

@override
String toString() {
  return 'TabataItem.group(group: $group)';
}


}

/// @nodoc
abstract mixin class $TabataItemGroupCopyWith<$Res> implements $TabataItemCopyWith<$Res> {
  factory $TabataItemGroupCopyWith(TabataItemGroup value, $Res Function(TabataItemGroup) _then) = _$TabataItemGroupCopyWithImpl;
@useResult
$Res call({
 TabataGroup group
});


$TabataGroupCopyWith<$Res> get group;

}
/// @nodoc
class _$TabataItemGroupCopyWithImpl<$Res>
    implements $TabataItemGroupCopyWith<$Res> {
  _$TabataItemGroupCopyWithImpl(this._self, this._then);

  final TabataItemGroup _self;
  final $Res Function(TabataItemGroup) _then;

/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? group = null,}) {
  return _then(TabataItemGroup(
null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as TabataGroup,
  ));
}

/// Create a copy of TabataItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TabataGroupCopyWith<$Res> get group {
  
  return $TabataGroupCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}

// dart format on
