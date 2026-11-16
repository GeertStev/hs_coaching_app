import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/display_team_controller.dart';
import 'package:hs_coaching_app/features/scheduler/domain/schedule_draft.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/game_result_dialog.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/core/errors/user_message.dart';
import 'package:hs_coaching_core/team/team_lineup.dart';
import 'package:hs_coaching_core/scheduler/rating_engine.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/team_scheduler.dart';

/// Vanaf deze breedte staan aanwezigheid en ploegen naast elkaar.
const _wideLayout = 900.0;

/// Ploegen maken voor een training: aanwezigen aanvinken, ploegen en
/// opstellingen kiezen, en meteen de voorgestelde indeling zien.
class TeamSchedulerScreen extends ConsumerWidget {
  const TeamSchedulerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(squadPlayersProvider).value;
    final ratings = ref.watch(ratingResultProvider).value;
    final settings = ref.watch(schedulerSettingsProvider).value;
    final draft = ref.watch(scheduleDraftProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Make teams (${draft.attendees.length} present)'),
        actions: [
          TextButton(
            onPressed: draft.attendees.isEmpty
                ? null
                : ref.read(scheduleDraftProvider.notifier).clearAttendance,
            child: const Text('Clear attendance'),
          ),
        ],
      ),
      body: players == null || ratings == null || settings == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final attendance = _AttendanceList(
                  players: [
                    for (final player in players)
                      if (player.active ||
                          draft.attendees.containsKey(player.id))
                        player,
                  ],
                );
                final teams = _TeamsPane(settings: settings, ratings: ratings);
                if (constraints.maxWidth >= _wideLayout) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: attendance),
                      const VerticalDivider(width: 1),
                      Expanded(flex: 3, child: teams),
                    ],
                  );
                }
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Attendance'),
                          Tab(text: 'Teams'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(children: [attendance, teams]),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  const _AttendanceList({required this.players});

  final List<SquadPlayer> players;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final draft = ref.watch(scheduleDraftProvider);
    final controller = ref.read(scheduleDraftProvider.notifier);
    final sorted = [...players]
      ..sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: metrics.spacingXs),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final player = sorted[index];
        final attendee = draft.attendees[player.id];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.spacingSm),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  key: ValueKey('attend-${player.id}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(player.displayName),
                  subtitle: Text(
                    [for (final p in player.positions) p.code].join(' '),
                  ),
                  value: attendee != null,
                  onChanged: (value) =>
                      controller.setAttending(player.id, value ?? false),
                ),
              ),
              if (attendee != null) ...[
                DropdownButton<PlayerPosition?>(
                  key: ValueKey('position-${player.id}'),
                  value: attendee.fixedPosition,
                  hint: const Text('Any position'),
                  items: [
                    const DropdownMenuItem(child: Text('Any position')),
                    for (final position in PlayerPosition.values)
                      DropdownMenuItem(
                        value: position,
                        child: Text(position.label),
                      ),
                  ],
                  onChanged: (value) =>
                      controller.setFixedPosition(player.id, value),
                ),
                SizedBox(width: metrics.spacingSm),
                DropdownButton<String?>(
                  key: ValueKey('team-${player.id}'),
                  value: attendee.fixedTeam,
                  hint: const Text('Any team'),
                  items: [
                    const DropdownMenuItem(child: Text('Any team')),
                    for (final team in draft.teams)
                      DropdownMenuItem(
                        value: team.name,
                        child: Text(team.name),
                      ),
                  ],
                  onChanged: (value) =>
                      controller.setFixedTeam(player.id, value),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TeamsPane extends ConsumerWidget {
  const _TeamsPane({required this.settings, required this.ratings});

  final SchedulerSettings settings;
  final RatingResult ratings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final draft = ref.watch(scheduleDraftProvider);
    final controller = ref.read(scheduleDraftProvider.notifier);
    final result = ref.watch(scheduleResultProvider);
    final players = {
      for (final player in ref.watch(squadPlayersProvider).value ?? const [])
        player.id: player,
    };
    String nameOf(String id) => players[id]?.displayName ?? id;

    return ListView(
      padding: EdgeInsets.all(metrics.containerMargin),
      children: [
        Wrap(
          spacing: metrics.spacingSm,
          runSpacing: metrics.spacingXs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.addTeam(settings.scheduler.teamNames),
              icon: const Icon(Icons.add),
              label: const Text('Add team'),
            ),
            FilterChip(
              label: const Text('Prioritize experience'),
              selected: draft.prioritizeExperience,
              onSelected: controller.setPrioritizeExperience,
            ),
            FilterChip(
              label: const Text('Prioritize inexperience'),
              selected: draft.prioritizeInexperience,
              onSelected: controller.setPrioritizeInexperience,
            ),
          ],
        ),
        SizedBox(height: metrics.spacingSm),
        if (result != null && result.unassigned.isNotEmpty)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: EdgeInsets.all(metrics.spacingSm),
              child: Text(
                'No place for: '
                '${[for (final id in result.unassigned) nameOf(id)].join(', ')}. '
                'Add substitutes or a team.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        // Een oefenwedstrijd is telkens de eerste tegen de tweede ploeg van
        // een paar: 1 tegen 2, 3 tegen 4...
        for (var index = 0; index < draft.teams.length; index++) ...[
          if (index.isEven && result != null && index + 1 < result.teams.length)
            _Forecast(
              schedule: result,
              team: result.teams[index],
              other: result.teams[index + 1],
              settings: settings,
              ratings: ratings,
              compositionWhite: draft.teams[index].composition,
              compositionBlack: draft.teams[index + 1].composition,
              canCast: index == 0,
              nameOf: nameOf,
            ),
          _TeamCard(
            index: index,
            team: draft.teams[index],
            settings: settings,
            scheduled: result?.teams[index],
            nameOf: nameOf,
          ),
        ],
      ],
    );
  }
}

/// Winstkans en verwachte score van twee ploegen tegen elkaar.
class _Forecast extends ConsumerWidget {
  const _Forecast({
    required this.schedule,
    required this.team,
    required this.other,
    required this.settings,
    required this.ratings,
    required this.compositionWhite,
    required this.compositionBlack,
    required this.canCast,
    required this.nameOf,
  });

  final String compositionWhite;
  final String compositionBlack;

  /// Het zwembadscherm toont één wedstrijd: alleen het eerste paar kan
  /// erheen.
  final bool canCast;
  final String Function(String playerId) nameOf;

  /// Stuurt de opstelling naar het zwembadscherm en zet daar de
  /// teamweergave aan.
  Future<void> _cast(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(teamControllerProvider.notifier)
        .castLineup(teamLineupJson(white: team, black: other, nameOf: nameOf));
    if (!context.mounted) return;
    final state = ref.read(teamControllerProvider);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          state.hasError
              ? userMessage(state.error)
              : 'Lineup sent to the pool screen.',
        ),
      ),
    );
  }

  /// Bewaart de uitslag als oefenwedstrijd: de eerste ploeg is wit, de
  /// tweede zwart. De ratings worden daarna vanzelf herrekend.
  Future<void> _saveResult(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final input = await showGameResultDialog(
      context,
      white: team.name,
      black: other.name,
      initial: GameResultInput(
        date: ref.read(schedulerTodayProvider),
        durationMinutes: settings.scheduler.gameMinutes,
        scoreWhite: 0,
        scoreBlack: 0,
      ),
    );
    if (input == null) return;
    try {
      await ref
          .read(schedulerRepositoryProvider)
          .saveGame(
            PracticeGame(
              date: input.date,
              durationMinutes: input.durationMinutes,
              white: team.toGameSide(
                score: input.scoreWhite,
                composition: compositionWhite,
              ),
              black: other.toGameSide(
                score: input.scoreBlack,
                composition: compositionBlack,
              ),
            ),
            nowMillis: DateTime.now().millisecondsSinceEpoch,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Result saved. Ratings are updated.')),
      );
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'uitslag bewaren');
      messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
    }
  }

  final ScheduleResult schedule;
  final ScheduledTeam team;
  final ScheduledTeam other;
  final SchedulerSettings settings;
  final RatingResult ratings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final casting = ref.watch(teamControllerProvider).isLoading;
    // Zonder spelers in beide ploegen valt er niets te tonen of te bewaren.
    final complete = team.base.isNotEmpty && other.base.isNotEmpty;
    final chance = winChance(team, other, settings.rating);
    double? goals(ScheduledTeam a, ScheduledTeam b) => expectedGoals(
      schedule: schedule,
      team: a,
      other: b,
      stats: ratings.stats,
      config: settings.scheduler,
      ratingConfig: settings.rating,
    );
    final goalsTeam = goals(team, other);
    final goalsOther = goals(other, team);
    final positions = [
      for (final position in PlayerPosition.values)
        if (team.setup.baseCount(position) > 0 &&
            other.setup.baseCount(position) > 0)
          position,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: metrics.spacingXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${team.name} ${(chance * 100).round()}% - '
            '${((1 - chance) * 100).round()}% ${other.name}',
            style: theme.textTheme.headlineSmall,
          ),
          if (goalsTeam != null && goalsOther != null)
            Text(
              'Expected score ${goalsTeam.toStringAsFixed(1)} - '
              '${goalsOther.toStringAsFixed(1)}',
              style: theme.textTheme.bodyLarge,
            ),
          Text(
            [
              for (final position in positions)
                '${position.code} ${_advantage(positionAdvantage(team, other, position, settings.rating))}',
            ].join('   '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: metrics.spacingXs),
          Wrap(
            spacing: metrics.spacingSm,
            runSpacing: metrics.spacingXs,
            children: [
              if (canCast)
                FilledButton.icon(
                  onPressed: complete && !casting
                      ? () => _cast(context, ref)
                      : null,
                  icon: const Icon(Icons.cast),
                  label: const Text('Send to pool screen'),
                ),
              OutlinedButton.icon(
                onPressed: complete ? () => _saveResult(context, ref) : null,
                icon: const Icon(Icons.scoreboard_outlined),
                label: const Text('Save result'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Voordeel van de eerste ploeg op één positie, in procent met teken.
  static String _advantage(double value) {
    final percent = (value * 100).round();
    return percent > 0 ? '+$percent%' : '$percent%';
  }
}

class _TeamCard extends ConsumerWidget {
  const _TeamCard({
    required this.index,
    required this.team,
    required this.settings,
    required this.scheduled,
    required this.nameOf,
  });

  final int index;
  final DraftTeam team;
  final SchedulerSettings settings;
  final ScheduledTeam? scheduled;
  final String Function(String playerId) nameOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final controller = ref.read(scheduleDraftProvider.notifier);
    final draft = ref.watch(scheduleDraftProvider);
    final config = settings.scheduler;
    final composition = compositionNamed(config, team.composition);
    final slots = composition?.slots ?? const <PlayerPosition>[];
    final positions = [
      for (final position in PlayerPosition.values)
        if (slots.contains(position)) position,
    ];
    final usedNames = {for (final other in draft.teams) other.name};
    final scheduled = this.scheduled;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  key: ValueKey('team-name-$index'),
                  value: team.name,
                  items: [
                    for (final name in {team.name, ...config.teamNames})
                      if (name == team.name || !usedNames.contains(name))
                        DropdownMenuItem(value: name, child: Text(name)),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setTeamName(index, value);
                  },
                ),
                SizedBox(width: metrics.spacingSm),
                DropdownButton<String>(
                  key: ValueKey('composition-$index'),
                  value: composition?.name,
                  hint: const Text('Composition'),
                  items: [
                    for (final option in config.compositions)
                      DropdownMenuItem(
                        value: option.name,
                        child: Text(option.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setComposition(index, value);
                  },
                ),
                const Spacer(),
                if (scheduled != null)
                  Text(
                    '${scheduled.rating(settings.rating).round()}',
                    style: theme.appTypography.dataPoint,
                  ),
                IconButton(
                  tooltip: 'Remove team',
                  icon: const Icon(Icons.close),
                  onPressed: draft.teams.length <= 1
                      ? null
                      : () => controller.removeTeam(index),
                ),
              ],
            ),
            for (final position in positions)
              _PositionRow(
                position: position,
                baseCount: slots.where((slot) => slot == position).length,
                substitutes: team.substitutes[position] ?? 0,
                onSubstitutes: (count) =>
                    controller.setSubstitutes(index, position, count),
                base: [
                  for (final entry in scheduled?.base ?? const <LineupEntry>[])
                    if (entry.position == position) nameOf(entry.playerId),
                ],
                subs: [
                  for (final entry in scheduled?.subs ?? const <LineupEntry>[])
                    if (entry.position == position) nameOf(entry.playerId),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Eén positie van een ploeg: de ingedeelde spelers en het aantal wissels.
class _PositionRow extends StatelessWidget {
  const _PositionRow({
    required this.position,
    required this.baseCount,
    required this.substitutes,
    required this.onSubstitutes,
    required this.base,
    required this.subs,
  });

  final PlayerPosition position;
  final int baseCount;
  final int substitutes;
  final ValueChanged<int> onSubstitutes;
  final List<String> base;
  final List<String> subs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final muted = theme.colorScheme.onSurfaceVariant;
    final open = baseCount - base.length;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: metrics.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              position.label.toUpperCase(),
              style: theme.appTypography.labelCaps.copyWith(color: muted),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: base.join(', ')),
                  if (open > 0)
                    TextSpan(
                      text: '${base.isEmpty ? '' : ', '}$open open',
                      style: TextStyle(color: muted),
                    ),
                  if (subs.isNotEmpty)
                    TextSpan(
                      text: '   sub: ${subs.join(', ')}',
                      style: TextStyle(color: muted),
                    ),
                ],
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          // Zoals in het blad: hoogstens één wissel per plaats.
          IconButton(
            tooltip: 'Fewer substitutes',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: substitutes > 0
                ? () => onSubstitutes(substitutes - 1)
                : null,
          ),
          Text('$substitutes sub', style: theme.textTheme.bodyMedium),
          IconButton(
            tooltip: 'More substitutes',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: substitutes < baseCount
                ? () => onSubstitutes(substitutes + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
