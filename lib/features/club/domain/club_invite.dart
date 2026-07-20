import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';

part 'club_invite.freezed.dart';
part 'club_invite.g.dart';

/// Uitnodiging om tot een club toe te treden.
///
/// Beheerd door de clubadmin onder `clubs/{clubId}/invites/{code}`.
/// Voor de join-flow bestaat een spiegel-document `inviteCodes/{code}`
/// (top-level) dat elke ingelogde gebruiker per code mag opvragen (get, geen
/// list) — de code zelf is het geheim.
@freezed
abstract class ClubInvite with _$ClubInvite {
  const factory ClubInvite({
    /// De code is tevens de document-id.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String code,
    required String clubId,
    @Default(ClubRole.player)
    @JsonKey(unknownEnumValue: ClubRole.player)
    ClubRole role,
    required String createdByUid,
    @Default(true) bool active,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? expiresAt,
  }) = _ClubInvite;

  const ClubInvite._();

  factory ClubInvite.fromJson(Map<String, dynamic> json) =>
      _$ClubInviteFromJson(json);

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isUsable => active && !isExpired;
}
