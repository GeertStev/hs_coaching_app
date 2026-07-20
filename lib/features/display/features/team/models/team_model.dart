import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/features/display/features/team/models/player_model.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

enum TeamColor { white, black }

enum TeamPositions { front, center, wing, goalie }

@freezed
abstract class Team with _$Team {
  const factory Team({
    required TeamColor teamColor,
    required List<Player> front,
    required List<Player> center,
    required List<Player> wing,
    required List<Player> goalie,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  /// Parses one team's roster out of the shared Google Apps Script response,
  /// which nests both teams under their color as key and lists players as
  /// plain name strings.
  factory Team.fromGoogleScriptResponse(
    Map<String, dynamic> data,
    TeamColor teamColor,
  ) {
    final team = data[teamColor.name] as Map<String, dynamic>;

    List<Player> playersFor(String position) {
      final raw = team[position] as List<dynamic>?;
      return raw?.map((player) => Player.fromString(player as String)).toList() ??
          <Player>[];
    }

    return Team(
      teamColor: teamColor,
      front: playersFor('front'),
      center: playersFor('center'),
      wing: playersFor('wing'),
      goalie: playersFor('goalie'),
    );
  }
}
