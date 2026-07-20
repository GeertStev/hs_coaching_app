import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/display_team_controller.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/team_preview_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

class TeamControlScreen extends ConsumerWidget {
  const TeamControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Luister naar de controller voor eventuele fouten tijdens Firebase mutaties
    ref.listen<AsyncValue<void>>(teamControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij het updaten: ${state.error}')),
        );
      }
    });

    return ContentControlScreen(
      contentType: DisplayContentType.team,
      contentList: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Team composition',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const TeamPreviewDialog(),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh screen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () =>
                  ref.read(teamControllerProvider.notifier).castToScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
