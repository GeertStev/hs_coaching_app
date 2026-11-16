import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/scheduler_texts.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';

/// Een speler van de spelerslijst toevoegen ([playerId] `null`) of bewerken:
/// naam, posities met startrating, en de handmatige aanpassingen.
class PlayerEditScreen extends ConsumerStatefulWidget {
  const PlayerEditScreen({super.key, this.playerId});

  final String? playerId;

  @override
  ConsumerState<PlayerEditScreen> createState() => _PlayerEditScreenState();
}

class _PlayerEditScreenState extends ConsumerState<PlayerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _surname = TextEditingController();
  final _nickname = TextEditingController();
  final _totem = TextEditingController();
  final _startRatings = {
    for (final position in PlayerPosition.values)
      position: TextEditingController(),
  };
  final _positions = <PlayerPosition>{};
  bool _active = true;
  bool _saving = false;

  /// Het id van de speler; wordt gezet zodra een nieuwe speler bewaard is.
  String? _playerId;
  SquadPlayer? _loaded;

  @override
  void initState() {
    super.initState();
    _playerId = widget.playerId;
    final id = _playerId;
    if (id == null) return;
    final players = ref.read(squadPlayersProvider).value ?? const [];
    for (final player in players) {
      if (player.id == id) _fill(player);
    }
  }

  void _fill(SquadPlayer player) {
    _loaded = player;
    _firstName.text = player.firstName;
    _surname.text = player.surname;
    _nickname.text = player.nickname;
    _totem.text = player.totem;
    _active = player.active;
    _positions
      ..clear()
      ..addAll(player.positions);
    for (final position in PlayerPosition.values) {
      _startRatings[position]!.text =
          player.startRatings[position]?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _surname,
      _nickname,
      _totem,
      ..._startRatings.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final player = (_loaded ?? const SquadPlayer(firstName: '')).copyWith(
      id: _playerId ?? '',
      firstName: _firstName.text.trim(),
      surname: _surname.text.trim(),
      nickname: _nickname.text.trim(),
      totem: _totem.text.trim(),
      active: _active,
      positions: [
        for (final position in PlayerPosition.values)
          if (_positions.contains(position)) position,
      ],
      startRatings: {
        for (final position in PlayerPosition.values)
          position: ?int.tryParse(_startRatings[position]!.text),
      },
    );
    setState(() => _saving = true);
    try {
      await ref.read(schedulerRepositoryProvider).savePlayer(player);
      navigator.pop();
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'speler bewaren');
      if (mounted) {
        showErrorSnackBar(context, error);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final id = _playerId;
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add player' : 'Edit player'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(metrics.containerMargin),
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'First name'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a first name' : null,
            ),
            SizedBox(height: metrics.spacingSm),
            TextFormField(
              controller: _surname,
              decoration: const InputDecoration(labelText: 'Surname'),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: metrics.spacingSm),
            TextFormField(
              controller: _nickname,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                helperText: 'Shown in lists and on the pool screen',
              ),
            ),
            SizedBox(height: metrics.spacingSm),
            TextFormField(
              controller: _totem,
              decoration: const InputDecoration(labelText: 'Totem'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text('Inactive players are hidden from lists'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
            SizedBox(height: metrics.spacingMd),
            Text('POSITIONS', style: theme.appTypography.labelCaps),
            SizedBox(height: metrics.spacingXs),
            Text(
              'Tick the positions the scheduler may use. The start rating '
              'is where the rating began; games and adjustments are added '
              'on top of it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            for (final position in PlayerPosition.values)
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(position.label),
                      value: _positions.contains(position),
                      onChanged: (value) => setState(() {
                        if (value ?? false) {
                          _positions.add(position);
                        } else {
                          _positions.remove(position);
                        }
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      key: ValueKey('start-${position.code}'),
                      controller: _startRatings[position],
                      decoration: const InputDecoration(
                        labelText: 'Start rating',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _positions.contains(position) &&
                              int.tryParse(value ?? '') == null
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),
            if (id != null) ...[
              SizedBox(height: metrics.spacingLg),
              _AdjustmentsSection(playerId: id),
            ],
          ],
        ),
      ),
    );
  }
}

/// De handmatige aanpassingen van één speler, met toevoegen en verwijderen.
class _AdjustmentsSection extends ConsumerWidget {
  const _AdjustmentsSection({required this.playerId});

  final String playerId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final today = ref.read(schedulerTodayProvider);
    final adjustment = await showDialog<RatingAdjustment>(
      context: context,
      builder: (_) => _AdjustmentDialog(playerId: playerId, today: today),
    );
    if (adjustment == null) return;
    try {
      await ref.read(schedulerRepositoryProvider).saveAdjustment(adjustment);
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'aanpassing bewaren');
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RatingAdjustment adjustment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete adjustment?'),
        content: Text(
          '${signed(adjustment.change)} from ${adjustment.start}. '
          'The ratings are recalculated without it.',
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
      await ref
          .read(schedulerRepositoryProvider)
          .deleteAdjustment(adjustment.id);
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'aanpassing verwijderen');
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    final all = ref.watch(ratingAdjustmentsProvider).value ?? const [];
    final own = [
      for (final adjustment in all)
        if (adjustment.playerId == playerId) adjustment,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('ADJUSTMENTS', style: theme.appTypography.labelCaps),
            ),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add adjustment'),
            ),
          ],
        ),
        if (own.isEmpty)
          Text(
            'No adjustments. Use one for an injury, a long break or a new '
            'player whose start rating was off. It applies to all positions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final adjustment in own)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              signed(adjustment.change),
              style: theme.appTypography.dataPoint,
            ),
            title: Text(
              adjustment.type == RatingAdjustmentType.instant
                  ? '${adjustmentTypeLabel(adjustment.type)} on '
                        '${adjustment.start}'
                  : '${adjustmentTypeLabel(adjustment.type)} from '
                        '${adjustment.start} to ${adjustment.end}',
            ),
            subtitle: adjustment.reason.isEmpty
                ? null
                : Text(adjustment.reason),
            trailing: IconButton(
              tooltip: 'Delete adjustment',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, adjustment),
            ),
          ),
        SizedBox(height: metrics.spacingLg),
      ],
    );
  }
}

class _AdjustmentDialog extends StatefulWidget {
  const _AdjustmentDialog({required this.playerId, required this.today});

  final String playerId;
  final String today;

  @override
  State<_AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<_AdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _change = TextEditingController();
  final _reason = TextEditingController();
  var _type = RatingAdjustmentType.instant;
  late String _start = widget.today;
  late String _end = widget.today;

  @override
  void dispose() {
    _change.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool start}) async {
    final current = DateTime.parse(start ? _start : _end);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = isoDate(picked);
        if (_end.compareTo(_start) < 0) _end = _start;
      } else {
        _end = isoDate(picked);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final linear = _type == RatingAdjustmentType.linear;
    Navigator.of(context).pop(
      RatingAdjustment(
        playerId: widget.playerId,
        type: _type,
        start: _start,
        end: linear ? _end : _start,
        change: double.parse(_change.text.replaceAll(',', '.')),
        reason: _reason.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    final linear = _type == RatingAdjustmentType.linear;
    return AlertDialog(
      title: const Text('Add adjustment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<RatingAdjustmentType>(
                showSelectedIcon: false,
                segments: [
                  for (final type in RatingAdjustmentType.values)
                    ButtonSegment(
                      value: type,
                      label: Text(adjustmentTypeLabel(type)),
                    ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.single),
              ),
              SizedBox(height: metrics.spacingXs),
              Text(
                linear
                    ? 'Spread evenly over the days between start and end.'
                    : 'Applied at once on the start date.',
              ),
              SizedBox(height: metrics.spacingSm),
              TextFormField(
                controller: _change,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Change in rating points',
                  hintText: '-50',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: (value) {
                  final number = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  return number == null || number == 0
                      ? 'Enter a number, for example -50'
                      : null;
                },
              ),
              SizedBox(height: metrics.spacingSm),
              OutlinedButton.icon(
                onPressed: () => _pick(start: true),
                icon: const Icon(Icons.event),
                label: Text(linear ? 'Start: $_start' : 'Date: $_start'),
              ),
              if (linear) ...[
                SizedBox(height: metrics.spacingXs),
                OutlinedButton.icon(
                  onPressed: () => _pick(start: false),
                  icon: const Icon(Icons.event),
                  label: Text('End: $_end'),
                ),
              ],
              SizedBox(height: metrics.spacingSm),
              TextFormField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason'),
                textCapitalization: TextCapitalization.sentences,
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
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
