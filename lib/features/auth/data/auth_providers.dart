import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/auth/data/auth_repository.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';

/// Provides the raw `FirebaseAuth` instance.
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>(
  (ref) => fb_auth.FirebaseAuth.instance,
);

/// Provides an instance of [AuthRepository] for authentication-related
/// operations.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  ),
);

/// A stream provider that emits the current Firebase authentication user state.
///
/// Emits a `User` object when a user is signed in, and `null` when they are
/// signed out. This is the primary way to listen for authentication changes.
final authStateChangesProvider = StreamProvider<fb_auth.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// A stream provider that watches the current authenticated user's `AppUser`
/// document in Firestore.
///
/// It depends on [authStateChangesProvider] to get the current user's UID.
/// If no user is logged in, it streams `null`.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final uid = authState.asData?.value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).userStream(uid);
});

/// De uid van de ingelogde gebruiker, of `null` als niemand is ingelogd.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).asData?.value?.uid;
});
