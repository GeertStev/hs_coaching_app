import 'package:flutter/foundation.dart';

/// Represents the game settings, specifically the scores for two teams.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/game
@immutable
class GameSettings {
  final int blackScore;
  final int whiteScore;

  const GameSettings({this.blackScore = 0, this.whiteScore = 0});

  /// Creates [GameSettings] from a Firestore document map.
  factory GameSettings.fromMap(Map<String, dynamic> data) {
    return GameSettings(
      blackScore: data['blackScore'] as int? ?? 0,
      whiteScore: data['whiteScore'] as int? ?? 0,
    );
  }

  /// Converts [GameSettings] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {'blackScore': blackScore, 'whiteScore': whiteScore};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameSettings &&
        other.blackScore == blackScore &&
        other.whiteScore == whiteScore;
  }

  @override
  int get hashCode => blackScore.hashCode ^ whiteScore.hashCode;
}
