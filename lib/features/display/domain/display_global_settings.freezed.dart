// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_global_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayGlobalSettings {

 String get clubName; String get clubLogoUrl; String get clubWebsite; int get width; int get height; List<String> get features;@SubscriptionEndConverter() DateTime get subscriptionEnd;@ColorFromHexConverter.blue() Color get primaryColor;@ColorFromHexConverter.green() Color get secondaryColor;@ColorFromHexConverter.amber() Color get tertiaryColor;@ColorFromHexConverter.black() Color get backgroundColor;
/// Create a copy of DisplayGlobalSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayGlobalSettingsCopyWith<DisplayGlobalSettings> get copyWith => _$DisplayGlobalSettingsCopyWithImpl<DisplayGlobalSettings>(this as DisplayGlobalSettings, _$identity);

  /// Serializes this DisplayGlobalSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayGlobalSettings&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.clubLogoUrl, clubLogoUrl) || other.clubLogoUrl == clubLogoUrl)&&(identical(other.clubWebsite, clubWebsite) || other.clubWebsite == clubWebsite)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.features, features)&&(identical(other.subscriptionEnd, subscriptionEnd) || other.subscriptionEnd == subscriptionEnd)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.tertiaryColor, tertiaryColor) || other.tertiaryColor == tertiaryColor)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clubName,clubLogoUrl,clubWebsite,width,height,const DeepCollectionEquality().hash(features),subscriptionEnd,primaryColor,secondaryColor,tertiaryColor,backgroundColor);

@override
String toString() {
  return 'DisplayGlobalSettings(clubName: $clubName, clubLogoUrl: $clubLogoUrl, clubWebsite: $clubWebsite, width: $width, height: $height, features: $features, subscriptionEnd: $subscriptionEnd, primaryColor: $primaryColor, secondaryColor: $secondaryColor, tertiaryColor: $tertiaryColor, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class $DisplayGlobalSettingsCopyWith<$Res>  {
  factory $DisplayGlobalSettingsCopyWith(DisplayGlobalSettings value, $Res Function(DisplayGlobalSettings) _then) = _$DisplayGlobalSettingsCopyWithImpl;
@useResult
$Res call({
 String clubName, String clubLogoUrl, String clubWebsite, int width, int height, List<String> features,@SubscriptionEndConverter() DateTime subscriptionEnd,@ColorFromHexConverter.blue() Color primaryColor,@ColorFromHexConverter.green() Color secondaryColor,@ColorFromHexConverter.amber() Color tertiaryColor,@ColorFromHexConverter.black() Color backgroundColor
});




}
/// @nodoc
class _$DisplayGlobalSettingsCopyWithImpl<$Res>
    implements $DisplayGlobalSettingsCopyWith<$Res> {
  _$DisplayGlobalSettingsCopyWithImpl(this._self, this._then);

  final DisplayGlobalSettings _self;
  final $Res Function(DisplayGlobalSettings) _then;

/// Create a copy of DisplayGlobalSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clubName = null,Object? clubLogoUrl = null,Object? clubWebsite = null,Object? width = null,Object? height = null,Object? features = null,Object? subscriptionEnd = null,Object? primaryColor = null,Object? secondaryColor = null,Object? tertiaryColor = null,Object? backgroundColor = null,}) {
  return _then(_self.copyWith(
clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,clubLogoUrl: null == clubLogoUrl ? _self.clubLogoUrl : clubLogoUrl // ignore: cast_nullable_to_non_nullable
as String,clubWebsite: null == clubWebsite ? _self.clubWebsite : clubWebsite // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,subscriptionEnd: null == subscriptionEnd ? _self.subscriptionEnd : subscriptionEnd // ignore: cast_nullable_to_non_nullable
as DateTime,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color,secondaryColor: null == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as Color,tertiaryColor: null == tertiaryColor ? _self.tertiaryColor : tertiaryColor // ignore: cast_nullable_to_non_nullable
as Color,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayGlobalSettings].
extension DisplayGlobalSettingsPatterns on DisplayGlobalSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayGlobalSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayGlobalSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayGlobalSettings value)  $default,){
final _that = this;
switch (_that) {
case _DisplayGlobalSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayGlobalSettings value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayGlobalSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clubName,  String clubLogoUrl,  String clubWebsite,  int width,  int height,  List<String> features, @SubscriptionEndConverter()  DateTime subscriptionEnd, @ColorFromHexConverter.blue()  Color primaryColor, @ColorFromHexConverter.green()  Color secondaryColor, @ColorFromHexConverter.amber()  Color tertiaryColor, @ColorFromHexConverter.black()  Color backgroundColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayGlobalSettings() when $default != null:
return $default(_that.clubName,_that.clubLogoUrl,_that.clubWebsite,_that.width,_that.height,_that.features,_that.subscriptionEnd,_that.primaryColor,_that.secondaryColor,_that.tertiaryColor,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clubName,  String clubLogoUrl,  String clubWebsite,  int width,  int height,  List<String> features, @SubscriptionEndConverter()  DateTime subscriptionEnd, @ColorFromHexConverter.blue()  Color primaryColor, @ColorFromHexConverter.green()  Color secondaryColor, @ColorFromHexConverter.amber()  Color tertiaryColor, @ColorFromHexConverter.black()  Color backgroundColor)  $default,) {final _that = this;
switch (_that) {
case _DisplayGlobalSettings():
return $default(_that.clubName,_that.clubLogoUrl,_that.clubWebsite,_that.width,_that.height,_that.features,_that.subscriptionEnd,_that.primaryColor,_that.secondaryColor,_that.tertiaryColor,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clubName,  String clubLogoUrl,  String clubWebsite,  int width,  int height,  List<String> features, @SubscriptionEndConverter()  DateTime subscriptionEnd, @ColorFromHexConverter.blue()  Color primaryColor, @ColorFromHexConverter.green()  Color secondaryColor, @ColorFromHexConverter.amber()  Color tertiaryColor, @ColorFromHexConverter.black()  Color backgroundColor)?  $default,) {final _that = this;
switch (_that) {
case _DisplayGlobalSettings() when $default != null:
return $default(_that.clubName,_that.clubLogoUrl,_that.clubWebsite,_that.width,_that.height,_that.features,_that.subscriptionEnd,_that.primaryColor,_that.secondaryColor,_that.tertiaryColor,_that.backgroundColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplayGlobalSettings implements DisplayGlobalSettings {
  const _DisplayGlobalSettings({this.clubName = 'Club name', this.clubLogoUrl = '', this.clubWebsite = 'www.club.uwh', this.width = 800, this.height = 600, final  List<String> features = const ['main'], @SubscriptionEndConverter() required this.subscriptionEnd, @ColorFromHexConverter.blue() required this.primaryColor, @ColorFromHexConverter.green() required this.secondaryColor, @ColorFromHexConverter.amber() required this.tertiaryColor, @ColorFromHexConverter.black() required this.backgroundColor}): _features = features;
  factory _DisplayGlobalSettings.fromJson(Map<String, dynamic> json) => _$DisplayGlobalSettingsFromJson(json);

@override@JsonKey() final  String clubName;
@override@JsonKey() final  String clubLogoUrl;
@override@JsonKey() final  String clubWebsite;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;
 final  List<String> _features;
@override@JsonKey() List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

@override@SubscriptionEndConverter() final  DateTime subscriptionEnd;
@override@ColorFromHexConverter.blue() final  Color primaryColor;
@override@ColorFromHexConverter.green() final  Color secondaryColor;
@override@ColorFromHexConverter.amber() final  Color tertiaryColor;
@override@ColorFromHexConverter.black() final  Color backgroundColor;

/// Create a copy of DisplayGlobalSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayGlobalSettingsCopyWith<_DisplayGlobalSettings> get copyWith => __$DisplayGlobalSettingsCopyWithImpl<_DisplayGlobalSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayGlobalSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayGlobalSettings&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.clubLogoUrl, clubLogoUrl) || other.clubLogoUrl == clubLogoUrl)&&(identical(other.clubWebsite, clubWebsite) || other.clubWebsite == clubWebsite)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other._features, _features)&&(identical(other.subscriptionEnd, subscriptionEnd) || other.subscriptionEnd == subscriptionEnd)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.tertiaryColor, tertiaryColor) || other.tertiaryColor == tertiaryColor)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clubName,clubLogoUrl,clubWebsite,width,height,const DeepCollectionEquality().hash(_features),subscriptionEnd,primaryColor,secondaryColor,tertiaryColor,backgroundColor);

@override
String toString() {
  return 'DisplayGlobalSettings(clubName: $clubName, clubLogoUrl: $clubLogoUrl, clubWebsite: $clubWebsite, width: $width, height: $height, features: $features, subscriptionEnd: $subscriptionEnd, primaryColor: $primaryColor, secondaryColor: $secondaryColor, tertiaryColor: $tertiaryColor, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class _$DisplayGlobalSettingsCopyWith<$Res> implements $DisplayGlobalSettingsCopyWith<$Res> {
  factory _$DisplayGlobalSettingsCopyWith(_DisplayGlobalSettings value, $Res Function(_DisplayGlobalSettings) _then) = __$DisplayGlobalSettingsCopyWithImpl;
@override @useResult
$Res call({
 String clubName, String clubLogoUrl, String clubWebsite, int width, int height, List<String> features,@SubscriptionEndConverter() DateTime subscriptionEnd,@ColorFromHexConverter.blue() Color primaryColor,@ColorFromHexConverter.green() Color secondaryColor,@ColorFromHexConverter.amber() Color tertiaryColor,@ColorFromHexConverter.black() Color backgroundColor
});




}
/// @nodoc
class __$DisplayGlobalSettingsCopyWithImpl<$Res>
    implements _$DisplayGlobalSettingsCopyWith<$Res> {
  __$DisplayGlobalSettingsCopyWithImpl(this._self, this._then);

  final _DisplayGlobalSettings _self;
  final $Res Function(_DisplayGlobalSettings) _then;

/// Create a copy of DisplayGlobalSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clubName = null,Object? clubLogoUrl = null,Object? clubWebsite = null,Object? width = null,Object? height = null,Object? features = null,Object? subscriptionEnd = null,Object? primaryColor = null,Object? secondaryColor = null,Object? tertiaryColor = null,Object? backgroundColor = null,}) {
  return _then(_DisplayGlobalSettings(
clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,clubLogoUrl: null == clubLogoUrl ? _self.clubLogoUrl : clubLogoUrl // ignore: cast_nullable_to_non_nullable
as String,clubWebsite: null == clubWebsite ? _self.clubWebsite : clubWebsite // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,subscriptionEnd: null == subscriptionEnd ? _self.subscriptionEnd : subscriptionEnd // ignore: cast_nullable_to_non_nullable
as DateTime,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color,secondaryColor: null == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as Color,tertiaryColor: null == tertiaryColor ? _self.tertiaryColor : tertiaryColor // ignore: cast_nullable_to_non_nullable
as Color,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
