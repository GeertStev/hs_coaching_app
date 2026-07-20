import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';
import 'package:hs_coaching_app/features/club/data/club_providers.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';

/// Controller voor alle club-mutaties (lid worden, beheren, ploegen, invites).
class ClubController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AppUser _requireUser() {
    final user = ref.read(appUserProvider).value;
    if (user == null) throw StateError('Niet ingelogd.');
    return user;
  }

  Future<bool> _guard(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  // ------------------------------------------------------------ Zelf lid

  Future<bool> requestMembership(String clubId) {
    return _guard(
      () => ref
          .read(clubRepositoryProvider)
          .requestMembership(clubId: clubId, user: _requireUser()),
    );
  }

  Future<bool> joinWithInviteCode(String code) {
    return _guard(
      () async => ref
          .read(clubRepositoryProvider)
          .joinWithInviteCode(code: code, user: _requireUser()),
    );
  }

  Future<bool> leaveClub(String clubId) {
    return _guard(
      () => ref
          .read(clubRepositoryProvider)
          .removeMembership(clubId, _requireUser().uid),
    );
  }

  Future<bool> createClub({required String name, String? description}) {
    return _guard(
      () async => ref
          .read(clubRepositoryProvider)
          .createClub(name: name, description: description, creator: _requireUser()),
    );
  }

  // ------------------------------------------------------------- Beheer

  Future<bool> approveMembership(String clubId, String uid) {
    return _guard(
      () => ref.read(clubRepositoryProvider).approveMembership(clubId, uid),
    );
  }

  Future<bool> removeMembership(String clubId, String uid) {
    return _guard(
      () => ref.read(clubRepositoryProvider).removeMembership(clubId, uid),
    );
  }

  Future<bool> updateMemberRole(String clubId, String uid, ClubRole role) {
    return _guard(
      () => ref
          .read(clubRepositoryProvider)
          .updateMemberRole(clubId, uid, role),
    );
  }

  Future<bool> updateMemberTeams(
    String clubId,
    String uid,
    List<String> teamIds,
  ) {
    return _guard(
      () => ref
          .read(clubRepositoryProvider)
          .updateMemberTeams(clubId, uid, teamIds),
    );
  }

  Future<bool> addTeam(String clubId, String name) {
    return _guard(() => ref.read(clubRepositoryProvider).addTeam(clubId, name));
  }

  Future<bool> renameTeam(String clubId, String teamId, String name) {
    return _guard(
      () => ref.read(clubRepositoryProvider).renameTeam(clubId, teamId, name),
    );
  }

  Future<bool> deleteTeam(String clubId, String teamId) {
    return _guard(
      () => ref.read(clubRepositoryProvider).deleteTeam(clubId, teamId),
    );
  }

  /// Maakt een uitnodiging aan en geeft de code terug (of `null` bij fout).
  Future<String?> createInvite({
    required String clubId,
    required ClubRole role,
    DateTime? expiresAt,
  }) async {
    state = const AsyncLoading();
    String? code;
    state = await AsyncValue.guard(() async {
      code = await ref
          .read(clubRepositoryProvider)
          .createInvite(
            clubId: clubId,
            role: role,
            createdByUid: _requireUser().uid,
            expiresAt: expiresAt,
          );
    });
    return state.hasError ? null : code;
  }

  Future<bool> setInviteActive(String clubId, String code, bool active) {
    return _guard(
      () => ref
          .read(clubRepositoryProvider)
          .setInviteActive(clubId, code, active),
    );
  }

  Future<bool> deleteInvite(String clubId, String code) {
    return _guard(
      () => ref.read(clubRepositoryProvider).deleteInvite(clubId, code),
    );
  }
}

final clubControllerProvider =
    AsyncNotifierProvider.autoDispose<ClubController, void>(ClubController.new);
