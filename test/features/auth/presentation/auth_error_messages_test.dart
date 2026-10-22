import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_error_messages.dart';
import 'package:hs_coaching_core/core/errors/user_message.dart';

void main() {
  test('bekende auth-codes krijgen een eigen melding', () {
    expect(
      authErrorMessage(fb_auth.FirebaseAuthException(code: 'wrong-password')),
      'Email address or password is incorrect.',
    );
  });

  test('onbekende fouten vallen terug op userMessage', () {
    final network = fb_auth.FirebaseAuthException(
      code: 'network-request-failed',
    );
    expect(authErrorMessage(network), userMessage(network));
    expect(authErrorMessage(null), userMessage(null));
  });
}
