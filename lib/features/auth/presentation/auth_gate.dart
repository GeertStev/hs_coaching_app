import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/auth/presentation/login_screen.dart';
import 'package:hs_coaching_app/features/home/presentation/home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}


/*
I/FirebaseAuth( 7063): Logging in as blaatschaap@geert.st with empty reCAPTCHA token
W/System  ( 7063): Ignoring header X-Firebase-Locale because its value was null.
W/LocalRequestInterceptor( 7063): Error getting App Check token; using placeholder token instead. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.

E/flutter ( 7063): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Cannot use the Ref of AsyncNotifierProvider<AuthController, void>#14933 after it has been disposed. This typically happens if:
E/flutter ( 7063): - A provider rebuilt, but the previous "build" was still pending and is still performing operations.
E/flutter ( 7063):   You should therefore either use `ref.onDispose` to cancel pending work, or
E/flutter ( 7063):   check `ref.mounted` after async gaps or anything that could invalidate the provider.
E/flutter ( 7063): - You tried to use Ref inside `onDispose` or other life-cycles.
E/flutter ( 7063):   This is not supported, as the provider is already being disposed.
*/