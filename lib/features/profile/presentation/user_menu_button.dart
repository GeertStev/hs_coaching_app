import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/club/presentation/my_clubs_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/profile_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/widgets/user_avatar.dart';

/// Gebruikersmenu rechtsboven in de AppBar: avatar (profielfoto of initiaal)
/// met een menu voor profiel, clubs en uitloggen.
class UserMenuButton extends ConsumerWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    final metrics = Theme.of(context).appMetrics;

    return Padding(
      padding: EdgeInsets.only(right: metrics.spacingSm),
      child: PopupMenuButton<String>(
        tooltip: 'Gebruikersmenu',
        offset: const Offset(0, 48),
        onSelected: (value) {
          switch (value) {
            case 'profile':
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            case 'clubs':
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyClubsScreen()),
              );
            case 'logout':
              ref.read(authRepositoryProvider).signOut();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (user.email != null)
                  Text(
                    user.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'profile',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.settings_outlined),
              title: Text('Profiel & instellingen'),
            ),
          ),
          const PopupMenuItem(
            value: 'clubs',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.groups_outlined),
              title: Text('Mijn clubs'),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout),
              title: Text('Uitloggen'),
            ),
          ),
        ],
        child: UserAvatar.fromUser(user),
      ),
    );
  }
}
