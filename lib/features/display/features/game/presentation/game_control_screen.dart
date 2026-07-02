import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/game/data/game_settings_repository.dart';
import 'package:hs_coaching_app/features/display/features/game/domain/game_settings.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

/// A provider that streams the latest game settings from Firestore.
/// ToDo Move?
final gameSettingsProvider = StreamProvider<GameSettings>((ref) {
  final repository = ref.watch(gameSettingsRepositoryProvider);
  return repository.watchGameSettings();
});

class GameControlScreen extends ConsumerWidget {
  const GameControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSettings = ref.watch(gameSettingsProvider);
    final gameRepo = ref.read(gameSettingsRepositoryProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.game,
      /*addIcon: Icons.refresh,
      addTooltip: 'Reset Scores',
      onAdd: () => gameRepo.resetScores(),*/
      contentList: gameSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          return Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: gameRepo.resetScores,
                icon: const Icon(Icons.refresh),
              ),
              //const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TeamControl(
                        teamName: 'White',
                        teamColor: Colors.white,
                        backgroundColor: Colors.black,
                        score: settings.whiteScore,
                        onIncrement: () => gameRepo.incrementScore(false),
                        onDecrement: () =>
                            gameRepo.decrementScore(false, settings.whiteScore),
                      ),
                    ),
                    //const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: _TeamControl(
                        teamName: 'Black',
                        teamColor: Colors.black,
                        backgroundColor: Colors.white,
                        score: settings.blackScore,
                        onIncrement: () => gameRepo.incrementScore(true),
                        onDecrement: () =>
                            gameRepo.decrementScore(true, settings.blackScore),
                      ),
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 16),
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
          height: 240,
          width: 150,
          decoration: BoxDecoration(
            color: teamColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: backgroundColor, width: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                teamName,
                style: textTheme.headlineMedium!.copyWith(
                  color: backgroundColor,
                ),
              ),
              Text(
                score.toString(),
                style: textTheme.displayLarge!.copyWith(color: backgroundColor),
              ),
            ],
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
    return IconButton.filled(
      icon: Icon(icon),
      onPressed: onIncrement,
      iconSize: 64,
      color: backgroundColor,

      style: IconButton.styleFrom(
        backgroundColor: teamColor,
        shadowColor: Colors.black,
        elevation: 5,
        // border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // outline
        side: BorderSide(color: backgroundColor, width: 4),
      ),
    );
  }
}
