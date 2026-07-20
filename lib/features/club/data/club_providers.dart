import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/club/data/club_repository.dart';
import 'package:hs_coaching_app/features/club/domain/club.dart';
import 'package:hs_coaching_app/features/club/domain/club_invite.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';
import 'package:hs_coaching_app/features/club/domain/club_team.dart';

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository(ref.watch(firebaseFirestoreProvider));
});

/// Alle lidmaatschappen (alle clubs, incl. aanvragen) van de ingelogde
/// gebruiker.
final myMembershipsProvider = StreamProvider<List<ClubMembership>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(clubRepositoryProvider).watchMembershipsForUser(uid);
});

/// Alle clubs (voor de "sluit je aan"-flow).
final allClubsProvider = StreamProvider<List<Club>>((ref) {
  return ref.watch(clubRepositoryProvider).watchAllClubs();
});

final clubProvider = StreamProvider.autoDispose.family<Club?, String>((
  ref,
  clubId,
) {
  return ref.watch(clubRepositoryProvider).watchClub(clubId);
});

final clubMembersProvider = StreamProvider.autoDispose
    .family<List<ClubMembership>, String>((ref, clubId) {
      return ref.watch(clubRepositoryProvider).watchMembers(clubId);
    });

final clubTeamsProvider = StreamProvider.autoDispose
    .family<List<ClubTeam>, String>((ref, clubId) {
      return ref.watch(clubRepositoryProvider).watchTeams(clubId);
    });

final clubInvitesProvider = StreamProvider.autoDispose
    .family<List<ClubInvite>, String>((ref, clubId) {
      return ref.watch(clubRepositoryProvider).watchInvites(clubId);
    });

/// Het eigen lidmaatschap binnen één club (of `null`).
final myMembershipForClubProvider = Provider.autoDispose
    .family<ClubMembership?, String>((ref, clubId) {
      final memberships = ref.watch(myMembershipsProvider).value ?? const [];
      for (final membership in memberships) {
        if (membership.clubId == clubId) return membership;
      }
      return null;
    });
