import 'package:flutter/foundation.dart';

/// The type of content to be displayed on the screen.
enum DisplayContentType {
  main,
  drawing,
  game,
  image,
  sketch,
  team,
  text,
  timer,
  chrono;

  /// Creates a [ScreenContentType] from a string.
  ///
  /// Defaults to [ScreenContentType.main] if the string is null or invalid.
  static DisplayContentType fromString(String? value) {
    if (value == null) return DisplayContentType.main;
    return DisplayContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DisplayContentType.main,
    );
  }
}

/// Represents the content settings for a display.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/content
@immutable
class DisplayContentSettings {
  final DisplayContentType contentType;

  const DisplayContentSettings({required this.contentType});

  /// Creates [ScreenContentSettings] from a Firestore document map.
  factory DisplayContentSettings.fromMap(Map<String, dynamic> data) {
    return DisplayContentSettings(
      contentType: DisplayContentType.fromString(
        data['contentType'] as String?,
      ),
    );
  }

  /// Converts [ScreenContentSettings] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {'contentType': contentType.name};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DisplayContentSettings && other.contentType == contentType;
  }

  @override
  int get hashCode => contentType.hashCode;
}
