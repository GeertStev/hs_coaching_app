import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_model.freezed.dart';
part 'player_model.g.dart';

/// Represents a single player.
@freezed
abstract class Player with _$Player {
  const factory Player({required String name}) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// Creates a Player from a simple string.
  /// ToDo: This is for compatibility with the current Google Script data source.
  /// It should be removed when switching to a structured data source like Firebase.
  factory Player.fromString(String name) {
    if (name.isEmpty) {
      throw const FormatException('Invalid data: player name cannot be empty.');
    }
    return Player(name: name);
  }
}
