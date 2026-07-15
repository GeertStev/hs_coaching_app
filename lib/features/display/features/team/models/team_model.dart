import 'package:hs_coaching_app/features/display/features/team/models/player_model.dart';

enum TeamColor { white, black }

enum TeamPositions { front, center, wing, goalie }

class Team {
  Team({
    required this.teamColor,
    required this.front,
    required this.center,
    required this.wing,
    required this.goalie,
  });
  final TeamColor teamColor;
  final List<Player> front;
  final List<Player> center;
  final List<Player> wing;
  final List<Player> goalie;

  factory Team.fromJson(Map<String, dynamic> data, TeamColor teamColor) {
    final team = data[teamColor.name] as Map<String, dynamic>;

    final frontData = team['front'] as List<dynamic>?;
    final centerData = team['center'] as List<dynamic>?;
    final wingData = team['wing'] as List<dynamic>?;
    final goalieData = team['goalie'] as List<dynamic>?;

    return Team(
      teamColor: teamColor,
      front: frontData != null
          ? frontData
                .map((player) => Player.fromString(player as String))
                .toList()
          : <Player>[],
      center: centerData != null
          ? centerData
                .map((player) => Player.fromString(player as String))
                .toList()
          : <Player>[],
      wing: wingData != null
          ? wingData
                .map((player) => Player.fromString(player as String))
                .toList()
          : <Player>[],
      goalie: goalieData != null
          ? goalieData
                .map((player) => Player.fromString(player as String))
                .toList()
          : <Player>[],
    );
  }
}
