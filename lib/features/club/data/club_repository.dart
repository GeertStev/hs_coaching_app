import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';
import 'package:hs_coaching_app/features/club/domain/club.dart';
import 'package:hs_coaching_app/features/club/domain/club_invite.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';
import 'package:hs_coaching_app/features/club/domain/club_team.dart';

/// Fout met een gebruikersvriendelijke (Nederlandse) melding uit de club-flow.
class ClubException implements Exception {
  ClubException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Repository voor clubs, lidmaatschappen, ploegen en uitnodigingen.
///
/// Firestore-structuur:
/// ```
/// clubs/{clubId}                       # Club
///   members/{uid}                      # ClubMembership (uid == doc-id)
///   teams/{teamId}                     # ClubTeam
///   invites/{code}                     # ClubInvite (beheer, alleen admin)
/// inviteCodes/{code}                   # spiegel voor de join-flow: iedere
///                                      # ingelogde gebruiker mag dit per code
///                                      # opvragen (get, geen list)
/// ```
class ClubRepository {
  ClubRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clubs =>
      _firestore.collection('clubs');

  CollectionReference<Map<String, dynamic>> _members(String clubId) =>
      _clubs.doc(clubId).collection('members');

  CollectionReference<Map<String, dynamic>> _teams(String clubId) =>
      _clubs.doc(clubId).collection('teams');

  CollectionReference<Map<String, dynamic>> _invites(String clubId) =>
      _clubs.doc(clubId).collection('invites');

  DocumentReference<Map<String, dynamic>> _inviteCode(String code) =>
      _firestore.collection('inviteCodes').doc(code);

  Club _clubFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Club.fromJson(doc.data()!).copyWith(id: doc.id);

  ClubMembership _membershipFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => ClubMembership.fromJson(doc.data()!);

  // ---------------------------------------------------------------- Clubs

  Stream<List<Club>> watchAllClubs() {
    return _clubs
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(_clubFromDoc).toList());
  }

  Stream<Club?> watchClub(String clubId) {
    return _clubs.doc(clubId).snapshots().map(
      (doc) => doc.exists && doc.data() != null ? _clubFromDoc(doc) : null,
    );
  }

  /// Maakt een nieuwe club aan; de oprichter wordt meteen actieve clubadmin.
  Future<String> createClub({
    required String name,
    String? description,
    required AppUser creator,
  }) async {
    final clubDoc = _clubs.doc();
    final batch = _firestore.batch();
    batch.set(clubDoc, {
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      clubDoc.collection('members').doc(creator.uid),
      _membershipData(
        uid: creator.uid,
        clubId: clubDoc.id,
        user: creator,
        role: ClubRole.clubAdmin,
        status: MembershipStatus.active,
        joined: true,
      ),
    );
    await batch.commit();
    return clubDoc.id;
  }

  // ----------------------------------------------------------- Memberships

  Map<String, dynamic> _membershipData({
    required String uid,
    required String clubId,
    required AppUser user,
    required ClubRole role,
    required MembershipStatus status,
    bool joined = false,
    String? inviteCode,
  }) {
    return {
      'uid': uid,
      'clubId': clubId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'picture': user.picture,
      'role': role.name,
      'status': status.name,
      'teamIds': <String>[],
      'inviteCode': ?inviteCode,
      'requestedAt': FieldValue.serverTimestamp(),
      if (joined) 'joinedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Alle lidmaatschappen (alle clubs) van één gebruiker.
  ///
  /// Let op: dit is een collection-group query op `members.uid`; hiervoor
  /// moet in Firestore een collection-group index op `uid` bestaan.
  Stream<List<ClubMembership>> watchMembershipsForUser(String uid) {
    return _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(_membershipFromDoc).toList());
  }

  /// Alle leden (actief én in afwachting) van een club.
  Stream<List<ClubMembership>> watchMembers(String clubId) {
    return _members(clubId).snapshots().map((snap) {
      final members = snap.docs.map(_membershipFromDoc).toList();
      members.sort(
        (a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
      return members;
    });
  }

  /// Vraagt lidmaatschap aan bij een club (status: in afwachting).
  Future<void> requestMembership({
    required String clubId,
    required AppUser user,
  }) async {
    final doc = await _members(clubId).doc(user.uid).get();
    if (doc.exists) {
      final existing = _membershipFromDoc(doc);
      throw ClubException(
        existing.isPending
            ? 'Je hebt al een aanvraag lopen bij deze club.'
            : 'Je bent al lid van deze club.',
      );
    }
    await _members(clubId)
        .doc(user.uid)
        .set(
          _membershipData(
            uid: user.uid,
            clubId: clubId,
            user: user,
            role: ClubRole.player,
            status: MembershipStatus.pending,
          ),
        );
  }

  /// Treedt toe met een uitnodigingscode; geeft de clubId terug.
  Future<String> joinWithInviteCode({
    required String code,
    required AppUser user,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) throw ClubException('Vul een code in.');

    final doc = await _inviteCode(normalized).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      throw ClubException('Deze uitnodigingscode bestaat niet.');
    }
    if (data['active'] != true) {
      throw ClubException('Deze uitnodigingscode is niet meer geldig.');
    }
    final expiresAt = data['expiresAt'];
    if (expiresAt is Timestamp &&
        DateTime.now().isAfter(expiresAt.toDate())) {
      throw ClubException('Deze uitnodigingscode is verlopen.');
    }
    final clubId = data['clubId'] as String?;
    if (clubId == null) {
      throw ClubException('Deze uitnodigingscode is ongeldig.');
    }

    final memberDoc = await _members(clubId).doc(user.uid).get();
    if (memberDoc.exists && _membershipFromDoc(memberDoc).isActive) {
      throw ClubException('Je bent al lid van deze club.');
    }

    final role = ClubRole.values.firstWhere(
      (r) => r.name == data['role'],
      orElse: () => ClubRole.player,
    );
    await _members(clubId)
        .doc(user.uid)
        .set(
          _membershipData(
            uid: user.uid,
            clubId: clubId,
            user: user,
            role: role,
            status: MembershipStatus.active,
            joined: true,
            inviteCode: normalized,
          ),
        );
    return clubId;
  }

  /// Keurt een aanvraag goed (clubadmin).
  Future<void> approveMembership(String clubId, String uid) async {
    await _members(clubId).doc(uid).update({
      'status': MembershipStatus.active.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Verwijdert een lidmaatschap: aanvraag weigeren, lid verwijderen of
  /// zelf de club verlaten.
  Future<void> removeMembership(String clubId, String uid) async {
    await _members(clubId).doc(uid).delete();
  }

  Future<void> updateMemberRole(
    String clubId,
    String uid,
    ClubRole role,
  ) async {
    await _members(clubId).doc(uid).update({'role': role.name});
  }

  /// Deelt een lid in bij ploegen (vervangt de volledige indeling).
  Future<void> updateMemberTeams(
    String clubId,
    String uid,
    List<String> teamIds,
  ) async {
    await _members(clubId).doc(uid).update({'teamIds': teamIds});
  }

  // ---------------------------------------------------------------- Teams

  Stream<List<ClubTeam>> watchTeams(String clubId) {
    return _teams(clubId).orderBy('name').snapshots().map(
      (snap) => snap.docs
          .map((doc) => ClubTeam.fromJson(doc.data()).copyWith(id: doc.id))
          .toList(),
    );
  }

  Future<void> addTeam(String clubId, String name) async {
    await _teams(clubId).add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> renameTeam(String clubId, String teamId, String name) async {
    await _teams(clubId).doc(teamId).update({'name': name});
  }

  /// Verwijdert een ploeg en haalt die in dezelfde batch uit de indeling van
  /// alle leden.
  Future<void> deleteTeam(String clubId, String teamId) async {
    final members = await _members(
      clubId,
    ).where('teamIds', arrayContains: teamId).get();
    final batch = _firestore.batch();
    for (final doc in members.docs) {
      batch.update(doc.reference, {
        'teamIds': FieldValue.arrayRemove([teamId]),
      });
    }
    batch.delete(_teams(clubId).doc(teamId));
    await batch.commit();
  }

  // -------------------------------------------------------------- Invites

  Stream<List<ClubInvite>> watchInvites(String clubId) {
    return _invites(clubId).snapshots().map((snap) {
      final invites = snap.docs
          .map((doc) => ClubInvite.fromJson(doc.data()).copyWith(code: doc.id))
          .toList();
      invites.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(2000);
        final bTime = b.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return invites;
    });
  }

  /// Genereert een nieuwe uitnodigingscode. De code (het geheim) wordt ook
  /// als spiegel-document onder `inviteCodes/{code}` gezet zodat de
  /// join-flow hem per code kan opvragen.
  Future<String> createInvite({
    required String clubId,
    required ClubRole role,
    required String createdByUid,
    DateTime? expiresAt,
  }) async {
    final code = _generateCode();
    final batch = _firestore.batch();
    batch.set(_invites(clubId).doc(code), {
      'clubId': clubId,
      'role': role.name,
      'createdByUid': createdByUid,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
    });
    batch.set(_inviteCode(code), {
      'clubId': clubId,
      'role': role.name,
      'active': true,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
    });
    await batch.commit();
    return code;
  }

  Future<void> setInviteActive(
    String clubId,
    String code,
    bool active,
  ) async {
    final batch = _firestore.batch();
    batch.update(_invites(clubId).doc(code), {'active': active});
    batch.update(_inviteCode(code), {'active': active});
    await batch.commit();
  }

  Future<void> deleteInvite(String clubId, String code) async {
    final batch = _firestore.batch();
    batch.delete(_invites(clubId).doc(code));
    batch.delete(_inviteCode(code));
    await batch.commit();
  }

  /// 8 tekens uit een alfabet zonder verwarrende tekens (geen 0/O, 1/I).
  String _generateCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      8,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}
