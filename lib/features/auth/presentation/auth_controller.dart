import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';

/// Controller voor auth-acties (login, registratie, wachtwoord-reset).
/// Schermen watchen de state voor de loading/error-weergave.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> _guard(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  Future<bool> signIn({required String email, required String password}) {
    return _guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password),
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return _guard(
      () => ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }

  Future<bool> sendPasswordReset(String email) {
    return _guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }

  Future<bool> signOut() {
    return _guard(() => ref.read(authRepositoryProvider).signOut());
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);
