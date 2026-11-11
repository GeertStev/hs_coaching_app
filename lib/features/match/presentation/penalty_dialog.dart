import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/presentation/cap_pad.dart';
import 'package:hs_coaching_app/features/match/presentation/console_button.dart';
import 'package:hs_coaching_app/features/match/presentation/match_texts.dart';
import 'package:hs_coaching_core/match/engine/infringement_table.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:hs_coaching_core/team/team_model.dart';

/// De straffen die de tafel kan geven.
enum PenaltyChoice {
  caution('Caution'),
  oneMinute('1 min'),
  twoMinutes('2 min'),
  fiveMinutes('5 min'),
  dismissal('Dismissal');

  const PenaltyChoice(this.label);
  final String label;

  int? get minutes => switch (this) {
    oneMinute => 1,
    twoMinutes => 2,
    fiveMinutes => 5,
    _ => null,
  };
}

/// Vertaalt een sanctie uit tabel 17.7.1 naar een keuze van de tafel. `null`
/// voor sancties die geen straf voor een speler zijn (strafworp, forfait).
PenaltyChoice? penaltyChoiceFor(Sanction sanction) => switch (sanction) {
  Sanction.individualCaution ||
  Sanction.teamCaution ||
  Sanction.caution => PenaltyChoice.caution,
  Sanction.oneMinute => PenaltyChoice.oneMinute,
  Sanction.twoMinutes => PenaltyChoice.twoMinutes,
  Sanction.fiveMinutes => PenaltyChoice.fiveMinutes,
  Sanction.dismissal => PenaltyChoice.dismissal,
  Sanction.penaltyShot || Sanction.penaltyGoal || Sanction.gameForfeit => null,
};

/// Het event dat bij de keuzes hoort, of `null` als er nog iets ontbreekt
/// (een tijdstraf of uitsluiting heeft altijd een kapnummer nodig).
MatchEventData? penaltyEventFor({
  required TeamColor team,
  required int? cap,
  required PenaltyChoice choice,
  required String infringementCode,
  required bool deliberate,
}) {
  final minutes = choice.minutes;
  if (choice == PenaltyChoice.caution) {
    return MatchEventData.cautionGiven(
      team: team,
      cap: cap,
      infringementCode: infringementCode,
      deliberate: deliberate,
      isTeamCaution: cap == null,
    );
  }
  if (cap == null) return null;
  if (minutes != null) {
    return MatchEventData.timePenaltyGiven(
      team: team,
      cap: cap,
      minutes: minutes,
      infringementCode: infringementCode,
      deliberate: deliberate,
    );
  }
  return MatchEventData.playerDismissed(
    team: team,
    cap: cap,
    infringementCode: infringementCode,
  );
}

/// Straf voor [team]: kapnummer, overtreding, opzettelijk of niet, en de
/// straf. De suggestie uit tabel 17.7.1 staat voorgeselecteerd, maar de
/// scheidsrechter beslist: elke andere keuze blijft mogelijk.
Future<MatchEventData?> showPenaltyDialog(
  BuildContext context, {
  required MatchSession session,
  required InfringementTable table,
  required TeamColor team,
}) {
  return showDialog<MatchEventData>(
    context: context,
    builder: (context) =>
        _PenaltyDialog(session: session, table: table, team: team),
  );
}

class _PenaltyDialog extends StatefulWidget {
  const _PenaltyDialog({
    required this.session,
    required this.table,
    required this.team,
  });

  final MatchSession session;
  final InfringementTable table;
  final TeamColor team;

  @override
  State<_PenaltyDialog> createState() => _PenaltyDialogState();
}

class _PenaltyDialogState extends State<_PenaltyDialog> {
  int? _cap;
  String? _code;
  bool _deliberate = false;

  /// Alleen gezet als de tafel zelf een straf koos; anders geldt de suggestie.
  PenaltyChoice? _manualChoice;

  PenaltyChoice? get _suggested {
    final code = _code;
    if (code == null) return null;
    final suggestion = widget.table.suggestPenalty(
      widget.session.state,
      widget.team,
      _cap,
      code,
      _deliberate,
    );
    for (final option
        in suggestion?.step?.options ?? const <List<Sanction>>[]) {
      for (final sanction in option) {
        final choice = penaltyChoiceFor(sanction);
        if (choice != null) return choice;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final suggested = _suggested;
    final choice = _manualChoice ?? suggested;
    final code = _code;

    final event = choice == null || code == null
        ? null
        : penaltyEventFor(
            team: widget.team,
            cap: _cap,
            choice: choice,
            infringementCode: code,
            deliberate: _deliberate,
          );
    final rejection = event == null ? null : widget.session.check(event);
    final problem = code == null
        ? 'Choose the infringement.'
        : choice == null
        ? 'Choose the penalty.'
        : event == null
        ? 'Choose the cap number.'
        : rejection == null
        ? null
        : rejectionMessage(rejection);

    return AlertDialog(
      title: Text('Penalty ${teamLabel(widget.team)}'),
      content: SizedBox(
        width: ConsoleLayout.dialogWidth,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 5 * ConsoleLayout.padKey + 4 * metrics.spacingXs,
                child: CapPad(
                  selected: _cap,
                  onSelected: (cap) =>
                      setState(() => _cap = _cap == cap ? null : cap),
                ),
              ),
              SizedBox(width: metrics.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      key: const ValueKey('infringement'),
                      isExpanded: true,
                      initialValue: _code,
                      decoration: const InputDecoration(
                        labelText: 'Infringement',
                      ),
                      items: [
                        for (final item in widget.table.infringements)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.id} ${item.name} (${item.handSignal})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => _code = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deliberate'),
                      value: _deliberate,
                      onChanged: (value) => setState(() => _deliberate = value),
                    ),
                    Wrap(
                      spacing: metrics.spacingXs,
                      runSpacing: metrics.spacingXs,
                      children: [
                        for (final option in PenaltyChoice.values)
                          ChoiceChip(
                            key: ValueKey('penalty-${option.name}'),
                            label: Text(
                              option == suggested
                                  ? '${option.label} (suggested)'
                                  : option.label,
                            ),
                            selected: option == choice,
                            onSelected: (_) =>
                                setState(() => _manualChoice = option),
                          ),
                      ],
                    ),
                    if (problem != null) ...[
                      SizedBox(height: metrics.spacingSm),
                      Text(
                        problem,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('penalty-confirm'),
          onPressed: problem == null
              ? () => Navigator.of(context).pop(event)
              : null,
          child: const Text('Give penalty'),
        ),
      ],
    );
  }
}
