import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/game/data/game_provider.dart';
import 'package:hs_coaching_app/features/display/features/game/presentation/game_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

class GameControlScreen extends ConsumerWidget {
  const GameControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSettings = ref.watch(gameSettingsProvider);

    // Luister naar de controller voor eventuele fouten tijdens Firebase mutaties
    ref.listen<AsyncValue<void>>(gameControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij het updaten van de score: ${state.error}'),
          ),
        );
      }
    });

    return ContentControlScreen(
      contentType: DisplayContentType.game,
      body: gameSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          final controller = ref.read(gameControllerProvider.notifier);

          return Column(
            children: [
              IconButton(
                onPressed: () => controller.resetScores(),
                icon: const Icon(Icons.refresh),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TeamControl(
                        teamName: 'White',
                        teamColor: Colors.white,
                        backgroundColor: Colors.black,
                        score: settings.whiteScore,
                        onIncrement: () => controller.incrementScore(false),
                        onDecrement: () => controller.decrementScore(
                          false,
                          settings.whiteScore,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TeamControl(
                        teamName: 'Black',
                        teamColor: Colors.black,
                        backgroundColor: Colors.white,
                        score: settings.blackScore,
                        onIncrement: () => controller.incrementScore(true),
                        onDecrement: () => controller.decrementScore(
                          true,
                          settings.blackScore,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A reusable widget to display and control the score for a single team.
class _TeamControl extends StatelessWidget {
  const _TeamControl({
    required this.teamName,
    required this.teamColor,
    required this.backgroundColor,
    required this.score,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String teamName;
  final Color teamColor;
  final Color backgroundColor;
  final int score;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GameIconButton(
          icon: Icons.add,
          onIncrement: onIncrement,
          backgroundColor: backgroundColor,
          teamColor: teamColor,
        ),
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: teamColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: backgroundColor, width: 4),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: textTheme.displayLarge!.copyWith(color: backgroundColor),
            ),
          ),
        ),
        GameIconButton(
          icon: Icons.remove,
          onIncrement: onDecrement,
          backgroundColor: backgroundColor,
          teamColor: teamColor,
        ),
      ],
    );
  }
}

class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    required this.icon,
    required this.onIncrement,
    required this.backgroundColor,
    required this.teamColor,
  });

  final IconData icon;
  final VoidCallback onIncrement;
  final Color backgroundColor;
  final Color teamColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: teamColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor, width: 4),
      ),
      child: IconButton.filled(
        icon: Icon(icon),
        onPressed: onIncrement,
        iconSize: 64,
        color: backgroundColor,

        style: IconButton.styleFrom(
          backgroundColor: teamColor,
          //shadowColor: Colors.black,
          //elevation: 5,
          // border
          /*shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // outline
          side: BorderSide(color: backgroundColor, width: 4),*/
        ),
      ),
    );
  }
}
