import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/data/infringement_table_provider.dart';
import 'package:hs_coaching_app/features/match/presentation/cap_pad.dart';
import 'package:hs_coaching_app/features/match/presentation/console_button.dart';
import 'package:hs_coaching_app/features/match/presentation/console_device.dart';
import 'package:hs_coaching_app/features/match/presentation/event_log_sheet.dart';
import 'package:hs_coaching_app/features/match/presentation/match_console_controller.dart';
import 'package:hs_coaching_app/features/match/presentation/match_texts.dart';
import 'package:hs_coaching_app/features/match/presentation/penalty_dialog.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:hs_coaching_core/team/team_model.dart';

/// Live console van de wedstrijdtafel (03 §2.2). Elke knop vraagt eerst de
/// validator van de engine: mag de actie niet, dan is de knop grijs en toont
/// een lange druk waarom. De console berekent zelf niets; de stand komt uit
/// de [MatchSession].
class MatchConsoleScreen extends ConsumerStatefulWidget {
  const MatchConsoleScreen({super.key, required this.session});

  final MatchSession session;

  @override
  ConsumerState<MatchConsoleScreen> createState() => _MatchConsoleScreenState();
}

class _MatchConsoleScreenState extends ConsumerState<MatchConsoleScreen> {
  /// Het type herstart dat de tafel voorgekozen heeft voor de volgende START
  /// (ook die van de afstandsbediening, 03 §5).
  RestartType _restartType = RestartType.endLineStart;
  late final ConsoleDevice _device = ref.read(consoleDeviceProvider);

  MatchSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _device.enterConsole();
  }

  @override
  void dispose() {
    _device.leaveConsole();
    super.dispose();
  }

  /// Logt [data] op het moment van de tik.
  bool _log(MatchEventData data) {
    try {
      _session.add(data);
      _device.confirmTap();
      return true;
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'match event loggen');
      if (mounted) showErrorSnackBar(context, error);
      return false;
    }
  }

  String? _blocked(MatchConsoleView view, MatchEventData probe) {
    if (!view.holdsLease) return 'Another device controls this match.';
    final rejection = _session.check(probe);
    return rejection == null ? null : rejectionMessage(rejection);
  }

  Future<void> _goal(TeamColor team) async {
    final choice = await showGoalCapDialog(
      context,
      title: 'Goal ${teamLabel(team)}: scorer',
    );
    if (choice == null) return;
    _log(MatchEventData.goalScored(team: team, scorerCap: choice.cap));
  }

  Future<void> _penalty(TeamColor team) async {
    final table = await ref.read(infringementTableProvider.future);
    if (!mounted) return;
    final event = await showPenaltyDialog(
      context,
      session: _session,
      table: table,
      team: team,
    );
    if (event != null) _log(event);
  }

  void _penaltyShotGoal(TeamColor team) {
    // Een gescoorde strafworp is een doelpunt gevolgd door de afsluiting.
    if (_log(
      MatchEventData.goalScored(team: team, kind: GoalKind.penaltyShot),
    )) {
      _log(
        const MatchEventData.penaltyShotResolved(
          outcome: PenaltyShotOutcome.goal,
        ),
      );
    }
  }

  void _openLog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: EventLogSheet(
          session: _session,
          onUndo: (event) =>
              _log(MatchEventData.eventVoided(targetId: event.id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = matchConsoleProvider(_session);
    final view = ref.watch(provider);
    ref.listen(provider.select((view) => view.hintSerial), (_, _) {
      _device.hint();
    });

    final metrics = Theme.of(context).appMetrics;
    final state = view.clock.state;
    final left = state.whiteOnLeft ? TeamColor.white : TeamColor.black;
    final right = opponentOf(left);
    // Op een telefoon krijgen de teamkolommen minder breedte.
    final sideWidth = math.min(
      ConsoleLayout.sideColumnWidth,
      MediaQuery.sizeOf(context).width * ConsoleLayout.sideColumnShare,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(metrics.spacingSm),
          child: Column(
            children: [
              _Header(
                view: view,
                left: left,
                right: right,
                sideWidth: sideWidth,
                onLog: _openLog,
              ),
              SizedBox(height: metrics.spacingSm),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: sideWidth, child: _teamColumn(view, left)),
                    SizedBox(width: metrics.spacingMd),
                    Expanded(child: _centerColumn(view)),
                    SizedBox(width: metrics.spacingMd),
                    SizedBox(width: sideWidth, child: _teamColumn(view, right)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamColumn(MatchConsoleView view, TeamColor team) {
    final metrics = Theme.of(context).appMetrics;
    final name = team.name;
    final gap = SizedBox(height: metrics.spacingSm);
    final penalties = view.clock.penalties
        .where((penalty) => penalty.team == team && penalty.inPenaltyBox)
        .toList();
    final dismissed = view.clock.penalties
        .where(
          (penalty) =>
              penalty.team == team && penalty.status == PenaltyStatus.dismissal,
        )
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          ConsoleButton(
            key: ValueKey('goal-$name'),
            label: 'Goal ${teamLabel(team)}',
            tone: ConsoleButtonTone.primary,
            blockedReason: _blocked(
              view,
              MatchEventData.goalScored(team: team),
            ),
            onPressed: () => _goal(team),
          ),
          gap,
          ConsoleButton(
            key: ValueKey('penalty-$name'),
            label: 'Penalty',
            // Een waarschuwing mag zodra de wedstrijd bestaat; de dialoog
            // controleert de gekozen straf zelf nog eens.
            blockedReason: _blocked(
              view,
              MatchEventData.cautionGiven(
                team: team,
                infringementCode: '',
                isTeamCaution: true,
              ),
            ),
            onPressed: () => _penalty(team),
          ),
          gap,
          ConsoleButton(
            key: ValueKey('timeout-$name'),
            label: 'Time-out',
            blockedReason: _blocked(
              view,
              MatchEventData.teamTimeOutRequested(team: team),
            ),
            onPressed: () =>
                _log(MatchEventData.teamTimeOutRequested(team: team)),
          ),
          gap,
          ConsoleButton(
            key: ValueKey('shot-$name'),
            label: 'Penalty shot',
            blockedReason: _blocked(
              view,
              MatchEventData.penaltyShotAwarded(againstTeam: opponentOf(team)),
            ),
            onPressed: () => _log(
              MatchEventData.penaltyShotAwarded(againstTeam: opponentOf(team)),
            ),
          ),
          gap,
          for (final penalty in [...penalties, ...dismissed])
            Padding(
              padding: EdgeInsets.only(bottom: metrics.spacingXs),
              child: _PenaltyClock(
                penalty: penalty,
                onRelease: () => _log(
                  MatchEventData.penaltyPlayerReturned(
                    team: team,
                    cap: penalty.cap,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _centerColumn(MatchConsoleView view) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final state = view.clock.state;
    final gap = SizedBox(height: metrics.spacingSm);
    final start = MatchEventData.playStarted(restartType: _restartType);
    const stop = MatchEventData.playStopped();
    final shotFor = state.pendingPenaltyShot;
    final nextPhase = state.phase.nextPlayPhase;

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ConsoleButton(
                  key: const ValueKey('start'),
                  label: 'Start',
                  icon: Icons.play_arrow,
                  tone: ConsoleButtonTone.primary,
                  height: ConsoleLayout.clockButtonHeight,
                  blockedReason: _blocked(view, start),
                  onPressed: () => _log(start),
                ),
              ),
              SizedBox(width: metrics.spacingSm),
              Expanded(
                child: ConsoleButton(
                  key: const ValueKey('stop'),
                  label: 'Stop',
                  icon: Icons.stop,
                  tone: ConsoleButtonTone.danger,
                  height: ConsoleLayout.clockButtonHeight,
                  blockedReason: _blocked(view, stop),
                  onPressed: () => _log(stop),
                ),
              ),
            ],
          ),
          gap,
          DropdownButtonFormField<RestartType>(
            key: const ValueKey('restart-type'),
            isExpanded: true,
            initialValue: _restartType,
            decoration: const InputDecoration(labelText: 'Next start'),
            items: [
              for (final type in RestartType.values)
                DropdownMenuItem(
                  value: type,
                  child: Text(restartTypeLabel(type)),
                ),
            ],
            onChanged: (type) =>
                setState(() => _restartType = type ?? _restartType),
          ),
          gap,
          if (shotFor != null) ...[
            Text(
              'Penalty shot for ${teamLabel(shotFor)}',
              style: theme.textTheme.headlineSmall,
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: ConsoleButton(
                    key: const ValueKey('shot-goal'),
                    label: 'Shot: goal',
                    tone: ConsoleButtonTone.primary,
                    blockedReason: _blocked(
                      view,
                      MatchEventData.goalScored(
                        team: shotFor,
                        kind: GoalKind.penaltyShot,
                      ),
                    ),
                    onPressed: () => _penaltyShotGoal(shotFor),
                  ),
                ),
                SizedBox(width: metrics.spacingSm),
                Expanded(
                  child: ConsoleButton(
                    key: const ValueKey('shot-defended'),
                    label: 'Shot: defended',
                    blockedReason: _blocked(
                      view,
                      const MatchEventData.penaltyShotResolved(
                        outcome: PenaltyShotOutcome.defended,
                      ),
                    ),
                    onPressed: () => _log(
                      const MatchEventData.penaltyShotResolved(
                        outcome: PenaltyShotOutcome.defended,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            gap,
          ],
          Row(
            children: [
              Expanded(
                child: ConsoleButton(
                  key: const ValueKey('officials-timeout'),
                  label: "Officials' time-out",
                  blockedReason: _blocked(
                    view,
                    const MatchEventData.officialsTimeOutStarted(),
                  ),
                  onPressed: () =>
                      _log(const MatchEventData.officialsTimeOutStarted()),
                ),
              ),
              SizedBox(width: metrics.spacingSm),
              Expanded(
                child: state.phase.isTimedPlay
                    ? ConsoleButton(
                        key: const ValueKey('end-period'),
                        label: 'End period',
                        blockedReason: _blocked(
                          view,
                          MatchEventData.periodEnded(phase: state.phase),
                        ),
                        onPressed: () => _log(
                          MatchEventData.periodEnded(phase: state.phase),
                        ),
                      )
                    : ConsoleButton(
                        key: const ValueKey('period-warning'),
                        label: 'Warning before period',
                        blockedReason: nextPhase == null
                            ? 'Not possible in this phase of the match.'
                            : _blocked(
                                view,
                                MatchEventData.periodWarningGiven(
                                  phase: nextPhase,
                                ),
                              ),
                        onPressed: () => _log(
                          MatchEventData.periodWarningGiven(phase: nextPhase!),
                        ),
                      ),
              ),
            ],
          ),
          if (state.phase.isOver) ...[
            gap,
            Text(
              state.phase == MatchPhase.finalized
                  ? 'The match is final.'
                  : 'Play is over. Sign-off follows on the closing screen.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Bovenbalk: teams en score aan de kant waar ze spelen, in het midden de
/// fase, de klok en of het spel loopt.
class _Header extends StatelessWidget {
  const _Header({
    required this.view,
    required this.left,
    required this.right,
    required this.sideWidth,
    required this.onLog,
  });

  final MatchConsoleView view;
  final TeamColor left;
  final TeamColor right;
  final double sideWidth;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final metrics = theme.appMetrics;
    final typography = theme.appTypography;
    final clock = view.clock;
    final state = clock.state;
    final main = mainClock(clock);
    final running = clock.playRunning;

    Widget team(TeamColor team) => SizedBox(
      width: sideWidth,
      child: Column(
        children: [
          Text(
            teamLabel(team).toUpperCase(),
            style: typography.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            team == TeamColor.white ? state.teamWhite : state.teamBlack,
            style: theme.textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${state.score.of(team)}',
            key: ValueKey('score-${team.name}'),
            style: typography.timerDisplay,
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        team(left),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Close console',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                  Flexible(
                    child: Text(
                      main.label,
                      key: const ValueKey('phase'),
                      style: theme.textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('open-log'),
                    tooltip: 'Event log',
                    onPressed: onLog,
                    icon: const Icon(Icons.list_alt),
                  ),
                ],
              ),
              FittedBox(
                child: Text(
                  main.time,
                  key: const ValueKey('clock'),
                  style: typography.timerDisplay,
                ),
              ),
              Wrap(
                spacing: metrics.spacingSm,
                alignment: WrapAlignment.center,
                children: [
                  _Badge(
                    key: const ValueKey('running'),
                    label: running ? 'RUNNING' : 'STOPPED',
                    background: running ? colors.primary : colors.error,
                    foreground: running ? colors.onPrimary : colors.onError,
                  ),
                  if (clock.stoppedClockMode)
                    _Badge(
                      label: 'STOPPED-CLOCK MODE',
                      background: colors.secondary,
                      foreground: colors.onSecondary,
                    ),
                  if (!view.holdsLease)
                    _Badge(
                      label: 'READ ONLY',
                      background: colors.surfaceContainerHighest,
                      foreground: colors.onSurface,
                    ),
                ],
              ),
            ],
          ),
        ),
        team(right),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(metrics.radiusFull),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.spacingMd,
          vertical: metrics.spacingXs,
        ),
        child: Text(
          label,
          style: theme.appTypography.labelCaps.copyWith(color: foreground),
        ),
      ),
    );
  }
}

/// Eén strafklok in de strafbalk. Een uitgezeten straf licht op; een tik
/// registreert dat de speler terug in het water is.
class _PenaltyClock extends StatelessWidget {
  const _PenaltyClock({required this.penalty, required this.onRelease});

  final PenaltyRecord penalty;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final waiting = penalty.status == PenaltyStatus.expiredWaiting;
    return ConsoleButton(
      key: ValueKey('penalty-clock-${penalty.team.name}-${penalty.cap}'),
      label: penaltyLabel(penalty),
      height: ConsoleLayout.smallButtonHeight,
      tone: waiting ? ConsoleButtonTone.primary : ConsoleButtonTone.neutral,
      blockedReason: waiting
          ? null
          : penalty.status == PenaltyStatus.dismissal
          ? 'Dismissed for the rest of the match.'
          : 'This penalty has not been served yet.',
      onPressed: onRelease,
    );
  }
}
