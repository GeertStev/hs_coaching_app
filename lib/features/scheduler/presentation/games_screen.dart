import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/game_result_dialog.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/scheduler/rating_engine.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';

/// Het wedstrijdlog: alle oefenwedstrijden, nieuwste eerst, met de
/// ratingwijziging per speler. Een uitslag verbeteren of een wedstrijd
/// verwijderen herrekent alle ratings.
class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(ratingResultProvider);
    final players = {
      for (final player in ref.watch(squadPlayersProvider).value ?? const [])
        player.id: player,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: ratingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(practiceGamesProvider),
        ),
        data: (ratings) {
          final games = ratings.games.reversed.toList();
          if (games.isEmpty) {
            return Center(
              child: Text(
                'No games yet. Save a result from Make teams.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(
              Theme.of(context).appMetrics.containerMargin,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) => _GameCard(
              detail: games[index],
              nameOf: (id) => players[id]?.displayName ?? id,
            ),
          );
        },
      ),
    );
  }
}

class _GameCard extends ConsumerWidget {
  const _GameCard({required this.detail, required this.nameOf});

  final GameRatingDetail detail;
  final String Function(String playerId) nameOf;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final game = detail.game;
    final input = await showGameResultDialog(
      context,
      white: 'White',
      black: 'Black',
      title: 'Edit result',
      initial: GameResultInput(
        date: game.date,
        durationMinutes: game.durationMinutes,
        scoreWhite: game.white.score,
        scoreBlack: game.black.score,
      ),
    );
    if (input == null) return;
    try {
      await ref
          .read(schedulerRepositoryProvider)
          .saveGame(
            game.copyWith(
              date: input.date,
              durationMinutes: input.durationMinutes,
              white: game.white.copyWith(score: input.scoreWhite),
              black: game.black.copyWith(score: input.scoreBlack),
            ),
            nowMillis: DateTime.now().millisecondsSinceEpoch,
          );
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'uitslag verbeteren');
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final game = detail.game;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete game?'),
        content: Text(
          '${game.date}: White ${game.white.score} - ${game.black.score} '
          'Black. All ratings are recalculated without this game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(schedulerRepositoryProvider).deleteGame(game.id);
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'wedstrijd verwijderen');
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final game = detail.game;
    final muted = theme.colorScheme.onSurfaceVariant;
    final config = ref.watch(schedulerSettingsProvider).value?.rating;
    final expected = config == null ? null : detail.expectedWhite(config);

    Widget side(String label, GameSide side, double change) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ${side.composition}  ${_signedChange(change)} per player',
            style: theme.appTypography.labelCaps.copyWith(color: muted),
          ),
          for (final position in PlayerPosition.values)
            if (side.entries.any((e) => e.position == position))
              Text(
                '${position.code}: '
                '${[for (final e in side.base)
                  if (e.position == position) nameOf(e.playerId)].join(', ')}'
                '${side.subs.any((e) => e.position == position) ? '  (sub: ${[for (final e in side.subs)
                        if (e.position == position) nameOf(e.playerId)].join(', ')})' : ''}',
                style: theme.textTheme.bodyMedium,
              ),
        ],
      ),
    );

    return Card(
      child: ExpansionTile(
        key: ValueKey('game-${game.id}'),
        title: Text(
          'White ${game.white.score} - ${game.black.score} Black',
          style: theme.textTheme.headlineSmall,
        ),
        subtitle: Text(
          '${game.date}, ${game.durationMinutes} min'
          '${expected == null ? '' : ', expected ${(expected * 100).round()}% for White'}',
        ),
        childrenPadding: EdgeInsets.all(metrics.spacingSm),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              side('WHITE', game.white, detail.changeWhite),
              SizedBox(width: metrics.spacingSm),
              side('BLACK', game.black, detail.changeBlack),
            ],
          ),
          SizedBox(height: metrics.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _delete(context, ref),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
              SizedBox(width: metrics.spacingSm),
              OutlinedButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.edit),
                label: const Text('Edit result'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Wijziging met één decimaal: de meeste wedstrijden bewegen maar enkele
  /// punten.
  static String _signedChange(double change) {
    final text = change.abs().toStringAsFixed(1);
    return change < 0 ? '-$text' : '+$text';
  }
}
