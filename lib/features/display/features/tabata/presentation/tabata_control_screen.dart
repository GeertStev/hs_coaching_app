import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_provider.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_progress.dart';
import 'package:hs_coaching_app/features/display/features/tabata/presentation/tabata_screen_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

class TabataControlScreen extends ConsumerWidget {
  const TabataControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabataAsync = ref.watch(tabataNotifierProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.tabata,
      body: tabataAsync.when(
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

String _formatStep(int stepSeconds) {
  if (stepSeconds == 0) return '0s';
  return stepSeconds > 0 ? '+${stepSeconds}s' : '${stepSeconds}s';
}

class _TabataView extends ConsumerWidget {
  const _TabataView({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Zolang de timer niet gestart is tonen we de editor/lijst-tabs; daarna
    // de lopende timer met progress-ring.
    return tabata.isIdle
        ? _TabataConfigView(tabata: tabata)
        : _TabataRunView(tabata: tabata);
  }
}

// ---------------------------------------------------------------------------
// Configuratie (idle): Editor- en List-tab
// ---------------------------------------------------------------------------

class _TabataConfigView extends StatelessWidget {
  const _TabataConfigView({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.edit_note), text: 'Editor'),
                Tab(icon: Icon(Icons.list), text: 'List'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _EditorTab(tabata: tabata),
                _ListTab(tabata: tabata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimale editor: work/rest/rounds/sets, geen kaarten, geen slepen.
class _EditorTab extends ConsumerWidget {
  const _EditorTab({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.read(tabataCommandsProvider);

    Future<void> update(Tabata Function(Tabata current) transform) {
      return commands.updateConfig(transform(tabata));
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _ConfigRow(
              label: 'Prepare',
              value: _formatSeconds(tabata.prepareSeconds),
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Prepare',
                  initial: tabata.prepareSeconds,
                  step: 5,
                  min: 0,
                  max: 120,
                  format: _formatSeconds,
                );
                if (result != null) {
                  await update((t) => t.copyWith(prepareSeconds: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Work',
              value: _formatSeconds(tabata.workSeconds),
              color: Colors.deepOrange,
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Work',
                  initial: tabata.workSeconds,
                  step: 5,
                  min: 5,
                  max: 600,
                  format: _formatSeconds,
                );
                if (result != null) {
                  await update((t) => t.copyWith(workSeconds: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Rest (between rounds)',
              value: _formatSeconds(tabata.restSeconds),
              color: Colors.green,
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Rest (between rounds)',
                  initial: tabata.restSeconds,
                  step: 5,
                  min: 0,
                  max: 600,
                  format: _formatSeconds,
                );
                if (result != null) {
                  await update((t) => t.copyWith(restSeconds: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Step per round\n(+ = longer, - = shorter)',
              value: _formatStep(tabata.stepSeconds),
              color: tabata.stepSeconds == 0
                  ? null
                  : (tabata.stepSeconds < 0
                        ? Colors.deepOrange
                        : Colors.green),
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Step per round\n(+ = longer, - = shorter)',
                  initial: tabata.stepSeconds,
                  step: 1,
                  min: -60,
                  max: 60,
                  format: _formatStep,
                );
                if (result != null) {
                  await update((t) => t.copyWith(stepSeconds: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Rounds',
              value: '${tabata.rounds}x',
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Rounds',
                  initial: tabata.rounds,
                  step: 1,
                  min: 1,
                  max: 50,
                  format: (v) => '$v',
                );
                if (result != null) {
                  await update((t) => t.copyWith(rounds: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Sets',
              value: '${tabata.sets}x',
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Sets',
                  initial: tabata.sets,
                  step: 1,
                  min: 1,
                  max: 20,
                  format: (v) => '$v',
                );
                if (result != null) {
                  await update((t) => t.copyWith(sets: result));
                }
              },
            ),
            _ConfigRow(
              label: 'Rest between sets',
              value: _formatSeconds(tabata.restBetweenSets),
              color: Colors.teal,
              onTap: () async {
                final result = await _showStepperDialog(
                  context,
                  title: 'Rest between sets',
                  initial: tabata.restBetweenSets,
                  step: 5,
                  min: 0,
                  max: 900,
                  format: _formatSeconds,
                );
                if (result != null) {
                  await update((t) => t.copyWith(restBetweenSets: result));
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ${_formatSeconds(tabata.totalDurationMillis ~/ 1000)}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _FloatingStartBar(tabata: tabata),
        ),
      ],
    );
  }
}

/// Eén rij in de minimale editor: label links, tikbare pill-waarde rechts.
class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.color,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: _Pill(label: value, color: color, onTap: onTap),
          ),
        ],
      ),
    );
  }
}

/// Klein tikbaar label (waarde-pill). [color] geeft een subtiele
/// accentkleur (bv. werktijd, of stap-richting); zonder kleur is de pill
/// neutraal.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color?.withValues(alpha: 0.12) ?? scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: color == null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color!, width: 1.5),
                ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: color ?? scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Zwevende start-knop onderaan het scherm: pint aan de onderkant met een
/// vervagende achtergrond, zodat de instelrijen die er onder scrollen niet
/// hard afgesneden worden.
class _FloatingStartBar extends ConsumerWidget {
  const _FloatingStartBar({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final canStart =
        tabata.workSeconds > 0 && tabata.rounds > 0 && tabata.sets > 0;
    return IgnorePointer(
      ignoring: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor.withValues(alpha: 0), backgroundColor],
          ),
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: canStart
                ? () => ref.read(tabataCommandsProvider).start(tabata)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Start',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List-tab: bibliotheek van opgeslagen sessies
// ---------------------------------------------------------------------------

class _ListTab extends ConsumerWidget {
  const _ListTab({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.read(tabataCommandsProvider);
    final presetsAsync = ref.watch(tabataPresetsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final title = await _showTitleDialog(
                  context,
                  title: 'Bewaar huidige sessie',
                  initial: '',
                );
                if (title == null || title.isEmpty) return;
                await commands.savePreset(title, tabata);
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Huidige sessie bewaren'),
            ),
          ),
        ),
        Expanded(
          child: presetsAsync.when(
            data: (presets) {
              if (presets.isEmpty) {
                return const Center(
                  child: Text('Nog geen opgeslagen sessies.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final durationMillis = Tabata(
                    prepareSeconds: 0,
                    workSeconds: preset.workSeconds,
                    restSeconds: preset.restSeconds,
                    stepSeconds: preset.stepSeconds,
                    rounds: preset.rounds,
                    sets: preset.sets,
                    restBetweenSets: preset.restBetweenSets,
                  ).totalDurationMillis;
                  return Card(
                    child: ListTile(
                      title: Text(
                        preset.title.isEmpty ? 'Sessie' : preset.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${preset.rounds} rondes × ${preset.sets} sets · '
                        '${_formatSeconds(durationMillis ~/ 1000)} totaal',
                      ),
                      onTap: () async {
                        await commands.updateConfig(
                          tabata.copyWith(
                            workSeconds: preset.workSeconds,
                            restSeconds: preset.restSeconds,
                            stepSeconds: preset.stepSeconds,
                            rounds: preset.rounds,
                            sets: preset.sets,
                            restBetweenSets: preset.restBetweenSets,
                          ),
                        );
                        if (context.mounted) {
                          DefaultTabController.of(context).animateTo(0);
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await _confirmPresetDelete(
                            context,
                            preset,
                          );
                          if (confirmed == true) {
                            await commands.deletePreset(preset.id);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Fout bij laden: $err')),
          ),
        ),
      ],
    );
  }
}

Future<bool?> _confirmPresetDelete(BuildContext context, TabataPreset preset) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Opgeslagen sessie verwijderen?'),
      content: Text(
        '"${preset.title.isEmpty ? 'Sessie' : preset.title}" wordt '
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
    TabataPhase.restBetweenSets: Colors.teal,
    TabataPhase.finished: Colors.blueGrey,
  };

  static const _phaseLabels = {
    TabataPhase.prepare: 'Voorbereiden',
    TabataPhase.work: 'Werk',
    TabataPhase.rest: 'Rust',
    TabataPhase.restBetweenSets: 'Setrust',
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

          // Setnummer, enkel zinvol bij meer dan 1 set
          if (progress.totalSets > 1) ...[
            Text(
              'Set ${progress.set} of ${progress.totalSets}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                      'Round ${progress.round}/${progress.totalRounds}',
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
