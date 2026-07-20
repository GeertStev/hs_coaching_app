import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings.freezed.dart';
part 'game_settings.g.dart';

/// Represents the game settings, specifically the scores for two teams.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/game
@freezed
abstract class GameSettings with _$GameSettings {
  const factory GameSettings({
    @Default(0) int blackScore,
    @Default(0) int whiteScore,
  }) = _GameSettings;

  factory GameSettings.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsFromJson(json);
}
