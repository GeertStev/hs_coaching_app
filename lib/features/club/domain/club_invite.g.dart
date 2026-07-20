// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubInvite _$ClubInviteFromJson(Map<String, dynamic> json) => _ClubInvite(
  clubId: json['clubId'] as String,
  role:
      $enumDecodeNullable(
        _$ClubRoleEnumMap,
        json['role'],
        unknownValue: ClubRole.player,
      ) ??
      ClubRole.player,
  createdByUid: json['createdByUid'] as String,
  active: json['active'] as bool? ?? true,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  expiresAt: const NullableTimestampConverter().fromJson(json['expiresAt']),
);

Map<String, dynamic> _$ClubInviteToJson(
  _ClubInvite instance,
) => <String, dynamic>{
  'clubId': instance.clubId,
  'role': _$ClubRoleEnumMap[instance.role]!,
  'createdByUid': instance.createdByUid,
  'active': instance.active,
  'createdAt': const NullableTimestampConverter().toJson(instance.createdAt),
  'expiresAt': const NullableTimestampConverter().toJson(instance.expiresAt),
};

const _$ClubRoleEnumMap = {
  ClubRole.player: 'player',
  ClubRole.trainer: 'trainer',
  ClubRole.clubAdmin: 'clubAdmin',
};
