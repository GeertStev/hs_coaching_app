import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_provider.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_group.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item_tree.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';
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

class _EditorTab extends ConsumerWidget {
  const _EditorTab({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.read(tabataCommandsProvider);
    final items = tabata.items;

    Future<void> updateItems(List<TabataItem> newItems) {
      return commands.updateConfig(tabata.copyWith(items: newItems));
    }

    void onChangeExercise(TabataExercise updated) =>
        updateItems(replaceExercise(items, updated));
    void onChangeGroup(TabataGroup updated) =>
        updateItems(replaceGroup(items, updated));
    void onDeleteId(String id) => updateItems(removeItem(items, id));

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          children: [
            const _ColumnHeaders(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                avatar: const Icon(Icons.accessibility_new, size: 16),
                label: Text('Prepare ${_formatSeconds(tabata.prepareSeconds)}'),
                onPressed: () async {
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
                    await commands.updateConfig(
                      tabata.copyWith(prepareSeconds: result),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _EmptyInsert(
                onInsert: () =>
                    updateItems(insertExercise(items, 0, newTabataExercise())),
              ),
            for (var i = 0; i < items.length; i++) ...[
              _TopLevelItemCard(
                item: items[i],
                onChangeExercise: onChangeExercise,
                onChangeGroup: onChangeGroup,
                onDeleteId: onDeleteId,
                onDropGroup: (draggedId) =>
                    updateItems(groupWithTarget(items, draggedId, items[i].id)),
              ),
              _InsertGap(
                targetIndex: i + 1,
                restAfter: items[i].restAfter,
                showRestPill: i < items.length - 1,
                onInsert: () =>
                    updateItems(insertExercise(items, i + 1, newTabataExercise())),
                onEditRest: (value) => updateItems(
                  switch (items[i]) {
                    TabataItemExercise(:final exercise) => replaceExercise(
                      items,
                      exercise.copyWith(restAfter: value),
                    ),
                    TabataItemGroup(:final group) => replaceGroup(
                      items,
                      group.copyWith(restAfter: value),
                    ),
                  },
                ),
                onDropReorder: (draggedId) =>
                    updateItems(moveItem(items, draggedId, i + 1)),
              ),
            ],
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

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.outline,
    );
    Widget label(String text) => Expanded(
      child: Center(child: Text(text, style: style)),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 36),
      child: Row(
        children: [
          label('ROUNDS'),
          const SizedBox(width: 6),
          label('WORK'),
          const SizedBox(width: 6),
          label('REST'),
          const SizedBox(width: 6),
          label('STEP'),
        ],
      ),
    );
  }
}

/// Een top-level kaart (losse oefening of groep) met slepen-om-te-groeperen:
/// droppen op de body van deze kaart voegt de gesleepte oefening toe aan een
/// (nieuwe of bestaande) groep.
class _TopLevelItemCard extends StatelessWidget {
  const _TopLevelItemCard({
    required this.item,
    required this.onChangeExercise,
    required this.onChangeGroup,
    required this.onDeleteId,
    required this.onDropGroup,
  });

  final TabataItem item;
  final ValueChanged<TabataExercise> onChangeExercise;
  final ValueChanged<TabataGroup> onChangeGroup;
  final ValueChanged<String> onDeleteId;
  final ValueChanged<String> onDropGroup;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != item.id,
      onAcceptWithDetails: (details) => onDropGroup(details.data),
      builder: (context, candidateData, rejectedData) {
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          color: candidateData.isNotEmpty
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: switch (item) {
              TabataItemExercise(:final exercise) => _ExerciseCardView(
                exercise: exercise,
                onChanged: onChangeExercise,
                onDelete: () => onDeleteId(exercise.id),
              ),
              TabataItemGroup(:final group) => _GroupCardView(
                group: group,
                onChangeGroup: onChangeGroup,
                onChangeExercise: onChangeExercise,
                onDeleteId: onDeleteId,
              ),
            },
          ),
        );
      },
    );
  }
}

class _GroupCardView extends StatelessWidget {
  const _GroupCardView({
    required this.group,
    required this.onChangeGroup,
    required this.onChangeExercise,
    required this.onDeleteId,
  });

  final TabataGroup group;
  final ValueChanged<TabataGroup> onChangeGroup;
  final ValueChanged<TabataExercise> onChangeExercise;
  final ValueChanged<String> onDeleteId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DragHandle(id: group.id),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final title = await _showTitleDialog(
                    context,
                    title: 'Naam groep',
                    initial: group.title,
                  );
                  if (title != null) onChangeGroup(group.copyWith(title: title));
                },
                child: Text(
                  group.title.isEmpty ? 'Groep' : group.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: _Pill(
                label: '${group.rounds}x',
                onTap: () async {
                  final value = await _showStepperDialog(
                    context,
                    title: 'Herhalingen van de groep',
                    initial: group.rounds,
                    step: 1,
                    min: 1,
                    max: 50,
                    format: (v) => '$v',
                  );
                  if (value != null) {
                    onChangeGroup(group.copyWith(rounds: value));
                  }
                },
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 72,
              child: _Pill(
                label: _formatSeconds(group.restBetweenRepeats),
                color: Colors.green,
                onTap: () async {
                  final value = await _showStepperDialog(
                    context,
                    title: 'Rust tussen herhalingen',
                    initial: group.restBetweenRepeats,
                    step: 5,
                    min: 0,
                    max: 600,
                    format: _formatSeconds,
                  );
                  if (value != null) {
                    onChangeGroup(group.copyWith(restBetweenRepeats: value));
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              onPressed: () => onDeleteId(group.id),
            ),
          ],
        ),
        const Divider(height: 16),
        for (var i = 0; i < group.children.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _ExerciseCardView(
              exercise: group.children[i],
              nested: true,
              onChanged: onChangeExercise,
              onDelete: () => onDeleteId(group.children[i].id),
            ),
          ),
          if (i < group.children.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: ActionChip(
                  avatar: const Icon(Icons.pause_circle_outline, size: 16),
                  label: Text(_formatSeconds(group.children[i].restAfter)),
                  onPressed: () async {
                    final child = group.children[i];
                    final value = await _showStepperDialog(
                      context,
                      title: 'Rust tot volgende oefening',
                      initial: child.restAfter,
                      step: 5,
                      min: 0,
                      max: 600,
                      format: _formatSeconds,
                    );
                    if (value != null) {
                      onChangeExercise(child.copyWith(restAfter: value));
                    }
                  },
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// De inhoud van één oefening-kaart: sleephandvat, titel en de 4 kolommen
/// (rondes/werk/rust/stap). Wordt zowel top-level als genest (in een groep)
/// gebruikt — [nested] bepaalt enkel de visuele weging.
class _ExerciseCardView extends StatelessWidget {
  const _ExerciseCardView({
    required this.exercise,
    required this.onChanged,
    required this.onDelete,
    this.nested = false,
  });

  final TabataExercise exercise;
  final ValueChanged<TabataExercise> onChanged;
  final VoidCallback onDelete;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(id: exercise.id),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final title = await _showTitleDialog(
                          context,
                          title: 'Naam oefening',
                          initial: exercise.title,
                        );
                        if (title != null) {
                          onChanged(exercise.copyWith(title: title));
                        }
                      },
                      child: Text(
                        exercise.title.isEmpty
                            ? (nested ? 'Oefening' : 'Exercise')
                            : exercise.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: nested ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _Pill(
                      label: '${exercise.rounds}x',
                      onTap: () async {
                        final value = await _showStepperDialog(
                          context,
                          title: 'Rondes',
                          initial: exercise.rounds,
                          step: 1,
                          min: 1,
                          max: 50,
                          format: (v) => '$v',
                        );
                        if (value != null) {
                          onChanged(exercise.copyWith(rounds: value));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _Pill(
                      label: _formatSeconds(exercise.workSeconds),
                      color: Colors.deepOrange,
                      onTap: () async {
                        final value = await _showStepperDialog(
                          context,
                          title: 'Werk',
                          initial: exercise.workSeconds,
                          step: 5,
                          min: 5,
                          max: 600,
                          format: _formatSeconds,
                        );
                        if (value != null) {
                          onChanged(exercise.copyWith(workSeconds: value));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _Pill(
                      label: _formatSeconds(exercise.restSeconds),
                      onTap: () async {
                        final value = await _showStepperDialog(
                          context,
                          title: 'Rust (tussen rondes)',
                          initial: exercise.restSeconds,
                          step: 5,
                          min: 0,
                          max: 600,
                          format: _formatSeconds,
                        );
                        if (value != null) {
                          onChanged(exercise.copyWith(restSeconds: value));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _Pill(
                      label: _formatStep(exercise.stepSeconds),
                      color: exercise.stepSeconds == 0
                          ? null
                          : (exercise.stepSeconds < 0
                                ? Colors.deepOrange
                                : Colors.green),
                      onTap: () async {
                        final value = await _showStepperDialog(
                          context,
                          title: 'Stap per ronde\n(+ = langer, - = korter)',
                          initial: exercise.stepSeconds,
                          step: 1,
                          min: -60,
                          max: 60,
                          format: _formatStep,
                        );
                        if (value != null) {
                          onChanged(exercise.copyWith(stepSeconds: value));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sleephandvat: lang indrukken en verslepen om te herordenen of te
/// groeperen (zie [_InsertGap] resp. [_TopLevelItemCard]).
class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.drag_indicator, color: Colors.grey);
    return LongPressDraggable<String>(
      data: id,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.3, child: icon),
      child: icon,
    );
  }
}

/// Klein tikbaar label (kolomwaarde). [color] geeft een subtiele
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

/// Subtiele "+" om een nieuwe kaart in te voegen, met (indien niet de
/// laatste kaart) de rust tot de volgende kaart als tikbare pill, uitgelijnd
/// met de kaartinhoud. Zelf ook een dropzone: droppen hier herordent de
/// gesleepte kaart naar deze positie (in plaats van te groeperen).
class _InsertGap extends StatelessWidget {
  const _InsertGap({
    required this.targetIndex,
    required this.restAfter,
    required this.showRestPill,
    required this.onInsert,
    required this.onEditRest,
    required this.onDropReorder,
  });

  final int targetIndex;
  final int restAfter;
  final bool showRestPill;
  final VoidCallback onInsert;
  final ValueChanged<int> onEditRest;
  final ValueChanged<String> onDropReorder;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => onDropReorder(details.data),
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.4)
              : null,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: Colors.grey,
                visualDensity: VisualDensity.compact,
                tooltip: 'Oefening invoegen',
                onPressed: onInsert,
              ),
              const Spacer(),
              if (showRestPill)
                ActionChip(
                  avatar: const Icon(Icons.pause_circle_outline, size: 16),
                  label: Text(_formatSeconds(restAfter)),
                  onPressed: () async {
                    final value = await _showStepperDialog(
                      context,
                      title: 'Rust tot volgende kaart',
                      initial: restAfter,
                      step: 5,
                      min: 0,
                      max: 600,
                      format: _formatSeconds,
                    );
                    if (value != null) onEditRest(value);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// "+" om de allereerste kaart toe te voegen wanneer er nog geen enkele
/// oefening is (geen rust-pill of dropzone nodig: er is niets om tussen te
/// rusten of naartoe te herordenen).
class _EmptyInsert extends StatelessWidget {
  const _EmptyInsert({required this.onInsert});
  final VoidCallback onInsert;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 40),
          color: Colors.grey,
          tooltip: 'Oefening toevoegen',
          onPressed: onInsert,
        ),
      ),
    );
  }
}

/// Zwevende start-knop onderaan het scherm: pint aan de onderkant met een
/// vervagende achtergrond, zodat de oefeningen die er onder scrollen niet
/// hard afgesneden worden, en overlapt de kaartenlijst nooit (de `ListView`
/// erboven heeft daarvoor extra bottom-padding).
class _FloatingStartBar extends ConsumerWidget {
  const _FloatingStartBar({required this.tabata});
  final Tabata tabata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
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
            onPressed: tabata.items.isEmpty
                ? null
                : () => ref.read(tabataCommandsProvider).start(tabata),
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
                await commands.savePreset(title, tabata.items);
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
                    items: preset.items,
                  ).totalDurationMillis;
                  return Card(
                    child: ListTile(
                      title: Text(
                        preset.title.isEmpty ? 'Sessie' : preset.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${preset.items.length} kaart(en) · '
                        '${_formatSeconds(durationMillis ~/ 1000)} totaal',
                      ),
                      onTap: () async {
                        await commands.updateConfig(
                          tabata.copyWith(items: preset.items),
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
            error: (err, stack) =>
                Center(child: Text('Fout bij laden: $err')),
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

          // Titel en nummer van de huidige kaart
          if (progress.itemTitle.isNotEmpty || progress.totalItems > 1) ...[
            Text(
              progress.itemTitle.isNotEmpty ? progress.itemTitle : 'Tabata',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (progress.totalItems > 1)
              Text(
                'Kaart ${progress.itemIndex} van ${progress.totalItems}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (progress.groupRepeat != null)
              Text(
                'Herhaling ${progress.groupRepeat} van '
                '${progress.totalGroupRepeats}',
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
