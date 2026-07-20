import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_content_settings.freezed.dart';
part 'display_content_settings.g.dart';

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
  chrono,
  tabata,
}

/// Represents the content settings for a display.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/content
@freezed
abstract class DisplayContentSettings with _$DisplayContentSettings {
  const factory DisplayContentSettings({
    @Default(DisplayContentType.main)
    @JsonKey(unknownEnumValue: DisplayContentType.main)
    DisplayContentType contentType,
  }) = _DisplayContentSettings;

  factory DisplayContentSettings.fromJson(Map<String, dynamic> json) =>
      _$DisplayContentSettingsFromJson(json);
}
