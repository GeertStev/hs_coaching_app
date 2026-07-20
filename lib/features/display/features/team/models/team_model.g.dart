// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  teamColor: $enumDecode(_$TeamColorEnumMap, json['teamColor']),
  front: (json['front'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  center: (json['center'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  wing: (json['wing'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  goalie: (json['goalie'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'teamColor': _$TeamColorEnumMap[instance.teamColor]!,
  'front': instance.front,
  'center': instance.center,
  'wing': instance.wing,
  'goalie': instance.goalie,
};

const _$TeamColorEnumMap = {TeamColor.white: 'white', TeamColor.black: 'black'};
