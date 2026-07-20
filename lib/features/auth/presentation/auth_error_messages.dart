import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Vertaalt (auth-)fouten naar een begrijpelijke Nederlandse melding, zonder
/// technische details of geheimen te lekken.
String authErrorMessage(Object error) {
  if (error is fb_auth.FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-mailadres of wachtwoord is onjuist.';
      case 'invalid-email':
        return 'Dit is geen geldig e-mailadres.';
      case 'user-disabled':
        return 'Dit account is uitgeschakeld.';
      case 'email-already-in-use':
        return 'Er bestaat al een account met dit e-mailadres.';
      case 'weak-password':
        return 'Het wachtwoord is te zwak. Kies een sterker wachtwoord.';
      case 'too-many-requests':
        return 'Te veel pogingen. Probeer het later opnieuw.';
      case 'network-request-failed':
        return 'Netwerkfout. Controleer je internetverbinding.';
      case 'requires-recent-login':
        return 'Log opnieuw in om deze actie uit te voeren.';
      case 'operation-not-allowed':
        return 'Deze actie is niet toegestaan.';
      default:
        return 'Er is een fout opgetreden (${error.code}).';
    }
  }
  if (error is FormatException || error is StateError) {
    return error.toString().replaceFirst(RegExp(r'^\w+Exception?: '), '');
  }
  return 'Er is een onverwachte fout opgetreden.';
}

/// Validators voor formuliervelden.
abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vul een e-mailadres in.';
    if (!_emailRegex.hasMatch(v)) return 'Dit is geen geldig e-mailadres.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vul een wachtwoord in.';
    return null;
  }

  /// Voor nieuwe wachtwoorden: minimaal 8 tekens, met letter en cijfer.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vul een wachtwoord in.';
    if (v.length < 8) return 'Minimaal 8 tekens.';
    if (!v.contains(RegExp(r'[A-Za-z]')) || !v.contains(RegExp(r'[0-9]'))) {
      return 'Gebruik minstens één letter en één cijfer.';
    }
    return null;
  }

  static String? requiredField(String? value, {String label = 'dit veld'}) {
    if (value == null || value.trim().isEmpty) return 'Vul $label in.';
    return null;
  }
}
