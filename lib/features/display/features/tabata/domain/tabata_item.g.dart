// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabataItemExercise _$TabataItemExerciseFromJson(Map<String, dynamic> json) =>
    TabataItemExercise(
      TabataExercise.fromJson(json['exercise'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$TabataItemExerciseToJson(TabataItemExercise instance) =>
    <String, dynamic>{
      'exercise': instance.exercise.toJson(),
      'runtimeType': instance.$type,
    };

TabataItemGroup _$TabataItemGroupFromJson(Map<String, dynamic> json) =>
    TabataItemGroup(
      TabataGroup.fromJson(json['group'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$TabataItemGroupToJson(TabataItemGroup instance) =>
    <String, dynamic>{
      'group': instance.group.toJson(),
      'runtimeType': instance.$type,
    };
