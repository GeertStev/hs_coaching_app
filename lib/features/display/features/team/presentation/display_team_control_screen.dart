import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/team/data/display_team_repository.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

class TeamControlScreen extends ConsumerWidget {
  const TeamControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentControlScreen(
      contentType: DisplayContentType.team,
      contentList: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Team Data'),
          onPressed: () =>
              ref.read(displayTeamRepositoryProvider).triggerTeamUpdate(),
        ),
      ),
    );
  }
}
