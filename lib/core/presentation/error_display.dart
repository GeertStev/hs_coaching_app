import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:hs_coaching_core/core/errors/user_message.dart';

/// Sleutel van de app-brede [ScaffoldMessenger] (op `MaterialApp`), zodat
/// ook code zonder `BuildContext` een melding kan tonen.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Toont [error] als korte melding onderaan, via core's `userMessage` of
/// [message] als die gegeven is (bv. een feature-specifieke vertaling).
void showErrorSnackBar(BuildContext context, Object? error, {String? message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message ?? userMessage(error))),
  );
}

/// Voor `installGlobalErrorHandlers`: een losse async-fout die niemand
/// opving (bv. een mislukte Start-knop) toch aan de coach tonen.
void showUncaughtErrorSnackBar(Object error) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(userMessage(error))),
  );
}

/// Toont een melding zodra een mutatie-controller (`AsyncNotifier<void>` met
/// `AsyncValue.guard`) in fout gaat. Roep aan vanuit `build`.
void listenForMutationErrors(
  WidgetRef ref,
  BuildContext context,
  ProviderListenable<AsyncValue<void>> controller,
) {
  ref.listen<AsyncValue<void>>(controller, (_, state) {
    if (state.hasError && !state.isLoading) {
      showErrorSnackBar(context, state.error);
    }
  });
}

/// Vervangt `Text('Error: $err')` in `.when(error: ...)`: een nette melding
/// en, met [onRetry], een knop om opnieuw te proberen.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry, this.message});

  final Object? error;
  final VoidCallback? onRetry;

  /// Optionele eigen tekst i.p.v. `userMessage(error)`.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message ?? userMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
