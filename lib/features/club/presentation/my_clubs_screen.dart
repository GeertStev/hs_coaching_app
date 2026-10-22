import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/club/data/club_providers.dart';
import 'package:hs_coaching_app/features/club/data/club_repository.dart';
import 'package:hs_coaching_app/features/club/domain/club.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';
import 'package:hs_coaching_app/features/club/presentation/club_controller.dart';
import 'package:hs_coaching_app/features/club/presentation/club_detail_screen.dart';
import 'package:hs_coaching_app/features/club/presentation/club_manage_screen.dart';
import 'package:hs_coaching_core/core/errors/user_message.dart';

/// Foutmelding voor club-acties. Eigen [ClubException]s geven hun tekst
/// zelf door (via core's [userMessage]); hier alleen de Firebase-fouten
/// die voor clubs een concretere uitleg verdienen.
String clubErrorMessage(Object? error) {
  if (error is StateError) return 'You are not signed in.';
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'No access. Check that the Firestore security rules are '
            'deployed (firebase deploy --only firestore).';
      case 'failed-precondition':
        return 'The database is missing an index for this query. Deploy the '
            'indexes (firebase deploy --only firestore); the link to create '
            'it is also in the debug console.';
    }
  }
  return userMessage(error);
}

void _showResult(
  BuildContext context,
  WidgetRef ref,
  bool ok, {
  String? successMessage,
}) {
  final error = ref.read(clubControllerProvider).error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ok ? (successMessage ?? 'Gelukt!') : clubErrorMessage(error)),
    ),
  );
}

/// Overzicht van alle clubs waar de gebruiker lid van is (of een aanvraag
/// heeft lopen), met flows om lid te worden van extra clubs.
class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  Future<void> _joinWithCode(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uitnodigingscode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Code',
            helperText: 'Je ontving deze code van de clubadmin.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Toetreden'),
          ),
        ],
      ),
    );
    if (code == null || code.trim().isEmpty || !context.mounted) return;
    final ok = await ref
        .read(clubControllerProvider.notifier)
        .joinWithInviteCode(code);
    if (context.mounted) {
      _showResult(context, ref, ok, successMessage: 'Welkom bij de club!');
    }
  }

  Future<void> _requestMembership(BuildContext context, WidgetRef ref) async {
    final club = await showDialog<Club>(
      context: context,
      builder: (context) => const _SelectClubDialog(),
    );
    if (club == null || !context.mounted) return;
    final ok = await ref
        .read(clubControllerProvider.notifier)
        .requestMembership(club.id);
    if (context.mounted) {
      _showResult(
        context,
        ref,
        ok,
        successMessage:
            'Aanvraag verstuurd naar ${club.name}. De clubadmin moet deze goedkeuren.',
      );
    }
  }

  Future<void> _createClub(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _CreateClubDialog(),
    );
    if (name == null || !context.mounted) return;
    final ok = await ref
        .read(clubControllerProvider.notifier)
        .createClub(name: name);
    if (context.mounted) {
      _showResult(
        context,
        ref,
        ok,
        successMessage: 'Club "$name" aangemaakt. Jij bent clubadmin.',
      );
    }
  }

  void _showJoinOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Uitnodigingscode invoeren'),
              subtitle: const Text('Direct lid met een code van de clubadmin'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _joinWithCode(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_reg_outlined),
              title: const Text('Toestemming vragen'),
              subtitle: const Text(
                'Kies een club; de clubadmin keurt je aanvraag goed',
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _requestMembership(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business_outlined),
              title: const Text('Nieuwe club aanmaken'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _createClub(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myMembershipsProvider);
    final metrics = Theme.of(context).appMetrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Mijn clubs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinOptions(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Lid worden'),
      ),
      body: membershipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(clubErrorMessage(err))),
        data: (memberships) {
          if (memberships.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(metrics.spacingLg),
                child: const Text(
                  'Je bent nog geen lid van een club.\n'
                  'Word lid met een uitnodigingscode of vraag toestemming aan een club.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // 88 = FAB-hoogte + marge, geen spacing-ritme-waarde; blijft een
          // eigen magic number voor FAB-vrije ruimte onderaan de lijst.
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              metrics.spacingMd,
              metrics.spacingMd,
              metrics.spacingMd,
              88,
            ),
            itemCount: memberships.length,
            itemBuilder: (context, index) =>
                _MembershipTile(membership: memberships[index]),
          );
        },
      ),
    );
  }
}

/// Aanvraag intrekken of club verlaten, met bevestiging.
Future<void> _leaveClub(
  BuildContext context,
  WidgetRef ref,
  ClubMembership membership,
  String clubName,
) async {
  final isPending = membership.isPending;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isPending ? 'Aanvraag intrekken' : 'Club verlaten'),
      content: Text(
        isPending
            ? 'Wil je je aanvraag bij $clubName intrekken?'
            : 'Wil je $clubName verlaten? Je ploegindeling gaat verloren.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(isPending ? 'Intrekken' : 'Verlaten'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final ok = await ref
      .read(clubControllerProvider.notifier)
      .leaveClub(membership.clubId);
  if (context.mounted) _showResult(context, ref, ok);
}

class _MembershipTile extends ConsumerWidget {
  const _MembershipTile({required this.membership});

  final ClubMembership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(membership.clubId));
    final clubName = clubAsync.value?.name ?? membership.clubId;
    final metrics = Theme.of(context).appMetrics;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.groups_outlined),
        title: Text(clubName),
        subtitle: Wrap(
          spacing: metrics.spacingSm,
          children: [
            Chip(
              label: Text(membership.role.label),
              visualDensity: VisualDensity.compact,
            ),
            if (membership.isPending)
              // Energy Yellow: DESIGN.md's kleur voor "Rest states, countdowns,
              // and critical warnings" — past hier op een pending/wacht-status.
              Chip(
                label: Text(membership.status.label),
                labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                visualDensity: VisualDensity.compact,
                backgroundColor: colorScheme.secondaryContainer,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ClubDetailScreen(clubId: membership.clubId),
                  ),
                );
              case 'manage':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ClubManageScreen(clubId: membership.clubId),
                  ),
                );
              case 'leave':
                _leaveClub(context, ref, membership, clubName);
            }
          },
          itemBuilder: (context) => [
            if (membership.isActive)
              const PopupMenuItem(value: 'open', child: Text('Bekijken')),
            if (membership.isClubAdmin)
              const PopupMenuItem(value: 'manage', child: Text('Beheren')),
            PopupMenuItem(
              value: 'leave',
              child: Text(
                membership.isPending ? 'Aanvraag intrekken' : 'Club verlaten',
              ),
            ),
          ],
        ),
        onTap: membership.isActive
            ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => membership.isClubAdmin
                      ? ClubManageScreen(clubId: membership.clubId)
                      : ClubDetailScreen(clubId: membership.clubId),
                ),
              )
            : null,
      ),
    );
  }
}

/// Dialoog om een club te kiezen voor een lidmaatschapsaanvraag.
class _SelectClubDialog extends ConsumerWidget {
  const _SelectClubDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(allClubsProvider);
    final myMemberships = ref.watch(myMembershipsProvider).value ?? const [];
    final myClubIds = myMemberships.map((m) => m.clubId).toSet();

    return AlertDialog(
      title: const Text('Kies een club'),
      content: SizedBox(
        width: double.maxFinite,
        child: clubsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(clubErrorMessage(err)),
          data: (clubs) {
            final available = clubs
                .where((c) => !myClubIds.contains(c.id))
                .toList();
            if (available.isEmpty) {
              return const Text(
                'Geen clubs beschikbaar. Vraag de clubadmin om een uitnodigingscode.',
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: available.length,
              itemBuilder: (context, index) {
                final club = available[index];
                return ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(club.name),
                  subtitle: club.description != null
                      ? Text(club.description!)
                      : null,
                  onTap: () => Navigator.of(context).pop(club),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}

class _CreateClubDialog extends StatefulWidget {
  const _CreateClubDialog();

  @override
  State<_CreateClubDialog> createState() => _CreateClubDialogState();
}

class _CreateClubDialogState extends State<_CreateClubDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuwe club'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Naam van de club'),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Vul een clubnaam in.'
              : null,
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
              Navigator.of(context).pop(_name.text.trim());
            }
          },
          child: const Text('Aanmaken'),
        ),
      ],
    );
  }
}
