import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_provider.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';
import 'package:hs_coaching_app/features/display/features/tabata/presentation/tabata_screen_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

class TabataControlScreen extends ConsumerWidget {
  const TabataControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabataAsync = ref.watch(tabataNotifierProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.tabata,
      contentList: tabataAsync.when(
        data: (tabata) => _TabataView(tabata: tabata),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading Tabata: $err')),
      ),
    );
  }
}

String _formatSeconds(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _TabataView extends ConsumerWidget {
  const _TabataView({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Zolang de timer niet gestart is tonen we de configuratie; daarna de
    // lopende timer met progress-ring.
    return tabata.isIdle
        ? _TabataConfigView(tabata: tabata)
        : _TabataRunView(tabata: tabata);
  }
}

// ---------------------------------------------------------------------------
// Configuratie (idle)
// ---------------------------------------------------------------------------

class _TabataConfigView extends ConsumerWidget {
  const _TabataConfigView({required this.tabata});
  final Tabata tabata;

  Future<void> _updateSets(TabataCommands commands, List<TabataSet> sets) {
    return commands.updateConfig(tabata.copyWith(sets: sets));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.read(tabataCommandsProvider);
    final presets =
        ref.watch(tabataPresetsProvider).value ?? const <TabataPreset>[];
    final sets = tabata.sets;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ConfigCard(
              label: 'Voorbereiding',
              icon: Icons.accessibility_new,
              color: Colors.lightBlue.shade100,
              value: _formatSeconds(tabata.prepareSeconds),
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Voorbereiding',
                  initial: tabata.prepareSeconds,
                  step: 5,
                  min: 0,
                  max: 120,
                  format: _formatSeconds,
                );
                if (result != null) {
                  await commands.updateConfig(
                    tabata.copyWith(prepareSeconds: result),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Snelkoppelingen naar opgeslagen standaard sets: tikken voegt de
            // set toe aan de configuratie.
            if (presets.isNotEmpty) ...[
              const _SectionLabel(
                icon: Icons.bookmark_outline,
                text: 'Standaard sets',
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final preset in presets)
                    InputChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(
                        preset.set.title.isEmpty ? 'Set' : preset.set.title,
                      ),
                      onPressed: () =>
                          _updateSets(commands, [...sets, preset.set]),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () async {
                        final confirmed = await _confirmPresetDelete(
                          context,
                          preset,
                        );
                        if (confirmed == true) {
                          await commands.deletePreset(preset.id);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            const _SectionLabel(
              icon: Icons.format_list_numbered,
              text: 'Sets',
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < sets.length; i++) ...[
              // Tussen twee sets: tikbare chip met de setrust.
              if (i > 0) ...[
                Center(
                  child: ActionChip(
                    avatar: const Icon(Icons.pause_circle_outline, size: 18),
                    label: Text(
                      'Rust tussen sets: '
                      '${_formatSeconds(sets[i - 1].setRestSeconds)}',
                    ),
                    onPressed: () async {
                      final result = await _showStepperDialog(
                        context,
                        title: 'Rust tussen sets',
                        initial: sets[i - 1].setRestSeconds,
                        step: 5,
                        min: 0,
                        max: 600,
                        format: _formatSeconds,
                      );
                      if (result != null) {
                        final updated = [...sets];
                        updated[i - 1] = sets[i - 1].copyWith(
                          setRestSeconds: result,
                        );
                        await _updateSets(commands, updated);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 4),
              ],
              _SetCard(
                index: i,
                set: sets[i],
                canDelete: sets.length > 1,
                onEdit: () async {
                  final edited = await _showSetEditDialog(
                    context,
                    dialogTitle: sets[i].title.isEmpty
                        ? 'Set ${i + 1}'
                        : sets[i].title,
                    initial: sets[i],
                  );
                  if (edited != null) {
                    final updated = [...sets];
                    updated[i] = edited;
                    await _updateSets(commands, updated);
                  }
                },
                onSaveAsPreset: () async {
                  final set = sets[i];
                  final title = await _showTitleDialog(
                    context,
                    title: 'Bewaar als standaard set',
                    initial: set.title.isEmpty ? 'Set ${i + 1}' : set.title,
                  );
                  if (title == null || title.isEmpty) return;
                  await commands.savePreset(set.copyWith(title: title));
                  // Geef de set in de configuratie dezelfde naam, zodat kaart
                  // en standaard set overeenkomen.
                  if (title != set.title) {
                    final updated = [...sets];
                    updated[i] = set.copyWith(title: title);
                    await _updateSets(commands, updated);
                  }
                },
                onDelete: () async {
                  final updated = [...sets]..removeAt(i);
                  await _updateSets(commands, updated);
                },
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final newSet = await _showSetEditDialog(
                  context,
                  dialogTitle: 'Nieuwe set',
                  initial: const TabataSet(),
                );
                if (newSet != null) {
                  await _updateSets(commands, [...sets, newSet]);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Set toevoegen'),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 20),
                  label: Text(
                    'Totaal: ${_formatSeconds(tabata.totalDurationMillis ~/ 1000)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(tabataCommandsProvider).start(tabata),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Start',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmPresetDelete(
    BuildContext context,
    TabataPreset preset,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Standaard set verwijderen?'),
        content: Text(
          '"${preset.set.title.isEmpty ? 'Set' : preset.set.title}" wordt '
          'definitief uit de bibliotheek verwijderd.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.index,
    required this.set,
    required this.canDelete,
    required this.onEdit,
    required this.onSaveAsPreset,
    required this.onDelete,
  });

  final int index;
  final TabataSet set;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onSaveAsPreset;
  final VoidCallback onDelete;

  String _summary() {
    final beeptest = set.workDecrementSeconds > 0
        ? ' (beeptest -${set.workDecrementSeconds}s/ronde)'
        : '';
    return '${set.rounds} × ${_formatSeconds(set.workSeconds)} werk$beeptest'
        '\n${_formatSeconds(set.restSeconds)} rust · '
        '${_formatSeconds(set.durationMillis ~/ 1000)} totaal';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(
          set.title.isEmpty ? 'Set ${index + 1}' : set.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_summary()),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'save':
                onSaveAsPreset();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: Text('Bewaar als standaard set'),
            ),
            PopupMenuItem(
              value: 'delete',
              enabled: canDelete,
              child: const Text('Verwijderen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialoog met +/- knoppen om een waarde in stappen aan te passen.
Future<int?> _showStepperDialog(
  BuildContext context, {
  required String title,
  required int initial,
  required int step,
  required int min,
  required int max,
  required String Function(int) format,
}) {
  var value = initial;
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: value - step >= min
                  ? () => setState(() => value -= step)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 110,
              child: Text(
                format(value),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: value + step <= max
                  ? () => setState(() => value += step)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(value),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

/// Dialoog om een volledige [TabataSet] te bewerken: titel, werk, rust,
/// rondes en de beeptest-aftrek.
Future<TabataSet?> _showSetEditDialog(
  BuildContext context, {
  required String dialogTitle,
  required TabataSet initial,
}) {
  return showDialog<TabataSet>(
    context: context,
    builder: (context) =>
        _SetEditDialog(dialogTitle: dialogTitle, initial: initial),
  );
}

class _SetEditDialog extends StatefulWidget {
  const _SetEditDialog({required this.dialogTitle, required this.initial});

  final String dialogTitle;
  final TabataSet initial;

  @override
  State<_SetEditDialog> createState() => _SetEditDialogState();
}

class _SetEditDialogState extends State<_SetEditDialog> {
  late final TextEditingController _titleController;
  late TabataSet _set;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title);
    _set = widget.initial;
  }

  @override
  void dispose() {
    // Pas hier disposen (niet meteen na `await showDialog(...)`): tijdens de
    // pop-animatie staat de TextField nog in de tree en zou een controller
    // die direct na de await al disposed is een "used after disposed" crash
    // geven.
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'Bv. Onderwaters',
                ),
              ),
              const SizedBox(height: 16),
              _StepperRow(
                label: 'Werk',
                value: _set.workSeconds,
                step: 5,
                min: 5,
                max: 600,
                format: _formatSeconds,
                onChanged: (v) =>
                    setState(() => _set = _set.copyWith(workSeconds: v)),
              ),
              _StepperRow(
                label: 'Rust',
                value: _set.restSeconds,
                step: 5,
                min: 0,
                max: 600,
                format: _formatSeconds,
                onChanged: (v) =>
                    setState(() => _set = _set.copyWith(restSeconds: v)),
              ),
              _StepperRow(
                label: 'Rondes',
                value: _set.rounds,
                step: 1,
                min: 1,
                max: 50,
                format: (v) => '$v',
                onChanged: (v) =>
                    setState(() => _set = _set.copyWith(rounds: v)),
              ),
              _StepperRow(
                label: 'Beeptest\n(-s per ronde)',
                value: _set.workDecrementSeconds,
                step: 1,
                min: 0,
                max: 60,
                format: (v) => '${v}s',
                onChanged: (v) => setState(
                  () => _set = _set.copyWith(workDecrementSeconds: v),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_set.copyWith(title: _titleController.text.trim())),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Dialoog om (enkel) een titel in te voeren.
Future<String?> _showTitleDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TitleDialog(title: title, initial: initial),
  );
}

class _TitleDialog extends StatefulWidget {
  const _TitleDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Titel',
          hintText: 'Bv. Onderwaters',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Bewaren'),
        ),
      ],
    );
  }
}

/// Compacte rij met label en +/- knoppen voor in de set-dialoog.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int step;
  final int min;
  final int max;
  final String Function(int) format;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton.filledTonal(
            onPressed: value - step >= min
                ? () => onChanged(value - step)
                : null,
            icon: const Icon(Icons.remove),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 64,
            child: Text(
              format(value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: value + step <= max
                ? () => onChanged(value + step)
                : null,
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lopende timer
// ---------------------------------------------------------------------------

class _TabataRunView extends ConsumerWidget {
  const _TabataRunView({required this.tabata});
  final Tabata tabata;

  static const _phaseColors = {
    TabataPhase.prepare: Colors.lightBlue,
    TabataPhase.work: Colors.deepOrange,
    TabataPhase.rest: Colors.green,
    TabataPhase.setRest: Colors.teal,
    TabataPhase.finished: Colors.blueGrey,
  };

  static const _phaseLabels = {
    TabataPhase.prepare: 'Voorbereiden',
    TabataPhase.work: 'Werk',
    TabataPhase.rest: 'Rust',
    TabataPhase.setRest: 'Setrust',
    TabataPhase.finished: 'Klaar!',
  };

  String _formatRemaining(Duration d) {
    final secondsLeft = (d.inMilliseconds / 1000).ceil();
    return _formatSeconds(secondsLeft < 0 ? 0 : secondsLeft);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(tabataScreenControllerProvider);
    final commands = ref.read(tabataCommandsProvider);

    final status = tabata.status;
    final phaseColor = _phaseColors[progress.phase]!;
    final isFinished = progress.phase == TabataPhase.finished;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Spacer(),

          // Titel en nummer van de huidige set
          if (progress.setTitle.isNotEmpty || progress.totalSets > 1) ...[
            Text(
              progress.setTitle.isNotEmpty ? progress.setTitle : 'Tabata',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (progress.totalSets > 1)
              Text(
                'Set ${progress.setIndex} van ${progress.totalSets}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
          ],

          // Progress-ring met resterende fasetijd en ronde
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: isFinished ? 1 : progress.phaseRemainingFraction,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  color: phaseColor,
                  backgroundColor: Colors.grey.shade300,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ronde ${progress.round}/${progress.totalRounds}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      isFinished
                          ? '00:00'
                          : _formatRemaining(progress.phaseRemaining),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                    Text(
                      _phaseLabels[progress.phase]!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Verstreken / resterende totaaltijd
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Verstreken'),
                  Text(
                    _formatSeconds(progress.elapsed.inSeconds),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Resterend'),
                  Text(
                    _formatRemaining(progress.totalRemaining),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Bedieningsknoppen (zelfde stijl als Chrono)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => commands.reset(tabata),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                height: 54,
                child: status == TabataStatus.running && !isFinished
                    ? ElevatedButton(
                        onPressed: () => commands.pause(tabata),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Pause',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: isFinished
                            ? null
                            : () => commands.start(tabata),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Resume',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              // Symmetrische spacer zodat de middenknop gecentreerd blijft
              const SizedBox(width: 116),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
