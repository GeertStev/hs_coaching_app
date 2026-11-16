import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/club/data/club_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/player_edit_screen.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/scheduler_texts.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/team_scheduler_screen.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/scheduler/rating_engine.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';

/// Laat de gebruiker de JSON-export van het blad kiezen en geeft de inhoud
/// terug, of `null` als er niets gekozen is. Tests overschrijven deze provider.
final sheetExportPickerProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes());
  },
);

/// Mag de ingelogde gebruiker de Team scheduler zien? Alleen trainers en
/// clubadmins van de club (zelfde voorwaarde als in `firestore.rules`).
final canUseSchedulerProvider = Provider.autoDispose<bool>((ref) {
  final clubId = ref.watch(displayDeviceIdsProvider).clubId;
  return ref.watch(myMembershipForClubProvider(clubId))?.isTrainerOrAdmin ??
      false;
});

/// Tabblad "Team": de ranking van de spelerslijst met de huidige rating per
/// positie. Van hieruit: speler toevoegen of bewerken en de export van het
/// blad importeren.
class SchedulerHomeTab extends ConsumerWidget {
  const SchedulerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canUseSchedulerProvider)) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: EdgeInsets.all(theme.appMetrics.containerMargin),
          child: Text(
            'The team scheduler is available to trainers and club admins.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const _RankingView();
  }
}

/// Waarop de ranking gesorteerd is: op naam of op de rating van één positie.
typedef _SortBy = PlayerPosition?;

class _RankingView extends ConsumerStatefulWidget {
  const _RankingView();

  @override
  ConsumerState<_RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends ConsumerState<_RankingView> {
  PlayerPosition? _sortBy;
  bool _showInactive = false;
  bool _importing = false;

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _importing = true);
    try {
      final json = await ref.read(sheetExportPickerProvider)();
      if (json == null) return;
      final import = await ref.read(
        Provider((ref) => importSheetExport(ref, json)),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${import.players.length} players, '
            '${import.games.length} games and '
            '${import.adjustments.length} adjustments.',
          ),
        ),
      );
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'Teamscheduler-export importeren');
      messenger.showSnackBar(
        SnackBar(content: Text(schedulerErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _edit(SquadPlayer? player) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerEditScreen(playerId: player?.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final playersAsync = ref.watch(squadPlayersProvider);
    final ratingsAsync = ref.watch(ratingResultProvider);

    if (playersAsync.hasError || ratingsAsync.hasError) {
      return ErrorView(
        error: playersAsync.error ?? ratingsAsync.error!,
        onRetry: () {
          ref.invalidate(squadPlayersProvider);
          ref.invalidate(practiceGamesProvider);
          ref.invalidate(ratingAdjustmentsProvider);
          ref.invalidate(schedulerSettingsProvider);
        },
      );
    }
    final players = playersAsync.value;
    final ratings = ratingsAsync.value;
    if (players == null || ratings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final importButton = OutlinedButton.icon(
      onPressed: _importing ? null : _import,
      icon: const Icon(Icons.upload_file),
      label: const Text('Import sheet export'),
    );
    final addButton = OutlinedButton.icon(
      onPressed: () => _edit(null),
      icon: const Icon(Icons.person_add),
      label: const Text('Add player'),
    );

    if (players.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: EdgeInsets.all(metrics.containerMargin),
            child: Padding(
              padding: EdgeInsets.all(metrics.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEAM SCHEDULER',
                    style: theme.appTypography.labelCaps.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: metrics.spacingXs),
                  Text(
                    'No players yet. Import the export of the Teamscheduler '
                    'sheet, or add players one by one.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: metrics.spacingMd),
                  importButton,
                  SizedBox(height: metrics.spacingSm),
                  addButton,
                ],
              ),
            ),
          ),
        ),
      );
    }

    final sortBy = _sortBy;
    final visible = [
      for (final player in players)
        if (_showInactive || player.active) player,
    ];
    if (sortBy == null) {
      visible.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    } else {
      // Hoogste rating eerst; spelers zonder rating op die positie achteraan.
      visible.sort(
        (a, b) => (ratings.ratingOf(b.id, sortBy) ?? double.negativeInfinity)
            .compareTo(
              ratings.ratingOf(a.id, sortBy) ?? double.negativeInfinity,
            ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            metrics.containerMargin,
            metrics.spacingSm,
            metrics.containerMargin,
            metrics.spacingXs,
          ),
          child: Wrap(
            spacing: metrics.spacingSm,
            runSpacing: metrics.spacingXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<_SortBy>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(value: null, label: Text('Name')),
                  for (final position in PlayerPosition.values)
                    ButtonSegment(
                      value: position,
                      label: Text(position.code),
                      tooltip: 'Sort by ${position.label} rating',
                    ),
                ],
                selected: {sortBy},
                onSelectionChanged: (selection) =>
                    setState(() => _sortBy = selection.single),
              ),
              FilterChip(
                label: const Text('Inactive'),
                selected: _showInactive,
                onSelected: (value) => setState(() => _showInactive = value),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TeamSchedulerScreen(),
                  ),
                ),
                icon: const Icon(Icons.groups),
                label: const Text('Make teams'),
              ),
              addButton,
              importButton,
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.containerMargin,
              vertical: metrics.spacingXs,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) => _PlayerCard(
              player: visible[index],
              ratings: ratings,
              onTap: () => _edit(visible[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends ConsumerWidget {
  const _PlayerCard({
    required this.player,
    required this.ratings,
    required this.onTap,
  });

  final SquadPlayer player;
  final RatingResult ratings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final config = ref.watch(schedulerSettingsProvider).value?.rating;
    final fullName = '${player.firstName} ${player.surname}'.trim();
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(metrics.spacingSm),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: player.active
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (fullName != player.displayName || !player.active)
                      Text(
                        player.active ? fullName : '$fullName (inactive)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              for (final position in PlayerPosition.values)
                Expanded(
                  child: _PositionRating(
                    position: position,
                    rating: ratings.ratingOf(player.id, position),
                    rank: (rating) => rankName(config?.tierFor(rating)),
                    allowed: player.positions.contains(position),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionRating extends StatelessWidget {
  const _PositionRating({
    required this.position,
    required this.rating,
    required this.rank,
    required this.allowed,
  });

  final PlayerPosition position;
  final double? rating;
  final String Function(double rating) rank;

  /// De scheduler mag de speler op deze positie zetten.
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = rating;
    final color = allowed
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Text(
          position.code,
          style: theme.appTypography.labelCaps.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value == null ? '-' : '${value.round()}',
          style: theme.appTypography.dataPoint.copyWith(color: color),
        ),
        if (value != null)
          Text(
            rank(value),
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
