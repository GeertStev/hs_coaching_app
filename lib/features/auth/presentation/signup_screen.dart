import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_controller.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_error_messages.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authControllerProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account aangemaakt. Er is een verificatiemail verstuurd.',
          ),
        ),
      );
      // Terug naar de root; de AuthGate toont nu het HomeScreen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error ?? ''))),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final metrics = Theme.of(context).appMetrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Registreren')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(metrics.spacingLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Voornaam',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        AuthValidators.requiredField(v, label: 'je voornaam'),
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: metrics.spacingMd),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Achternaam',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        AuthValidators.requiredField(v, label: 'je achternaam'),
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.familyName],
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: metrics.spacingMd),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mailadres',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: AuthValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: metrics.spacingMd),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Wachtwoord',
                      helperText: 'Minimaal 8 tekens, met letter en cijfer',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: AuthValidators.newPassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: metrics.spacingMd),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Herhaal wachtwoord',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) => v != _passwordController.text
                        ? 'De wachtwoorden komen niet overeen.'
                        : null,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => isLoading ? null : _signup(),
                  ),
                  SizedBox(height: metrics.spacingLg),
                  FilledButton(
                    onPressed: isLoading ? null : _signup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registreren'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
