import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Represents the static global settings for a display.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/global
@immutable
class DisplayGlobalSettings {
  final String clubName;
  final String clubLogoUrl;
  final String clubWebsite;
  final int width;
  final int height;
  final List<String> features;
  final DateTime subscriptionEnd;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color backgroundColor;

  const DisplayGlobalSettings({
    required this.clubName,
    required this.clubLogoUrl,
    required this.clubWebsite,
    required this.width,
    required this.height,
    required this.features,
    required this.subscriptionEnd,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.backgroundColor,
  });

  /// Creates [GlobalSettings] from a Firestore document map.
  factory DisplayGlobalSettings.fromMap(Map<String, dynamic> data) {
    // Helper to parse color from hex string or return a default
    Color colorFromHex(String? hexColor, Color defaultColor) {
      if (hexColor == null || hexColor.isEmpty) return defaultColor;
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    return DisplayGlobalSettings(
      clubName: data['clubName'] as String? ?? 'Club name',
      // ToDo Logo dummy
      clubLogoUrl: data['clubLogoUrl'] as String? ?? '',
      clubWebsite: data['clubWebsite'] as String? ?? 'www.club.uwh',
      width: data['width'] as int? ?? 800,
      height: data['height'] as int? ?? 600,
      features: List<String>.from(data['features'] as List? ?? ['main']),
      subscriptionEnd:
          (data['subscriptionEnd'] as Timestamp? ?? Timestamp.now())
              .toDate()
              .add(const Duration(days: 30)),
      primaryColor: colorFromHex(data['primaryColor'] as String?, Colors.blue),
      secondaryColor: colorFromHex(
        data['secondaryColor'] as String?,
        Colors.green,
      ),
      tertiaryColor: colorFromHex(
        data['tertiaryColor'] as String?,
        Colors.amber,
      ),
      backgroundColor: colorFromHex(
        data['backgroundColor'] as String?,
        Colors.black,
      ),
    );
  }

  @override
  String toString() {
    return 'GlobalSettings(clubName: $clubName, clubLogoUrl: $clubLogoUrl, clubWebsite: $clubWebsite, width: $width, height: $height, features: $features, subscriptionEnd: $subscriptionEnd)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DisplayGlobalSettings &&
        other.clubName == clubName &&
        other.clubLogoUrl == clubLogoUrl &&
        other.clubWebsite == clubWebsite &&
        other.width == width &&
        other.height == height &&
        listEquals(other.features, features) &&
        other.subscriptionEnd == subscriptionEnd &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.tertiaryColor == tertiaryColor &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode {
    return clubName.hashCode ^
        clubLogoUrl.hashCode ^
        clubWebsite.hashCode ^
        width.hashCode ^
        height.hashCode ^
        features.hashCode ^
        subscriptionEnd.hashCode ^
        primaryColor.hashCode ^
        secondaryColor.hashCode ^
        tertiaryColor.hashCode ^
        backgroundColor.hashCode;
  }
}
