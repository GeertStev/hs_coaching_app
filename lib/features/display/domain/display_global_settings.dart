import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_global_settings.freezed.dart';
part 'display_global_settings.g.dart';

/// Represents the static global settings for a display.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/global
@freezed
abstract class DisplayGlobalSettings with _$DisplayGlobalSettings {
  const factory DisplayGlobalSettings({
    @Default('Club name') String clubName,
    @Default('') String clubLogoUrl,
    @Default('www.club.uwh') String clubWebsite,
    @Default(800) int width,
    @Default(600) int height,
    @Default(['main']) List<String> features,
    @SubscriptionEndConverter() required DateTime subscriptionEnd,
    @ColorFromHexConverter.blue() required Color primaryColor,
    @ColorFromHexConverter.green() required Color secondaryColor,
    @ColorFromHexConverter.amber() required Color tertiaryColor,
    @ColorFromHexConverter.black() required Color backgroundColor,
  }) = _DisplayGlobalSettings;

  factory DisplayGlobalSettings.fromJson(Map<String, dynamic> json) =>
      _$DisplayGlobalSettingsFromJson(json);
}

/// Adds a 30-day grace period on top of the stored subscription end date.
class SubscriptionEndConverter implements JsonConverter<DateTime, Object?> {
  const SubscriptionEndConverter();

  @override
  DateTime fromJson(Object? json) {
    final timestamp = json is Timestamp ? json : Timestamp.now();
    return timestamp.toDate().add(const Duration(days: 30));
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

/// Parses a `#RRGGBB` / `#AARRGGBB` hex string into a [Color], falling back
/// to [defaultColor] when the value is missing or empty.
class ColorFromHexConverter implements JsonConverter<Color, String?> {
  const ColorFromHexConverter._(this.defaultColor);
  const ColorFromHexConverter.blue() : this._(Colors.blue);
  const ColorFromHexConverter.green() : this._(Colors.green);
  const ColorFromHexConverter.amber() : this._(Colors.amber);
  const ColorFromHexConverter.black() : this._(Colors.black);

  final Color defaultColor;

  @override
  Color fromJson(String? json) {
    if (json == null || json.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    if (json.length == 6 || json.length == 7) buffer.write('ff');
    buffer.write(json.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  String toJson(Color object) =>
      '#${object.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}
