import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';

part 'club_team.freezed.dart';
part 'club_team.g.dart';

/// Een ploeg binnen een club (bv. "Heren A", "Jeugd").
///
/// Pad: `clubs/{clubId}/teams/{teamId}`. Spelers worden aan ploegen gekoppeld
/// via `ClubMembership.teamIds` (indeling door de clubadmin).
@freezed
abstract class ClubTeam with _$ClubTeam {
  const factory ClubTeam({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    required String name,
    String? description,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _ClubTeam;

  factory ClubTeam.fromJson(Map<String, dynamic> json) =>
      _$ClubTeamFromJson(json);
}
