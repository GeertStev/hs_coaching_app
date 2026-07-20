// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubTeam _$ClubTeamFromJson(Map<String, dynamic> json) => _ClubTeam(
  name: json['name'] as String,
  description: json['description'] as String?,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ClubTeamToJson(_ClubTeam instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
};
