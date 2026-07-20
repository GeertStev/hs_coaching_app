import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/club/data/club_providers.dart';
import 'package:hs_coaching_app/features/club/domain/club_membership.dart';
import 'package:hs_coaching_app/features/club/presentation/my_clubs_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/widgets/user_avatar.dart';

/// Alleen-lezen weergave van een club voor gewone leden: ploegen met hun
/// spelers, trainers en clubadmins.
class ClubDetailScreen extends ConsumerWidget {
  const ClubDetailScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(clubId));
    final membersAsync = ref.watch(clubMembersProvider(clubId));
    final teamsAsync = ref.watch(clubTeamsProvider(clubId));

    return Scaffold(
      appBar: AppBar(title: Text(clubAsync.value?.name ?? 'Club')),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(clubErrorMessage(err))),
        data: (members) {
          final active = members.where((m) => m.isActive).toList();
          final teams = teamsAsync.value ?? const [];
          final unassigned = active
              .where(
                (m) =>
                    m.role == ClubRole.player &&
                    !m.teamIds.any((id) => teams.any((t) => t.id == id)),
              )
              .toList();
          final staff = active
              .where((m) => m.role != ClubRole.player)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (staff.isNotEmpty) ...[
                Text(
                  'Trainers & admins',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final member in staff)
                  _MemberTile(member: member, subtitle: member.role.label),
                const SizedBox(height: 16),
              ],
              for (final team in teams) ...[
                Text(team.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final teamMembers = active
                        .where((m) => m.teamIds.contains(team.id))
                        .toList();
                    if (teamMembers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('Nog geen spelers ingedeeld.'),
                      );
                    }
                    return Column(
                      children: [
                        for (final member in teamMembers)
                          _MemberTile(member: member),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (unassigned.isNotEmpty) ...[
                Text(
                  'Nog niet ingedeeld',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final member in unassigned) _MemberTile(member: member),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, this.subtitle});

  final ClubMembership member;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: UserAvatar(
          firstName: member.firstName,
          lastName: member.lastName,
          pictureUrl: member.picture,
        ),
        title: Text(member.fullName),
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),
    );
  }
}
