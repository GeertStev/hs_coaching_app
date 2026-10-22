import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hs_coaching_core/core/errors/user_message.dart';

/// Vertaalt auth-fouten naar een begrijpelijke Engelse melding, zonder
/// technische details of geheimen te lekken. Wat hier niet specifiek is,
/// valt terug op core's [userMessage].
String authErrorMessage(Object? error) {
  if (error is fb_auth.FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email address or password is incorrect.';
      case 'invalid-email':
        return 'This is not a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email address already exists.';
      case 'weak-password':
        return 'The password is too weak. Choose a stronger password.';
      case 'requires-recent-login':
        return 'Sign in again to perform this action.';
      case 'operation-not-allowed':
        return 'This action is not allowed.';
    }
  }
  if (error is FormatException || error is StateError) {
    return error.toString().replaceFirst(RegExp(r'^\w+Exception?: '), '');
  }
  return userMessage(error);
}

/// Validators voor formuliervelden.
abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter an email address.';
    if (!_emailRegex.hasMatch(v)) return 'This is not a valid email address.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter a password.';
    return null;
  }

  /// Voor nieuwe wachtwoorden: minimaal 8 tekens, met letter en cijfer.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter a password.';
    if (v.length < 8) return 'At least 8 characters.';
    if (!v.contains(RegExp(r'[A-Za-z]')) || !v.contains(RegExp(r'[0-9]'))) {
      return 'Use at least one letter and one digit.';
    }
    return null;
  }

  static String? requiredField(String? value, {String label = 'this field'}) {
    if (value == null || value.trim().isEmpty) return 'Enter $label.';
    return null;
  }
}
