// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubMembership _$ClubMembershipFromJson(
  Map<String, dynamic> json,
) => _ClubMembership(
  uid: json['uid'] as String,
  clubId: json['clubId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  picture: json['picture'] as String?,
  role:
      $enumDecodeNullable(
        _$ClubRoleEnumMap,
        json['role'],
        unknownValue: ClubRole.player,
      ) ??
      ClubRole.player,
  status:
      $enumDecodeNullable(
        _$MembershipStatusEnumMap,
        json['status'],
        unknownValue: MembershipStatus.pending,
      ) ??
      MembershipStatus.pending,
  teamIds:
      (json['teamIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  inviteCode: json['inviteCode'] as String?,
  requestedAt: const NullableTimestampConverter().fromJson(json['requestedAt']),
  joinedAt: const NullableTimestampConverter().fromJson(json['joinedAt']),
);

Map<String, dynamic> _$ClubMembershipToJson(_ClubMembership instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'clubId': instance.clubId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'picture': instance.picture,
      'role': _$ClubRoleEnumMap[instance.role]!,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'teamIds': instance.teamIds,
      'inviteCode': instance.inviteCode,
      'requestedAt': const NullableTimestampConverter().toJson(
        instance.requestedAt,
      ),
      'joinedAt': const NullableTimestampConverter().toJson(instance.joinedAt),
    };

const _$ClubRoleEnumMap = {
  ClubRole.player: 'player',
  ClubRole.trainer: 'trainer',
  ClubRole.clubAdmin: 'clubAdmin',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pending: 'pending',
  MembershipStatus.active: 'active',
};
