// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameSettings _$GameSettingsFromJson(Map<String, dynamic> json) =>
    _GameSettings(
      blackScore: (json['blackScore'] as num?)?.toInt() ?? 0,
      whiteScore: (json['whiteScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GameSettingsToJson(_GameSettings instance) =>
    <String, dynamic>{
      'blackScore': instance.blackScore,
      'whiteScore': instance.whiteScore,
    };
