import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

/// Repository voor het bewerken van het eigen `users/{uid}` profieldocument
/// en de profielfoto in Storage.
class UserProfileRepository {
  UserProfileRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> updateNames({
    required String uid,
    required String firstName,
    required String lastName,
  }) async {
    await _userDoc(
      uid,
    ).update({'firstName': firstName, 'lastName': lastName});
  }

  /// Uploadt een nieuwe profielfoto en slaat de download-URL op.
  Future<String> uploadPicture({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child('user_pictures/$uid.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _userDoc(uid).update({'picture': url});
    return url;
  }

  /// Verwijdert de profielfoto (Storage + veld in het document).
  Future<void> removePicture(String uid) async {
    await _userDoc(uid).update({'picture': null});
    try {
      await _storage.ref().child('user_pictures/$uid.jpg').delete();
    } on FirebaseException catch (e) {
      // Bestond mogelijk niet (bv. extern gehoste foto) — geen probleem.
      if (e.code != 'object-not-found') rethrow;
    }
  }

  /// Vervangt de volledige lijst met persoonlijke gegevens.
  Future<void> setPersonalInfo(String uid, List<PersonalInfo> info) async {
    await _userDoc(uid).update({
      'personalInfo': info.map((i) => i.toJson()).toList(),
    });
  }
}
