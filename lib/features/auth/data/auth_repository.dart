import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<fb_auth.User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('User creation failed: No user returned.');
    }

    final newUser = AppUser(
      uid: userCredential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      role: 'user', // Default role
      lastLogin: DateTime.now(),
    );

    await _createUserDocument(newUser);
  }

  Future<void> _createUserDocument(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<AppUser?> userStream(String uid) {
    final docRef = _firestore.collection('users').doc(uid);
    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromJson(snapshot.data()!).copyWith(uid: snapshot.id);
      }
      return null;
    });
  }
}
