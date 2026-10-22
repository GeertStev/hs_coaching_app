import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_error_messages.dart';
import 'package:hs_coaching_app/features/club/presentation/my_clubs_screen.dart';
import 'package:hs_coaching_app/core/theme/theme_mode_controller.dart';
import 'package:hs_coaching_app/features/profile/presentation/personal_info_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/profile_controller.dart';
import 'package:hs_coaching_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// Uitgebreid scherm voor alle gebruikersinstellingen: profiel, account,
/// persoonlijke gegevens, noodcontacten en clubs.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showError(BuildContext context, WidgetRef ref) {
    final error = ref.read(profileControllerProvider).error;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editPicture(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final controller = ref.read(profileControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Kies uit galerij'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final ok = await controller.pickAndUploadPicture(
                  ImageSource.gallery,
                );
                if (!ok && context.mounted) _showError(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Maak een foto'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final ok = await controller.pickAndUploadPicture(
                  ImageSource.camera,
                );
                if (!ok && context.mounted) _showError(context, ref);
              },
            ),
            if (user.picture != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Foto verwijderen'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final ok = await controller.removePicture();
                  if (!ok && context.mounted) _showError(context, ref);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNames(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _EditNamesDialog(user: user),
    );
    if (result == null || !context.mounted) return;
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .updateNames(firstName: result.$1, lastName: result.$2);
    if (!ok && context.mounted) _showError(context, ref);
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
    if (result == null || !context.mounted) return;
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .changePassword(currentPassword: result.$1, newPassword: result.$2);
    if (!context.mounted) return;
    if (ok) {
      _showMessage(context, 'Wachtwoord gewijzigd.');
    } else {
      _showError(context, ref);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _DeleteAccountDialog(),
    );
    if (password == null || !context.mounted) return;
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .deleteAccount(currentPassword: password);
    if (!ok && context.mounted) _showError(context, ref);
    // Bij succes logt Firebase automatisch uit; de AuthGate toont het
    // loginscherm.
  }

  Future<void> _sendVerification(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .sendEmailVerification();
    if (!context.mounted) return;
    if (ok) {
      _showMessage(context, 'Verificatiemail verstuurd.');
    } else {
      _showError(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final fbUser = ref.watch(authStateChangesProvider).value;
    final isBusy = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Profiel & instellingen')),
      body: appUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(authErrorMessage(err))),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Gebruikersprofiel niet gevonden.'));
          }
          final info = user.personalInfo.isNotEmpty
              ? user.personalInfo.first
              : null;
          final metrics = Theme.of(context).appMetrics;
          final colorScheme = Theme.of(context).colorScheme;
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.all(metrics.spacingMd),
                children: [
                  _buildHeader(context, ref, user, fbUser),
                  SizedBox(height: metrics.spacingLg),
                  _sectionTitle(context, 'Weergave'),
                  _buildAppearanceSection(context, ref),
                  SizedBox(height: metrics.spacingLg),
                  _sectionTitle(context, 'Account'),
                  _buildAccountSection(context, ref, user, fbUser),
                  SizedBox(height: metrics.spacingLg),
                  _sectionTitle(context, 'Persoonlijke gegevens'),
                  _buildPersonalInfoSection(context, user, info),
                  SizedBox(height: metrics.spacingLg),
                  _sectionTitle(context, 'Clubs'),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.groups_outlined),
                      title: const Text('Mijn clubs'),
                      subtitle: const Text(
                        'Lidmaatschappen, aanvragen en ploegen',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyClubsScreen(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: metrics.spacingLg),
                  _sectionTitle(context, 'Gevarenzone'),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        'Account verwijderen',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                      ),
                      onTap: () => _deleteAccount(context, ref),
                    ),
                  ),
                ],
              ),
              if (isBusy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref) {
    final metrics = Theme.of(context).appMetrics;
    final themeMode = ref.watch(themeModeControllerProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thema'),
            SizedBox(height: metrics.spacingSm),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Licht'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Donker'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('Systeem'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) => ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(selection.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final metrics = Theme.of(context).appMetrics;
    return Padding(
      padding: EdgeInsets.only(
        left: metrics.spacingSm,
        bottom: metrics.spacingSm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    fb_auth.User? fbUser,
  ) {
    final metrics = Theme.of(context).appMetrics;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.spacingMd),
        child: Row(
          children: [
            Stack(
              children: [
                UserAvatar.fromUser(user, radius: 36),
                Positioned(
                  right: -metrics.spacingXs,
                  bottom: -metrics.spacingXs,
                  child: IconButton.filledTonal(
                    iconSize: 16,
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editPicture(context, ref, user),
                  ),
                ),
              ],
            ),
            SizedBox(width: metrics.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if ((user.email ?? fbUser?.email) != null)
                    Text(
                      user.email ?? fbUser!.email!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Naam wijzigen',
              onPressed: () => _editNames(context, ref, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    fb_auth.User? fbUser,
  ) {
    final verified = fbUser?.emailVerified ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              verified ? Icons.verified_outlined : Icons.warning_amber_outlined,
              // DESIGN.md heeft geen groen; "geverifieerd" leent Athletic Blue
              // (primary = stabiliteit/kracht), "niet geverifieerd" Energy
              // Yellow (secondary = warnings), in plaats van een merkvreemd groen/oranje.
              color: verified ? colorScheme.primary : colorScheme.secondary,
            ),
            title: Text(
              verified ? 'E-mailadres geverifieerd' : 'E-mailadres niet geverifieerd',
            ),
            subtitle: verified ? null : const Text('Verstuur een verificatiemail'),
            trailing: verified
                ? null
                : TextButton(
                    onPressed: () => _sendVerification(context, ref),
                    child: const Text('Versturen'),
                  ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Wachtwoord wijzigen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePassword(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Uitloggen'),
            onTap: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    AppUser user,
    PersonalInfo? info,
  ) {
    final birthday = info?.birthday;
    final addressParts = [
      if (info?.street?.isNotEmpty ?? false)
        '${info!.street} ${info.number ?? ''}'.trim(),
      if (info?.city?.isNotEmpty ?? false)
        '${info!.zipCode ?? ''} ${info.city}'.trim(),
      if (info?.country?.isNotEmpty ?? false) info!.country!,
    ];
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Adres'),
            subtitle: Text(
              addressParts.isEmpty ? 'Niet ingevuld' : addressParts.join('\n'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Telefoon'),
            subtitle: Text(
              (info?.phoneNumber?.isNotEmpty ?? false)
                  ? info!.phoneNumber!
                  : 'Niet ingevuld',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Geboortedatum'),
            subtitle: Text(
              birthday != null
                  ? DateFormat('d MMMM yyyy').format(birthday)
                  : 'Niet ingevuld',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.emergency_outlined),
            title: const Text('Noodcontacten'),
            subtitle: Text(
              (info?.emergencyContacts.isEmpty ?? true)
                  ? 'Geen noodcontacten'
                  : info!.emergencyContacts
                        .map((c) => '${c.firstName} ${c.lastName}')
                        .join(', '),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Gegevens bewerken'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PersonalInfoScreen(user: user),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditNamesDialog extends StatefulWidget {
  const _EditNamesDialog({required this.user});
  final AppUser user;

  @override
  State<_EditNamesDialog> createState() => _EditNamesDialogState();
}

class _EditNamesDialogState extends State<_EditNamesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: const Text('Naam wijzigen'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Voornaam'),
              validator: (v) =>
                  AuthValidators.requiredField(v, label: 'your first name'),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: metrics.spacingMd),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Achternaam'),
              validator: (v) =>
                  AuthValidators.requiredField(v, label: 'your last name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(
                context,
              ).pop((_firstName.text.trim(), _lastName.text.trim()));
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: const Text('Wachtwoord wijzigen'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              decoration: const InputDecoration(
                labelText: 'Huidig wachtwoord',
              ),
              obscureText: true,
              validator: AuthValidators.password,
            ),
            SizedBox(height: metrics.spacingMd),
            TextFormField(
              controller: _new,
              decoration: const InputDecoration(
                labelText: 'Nieuw wachtwoord',
                helperText: 'Minimaal 8 tekens, met letter en cijfer',
              ),
              obscureText: true,
              validator: AuthValidators.newPassword,
            ),
            SizedBox(height: metrics.spacingMd),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(
                labelText: 'Herhaal nieuw wachtwoord',
              ),
              obscureText: true,
              validator: (v) =>
                  v != _new.text ? 'De wachtwoorden komen niet overeen.' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop((_current.text, _new.text));
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: const Text('Account verwijderen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dit verwijdert je account en profielgegevens definitief. '
            'Deze actie kan niet ongedaan worden gemaakt.',
          ),
          SizedBox(height: metrics.spacingMd),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Bevestig met je wachtwoord',
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(_password.text),
          child: const Text('Definitief verwijderen'),
        ),
      ],
    );
  }
}
