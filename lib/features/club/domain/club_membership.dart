import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_core/core/data/firestore_converters.dart';

part 'club_membership.freezed.dart';
part 'club_membership.g.dart';

/// Rol van een gebruiker binnen een club.
enum ClubRole {
  player,
  trainer,
  clubAdmin;

  String get label => switch (this) {
    ClubRole.player => 'Speler',
    ClubRole.trainer => 'Trainer',
    ClubRole.clubAdmin => 'Clubadmin',
  };
}

/// Status van een lidmaatschap: in afwachting van goedkeuring of actief.
enum MembershipStatus {
  pending,
  active;

  String get label => switch (this) {
    MembershipStatus.pending => 'In afwachting',
    MembershipStatus.active => 'Actief',
  };
}

/// Lidmaatschap van een gebruiker bij een club.
///
/// Pad: `clubs/{clubId}/members/{uid}` (document-id == uid).
/// `uid` en `clubId` staan ook als velden in het document zodat
/// collection-group queries ("al mijn clubs") mogelijk zijn. Naam en foto
/// zijn gedenormaliseerd zodat ledenlijsten geen extra user-reads nodig hebben.
@freezed
abstract class ClubMembership with _$ClubMembership {
  const factory ClubMembership({
    required String uid,
    required String clubId,
    required String firstName,
    required String lastName,
    String? picture,
    @Default(ClubRole.player)
    @JsonKey(unknownEnumValue: ClubRole.player)
    ClubRole role,
    @Default(MembershipStatus.pending)
    @JsonKey(unknownEnumValue: MembershipStatus.pending)
    MembershipStatus status,
    @Default([]) List<String> teamIds,
    /// Code waarmee dit lid via een uitnodiging is toegetreden (indien van
    /// toepassing) — wordt door de security rules gevalideerd.
    String? inviteCode,
    @NullableTimestampConverter() DateTime? requestedAt,
    @NullableTimestampConverter() DateTime? joinedAt,
  }) = _ClubMembership;

  const ClubMembership._();

  factory ClubMembership.fromJson(Map<String, dynamic> json) =>
      _$ClubMembershipFromJson(json);

  String get fullName => '$firstName $lastName'.trim();

  bool get isPending => status == MembershipStatus.pending;
  bool get isActive => status == MembershipStatus.active;
  bool get isClubAdmin => isActive && role == ClubRole.clubAdmin;
  bool get isTrainerOrAdmin =>
      isActive && (role == ClubRole.trainer || role == ClubRole.clubAdmin);
}
