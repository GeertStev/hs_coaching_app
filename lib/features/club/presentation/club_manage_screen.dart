import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/club/data/club_providers.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';
import 'package:hs_coaching_app/features/club/domain/club_team.dart';
import 'package:hs_coaching_app/features/club/presentation/club_controller.dart';
import 'package:hs_coaching_app/features/club/presentation/my_clubs_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

/// Beheerscherm voor de clubadmin: leden, aanvragen, ploegen en
/// uitnodigingen.
class ClubManageScreen extends ConsumerWidget {
  const ClubManageScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(clubId));
    final membersAsync = ref.watch(clubMembersProvider(clubId));
    final pendingCount = membersAsync.value
            ?.where((m) => m.isPending)
            .length ??
        0;
    final metrics = Theme.of(context).appMetrics;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${clubAsync.value?.name ?? 'Club'} beheren'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Leden'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Aanvragen'),
                    if (pendingCount > 0) ...[
                      SizedBox(width: metrics.spacingXs),
                      Badge(label: Text('$pendingCount')),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Ploegen'),
              const Tab(text: 'Uitnodigingen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MembersTab(clubId: clubId),
            _RequestsTab(clubId: clubId),
            _TeamsTab(clubId: clubId),
            _InvitesTab(clubId: clubId),
          ],
        ),
      ),
    );
  }
}

void _showControllerResult(
  BuildContext context,
  WidgetRef ref,
  bool ok, {
  String? successMessage,
}) {
  final error = ref.read(clubControllerProvider).error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        ok ? (successMessage ?? 'Opgeslagen.') : clubErrorMessage(error),
      ),
    ),
  );
}

// ------------------------------------------------------------------- Leden

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(clubId));
    final teams = ref.watch(clubTeamsProvider(clubId)).value ?? const [];

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(clubErrorMessage(err))),
      data: (members) {
        final active = members.where((m) => m.isActive).toList();
        if (active.isEmpty) {
          return const Center(child: Text('Nog geen actieve leden.'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(Theme.of(context).appMetrics.spacingMd),
          itemCount: active.length,
          itemBuilder: (context, index) {
            final member = active[index];
            final teamNames = teams
                .where((t) => member.teamIds.contains(t.id))
                .map((t) => t.name)
                .join(', ');
            return Card(
              child: ListTile(
                leading: UserAvatar(
                  firstName: member.firstName,
                  lastName: member.lastName,
                  pictureUrl: member.picture,
                ),
                title: Text(member.fullName),
                subtitle: Text(
                  [
                    member.role.label,
                    if (teamNames.isNotEmpty) teamNames,
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => _EditMemberDialog(
                    clubId: clubId,
                    member: member,
                    teams: teams,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Dialoog voor de clubadmin: rol wijzigen, ploegen toewijzen of lid
/// verwijderen.
class _EditMemberDialog extends ConsumerStatefulWidget {
  const _EditMemberDialog({
    required this.clubId,
    required this.member,
    required this.teams,
  });

  final String clubId;
  final ClubMembership member;
  final List<ClubTeam> teams;

  @override
  ConsumerState<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends ConsumerState<_EditMemberDialog> {
  late ClubRole _role = widget.member.role;
  late Set<String> _teamIds = {...widget.member.teamIds};

  Future<void> _save() async {
    final controller = ref.read(clubControllerProvider.notifier);
    var ok = true;
    if (_role != widget.member.role) {
      ok = await controller.updateMemberRole(
        widget.clubId,
        widget.member.uid,
        _role,
      );
    }
    final newTeams = _teamIds.toList()..sort();
    final oldTeams = [...widget.member.teamIds]..sort();
    if (ok && newTeams.join(',') != oldTeams.join(',')) {
      ok = await controller.updateMemberTeams(
        widget.clubId,
        widget.member.uid,
        newTeams,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _showControllerResult(context, ref, ok);
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lid verwijderen'),
        content: Text(
          '${widget.member.fullName} verwijderen uit de club?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(clubControllerProvider.notifier)
        .removeMembership(widget.clubId, widget.member.uid);
    if (!mounted) return;
    Navigator.of(context).pop();
    _showControllerResult(context, ref, ok, successMessage: 'Lid verwijderd.');
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: Text(widget.member.fullName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ClubRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: [
                for (final role in ClubRole.values)
                  DropdownMenuItem(value: role, child: Text(role.label)),
              ],
              onChanged: (role) =>
                  setState(() => _role = role ?? ClubRole.player),
            ),
            SizedBox(height: metrics.spacingMd),
            Text('Ploegen', style: Theme.of(context).textTheme.titleSmall),
            if (widget.teams.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: metrics.spacingSm),
                child: const Text('Nog geen ploegen. Maak eerst een ploeg aan.'),
              ),
            for (final team in widget.teams)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(team.name),
                value: _teamIds.contains(team.id),
                onChanged: (checked) => setState(() {
                  _teamIds = {..._teamIds};
                  if (checked ?? false) {
                    _teamIds.add(team.id);
                  } else {
                    _teamIds.remove(team.id);
                  }
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _remove,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Verwijderen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(onPressed: _save, child: const Text('Opslaan')),
      ],
    );
  }
}

// --------------------------------------------------------------- Aanvragen

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab({required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(clubId));

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(clubErrorMessage(err))),
      data: (members) {
        final pending = members.where((m) => m.isPending).toList();
        if (pending.isEmpty) {
          return const Center(child: Text('Geen openstaande aanvragen.'));
        }
        final metrics = Theme.of(context).appMetrics;
        final colorScheme = Theme.of(context).colorScheme;
        return ListView.builder(
          padding: EdgeInsets.all(metrics.spacingMd),
          itemCount: pending.length,
          itemBuilder: (context, index) {
            final member = pending[index];
            return Card(
              child: ListTile(
                leading: UserAvatar(
                  firstName: member.firstName,
                  lastName: member.lastName,
                  pictureUrl: member.picture,
                ),
                title: Text(member.fullName),
                subtitle: member.requestedAt != null
                    ? Text(
                        'Aangevraagd op '
                        '${DateFormat('d MMM yyyy').format(member.requestedAt!)}',
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.error),
                      tooltip: 'Weigeren',
                      onPressed: () async {
                        final ok = await ref
                            .read(clubControllerProvider.notifier)
                            .removeMembership(clubId, member.uid);
                        if (context.mounted) {
                          _showControllerResult(
                            context,
                            ref,
                            ok,
                            successMessage: 'Aanvraag geweigerd.',
                          );
                        }
                      },
                    ),
                    IconButton(
                      // Geen groen in DESIGN.md: primary (Athletic Blue) is de
                      // enige "positieve" merkkleur, in plaats van generiek groen.
                      icon: Icon(Icons.check, color: colorScheme.primary),
                      tooltip: 'Goedkeuren',
                      onPressed: () async {
                        final ok = await ref
                            .read(clubControllerProvider.notifier)
                            .approveMembership(clubId, member.uid);
                        if (context.mounted) {
                          _showControllerResult(
                            context,
                            ref,
                            ok,
                            successMessage:
                                '${member.fullName} is nu lid van de club.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------------- Ploegen

class _TeamsTab extends ConsumerWidget {
  const _TeamsTab({required this.clubId});

  final String clubId;

  Future<void> _addOrRenameTeam(
    BuildContext context,
    WidgetRef ref, {
    ClubTeam? existing,
  }) async {
    final controller = TextEditingController(text: existing?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Nieuwe ploeg' : 'Ploeg hernoemen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Naam'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final clubController = ref.read(clubControllerProvider.notifier);
    final ok = existing == null
        ? await clubController.addTeam(clubId, name)
        : await clubController.renameTeam(clubId, existing.id, name);
    if (context.mounted) _showControllerResult(context, ref, ok);
  }

  Future<void> _deleteTeam(
    BuildContext context,
    WidgetRef ref,
    ClubTeam team,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ploeg verwijderen'),
        content: Text(
          '"${team.name}" verwijderen? Spelers blijven lid van de club, '
          'maar worden uit deze ploeg gehaald.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await ref
        .read(clubControllerProvider.notifier)
        .deleteTeam(clubId, team.id);
    if (context.mounted) {
      _showControllerResult(context, ref, ok,
          successMessage: 'Ploeg verwijderd.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(clubTeamsProvider(clubId));
    final members = ref.watch(clubMembersProvider(clubId)).value ?? const [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addTeam',
        onPressed: () => _addOrRenameTeam(context, ref),
        child: const Icon(Icons.add),
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(clubErrorMessage(err))),
        data: (teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text('Nog geen ploegen. Maak er een aan met de + knop.'),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(Theme.of(context).appMetrics.spacingMd),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final count = members
                  .where((m) => m.isActive && m.teamIds.contains(team.id))
                  .length;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: Text(team.name),
                  subtitle: Text('$count spelers'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'rename':
                          _addOrRenameTeam(context, ref, existing: team);
                        case 'delete':
                          _deleteTeam(context, ref, team);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'rename', child: Text('Hernoemen')),
                      PopupMenuItem(value: 'delete', child: Text('Verwijderen')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------ Uitnodigingen

class _InvitesTab extends ConsumerWidget {
  const _InvitesTab({required this.clubId});

  final String clubId;

  Future<void> _createInvite(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(ClubRole, DateTime?)>(
      context: context,
      builder: (context) => const _CreateInviteDialog(),
    );
    if (result == null || !context.mounted) return;
    final code = await ref.read(clubControllerProvider.notifier).createInvite(
      clubId: clubId,
      role: result.$1,
      expiresAt: result.$2,
    );
    if (!context.mounted) return;
    if (code == null) {
      _showControllerResult(context, ref, false);
    } else {
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uitnodigingscode $code aangemaakt en gekopieerd.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(clubInvitesProvider(clubId));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addInvite',
        onPressed: () => _createInvite(context, ref),
        child: const Icon(Icons.add),
      ),
      body: invitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(clubErrorMessage(err))),
        data: (invites) {
          final metrics = Theme.of(context).appMetrics;
          final colorScheme = Theme.of(context).colorScheme;
          if (invites.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(metrics.spacingLg),
                child: const Text(
                  'Nog geen uitnodigingen.\nMaak een code aan en deel die met '
                  'nieuwe leden: zij treden dan direct toe zonder goedkeuring.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(metrics.spacingMd),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.key_outlined,
                    // Geen groen in DESIGN.md: primary voor "bruikbaar",
                    // onSurfaceVariant (neutraal gedimd) i.p.v. generiek grijs.
                    color: invite.isUsable
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: SelectableText(
                    invite.code,
                    // DESIGN.md "data-point": JetBrains Mono voor technische
                    // waarden, i.p.v. het generieke OS-'monospace'-font.
                    style: Theme.of(context).appTypography.dataPoint.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  subtitle: Text(
                    [
                      'Rol: ${invite.role.label}',
                      if (invite.expiresAt != null)
                        'Geldig tot ${DateFormat('d MMM yyyy').format(invite.expiresAt!)}',
                      if (!invite.active) 'Gedeactiveerd',
                      if (invite.active && invite.isExpired) 'Verlopen',
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        tooltip: 'Code kopiëren',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: invite.code),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code gekopieerd.'),
                              ),
                            );
                          }
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          final controller = ref.read(
                            clubControllerProvider.notifier,
                          );
                          switch (value) {
                            case 'toggle':
                              final ok = await controller.setInviteActive(
                                clubId,
                                invite.code,
                                !invite.active,
                              );
                              if (context.mounted) {
                                _showControllerResult(context, ref, ok);
                              }
                            case 'delete':
                              final ok = await controller.deleteInvite(
                                clubId,
                                invite.code,
                              );
                              if (context.mounted) {
                                _showControllerResult(context, ref, ok);
                              }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              invite.active ? 'Deactiveren' : 'Activeren',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Verwijderen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateInviteDialog extends StatefulWidget {
  const _CreateInviteDialog();

  @override
  State<_CreateInviteDialog> createState() => _CreateInviteDialogState();
}

class _CreateInviteDialogState extends State<_CreateInviteDialog> {
  ClubRole _role = ClubRole.player;
  DateTime? _expiresAt;

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: const Text('Nieuwe uitnodiging'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ClubRole>(
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: 'Rol voor nieuwe leden',
            ),
            items: [
              for (final role in ClubRole.values)
                DropdownMenuItem(value: role, child: Text(role.label)),
            ],
            onChanged: (role) => setState(() => _role = role ?? ClubRole.player),
          ),
          SizedBox(height: metrics.spacingMd),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vervaldatum'),
            subtitle: Text(
              _expiresAt != null
                  ? DateFormat('d MMM yyyy').format(_expiresAt!)
                  : 'Geen (blijft geldig)',
            ),
            trailing: _expiresAt != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _expiresAt = null),
                  )
                : const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now.add(const Duration(days: 7)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) {
                // Einde van de gekozen dag.
                setState(
                  () => _expiresAt = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    23,
                    59,
                    59,
                  ),
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((_role, _expiresAt)),
          child: const Text('Aanmaken'),
        ),
      ],
    );
  }
}
