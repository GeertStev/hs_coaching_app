// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_global_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayGlobalSettings _$DisplayGlobalSettingsFromJson(
  Map<String, dynamic> json,
) => _DisplayGlobalSettings(
  clubName: json['clubName'] as String? ?? 'Club name',
  clubLogoUrl: json['clubLogoUrl'] as String? ?? '',
  clubWebsite: json['clubWebsite'] as String? ?? 'www.club.uwh',
  width: (json['width'] as num?)?.toInt() ?? 800,
  height: (json['height'] as num?)?.toInt() ?? 600,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['main'],
  subscriptionEnd: const SubscriptionEndConverter().fromJson(
    json['subscriptionEnd'],
  ),
  primaryColor: const ColorFromHexConverter.blue().fromJson(
    json['primaryColor'] as String?,
  ),
  secondaryColor: const ColorFromHexConverter.green().fromJson(
    json['secondaryColor'] as String?,
  ),
  tertiaryColor: const ColorFromHexConverter.amber().fromJson(
    json['tertiaryColor'] as String?,
  ),
  backgroundColor: const ColorFromHexConverter.black().fromJson(
    json['backgroundColor'] as String?,
  ),
);

Map<String, dynamic> _$DisplayGlobalSettingsToJson(
  _DisplayGlobalSettings instance,
) => <String, dynamic>{
  'clubName': instance.clubName,
  'clubLogoUrl': instance.clubLogoUrl,
  'clubWebsite': instance.clubWebsite,
  'width': instance.width,
  'height': instance.height,
  'features': instance.features,
  'subscriptionEnd': const SubscriptionEndConverter().toJson(
    instance.subscriptionEnd,
  ),
  'primaryColor': const ColorFromHexConverter.blue().toJson(
    instance.primaryColor,
  ),
  'secondaryColor': const ColorFromHexConverter.green().toJson(
    instance.secondaryColor,
  ),
  'tertiaryColor': const ColorFromHexConverter.amber().toJson(
    instance.tertiaryColor,
  ),
  'backgroundColor': const ColorFromHexConverter.black().toJson(
    instance.backgroundColor,
  ),
};
