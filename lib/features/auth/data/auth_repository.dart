import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';

/// Repository voor authenticatie en het bijbehorende `users/{uid}` document.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<fb_auth.User?> authStateChanges() => _auth.authStateChanges();

  fb_auth.User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // lastLogin bijwerken; mislukt dit (bv. offline), dan mag de login zelf
    // niet falen.
    final uid = credential.user?.uid;
    if (uid != null) {
      try {
        await _userDoc(uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Bewust genegeerd: login is al geslaagd.
      }
    }
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

    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed: No user returned.');
    }

    final newUser = AppUser(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      lastLogin: DateTime.now(),
    );

    await _userDoc(user.uid).set(newUser.toJson());
    await user.updateDisplayName('$firstName $lastName');

    // Verificatiemail versturen; niet blokkerend voor de signup-flow.
    try {
      await user.sendEmailVerification();
    } catch (_) {
      // Kan later opnieuw vanuit het profielscherm.
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Herlaadt de Firebase-gebruiker (om o.a. `emailVerified` te verversen).
  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Wachtwoord wijzigen; vereist het huidige wachtwoord (re-authenticatie).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    await _reauthenticate(user, currentPassword);
    await user.updatePassword(newPassword);
  }

  /// Verwijdert het account definitief; vereist het huidige wachtwoord.
  /// Het user-document wordt eerst verwijderd (daarna vervalt de autorisatie).
  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _requireUser();
    await _reauthenticate(user, currentPassword);
    await _userDoc(user.uid).delete();
    await user.delete();
  }

  fb_auth.User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw fb_auth.FirebaseAuthException(code: 'requires-recent-login');
    }
    return user;
  }

  Future<void> _reauthenticate(fb_auth.User user, String password) async {
    final email = user.email;
    if (email == null) {
      throw fb_auth.FirebaseAuthException(code: 'requires-recent-login');
    }
    await user.reauthenticateWithCredential(
      fb_auth.EmailAuthProvider.credential(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<AppUser?> userStream(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (snapshot.exists && data != null) {
        return AppUser.fromJson(data).copyWith(uid: snapshot.id);
      }
      return null;
    });
  }
}
