// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Club _$ClubFromJson(Map<String, dynamic> json) => _Club(
  name: json['name'] as String,
  description: json['description'] as String?,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ClubToJson(_Club instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
};
