import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_exercise_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:hs_coaching_core/training/training_validation.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_factories.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/indented_guide.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_dialogs.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_drag_drop.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_mutations.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_pill.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_wheel_picker.dart';

const _kStrokeValues = ['AB', 'A', 'B', 'D'];
const _kZoneValues = ['Bov', 'Ond', 'HaBo', 'HaOn'];

const _kRepsMin = 1, _kRepsMax = 50, _kRepsStep = 1;
const _kDistanceMin = 0, _kDistanceMax = 2000, _kDistanceStep = 25;
const _kIntensityMin = 0, _kIntensityMax = 100, _kIntensityStep = 5;
const _kSecondsMin = 0, _kSecondsMax = 900, _kSecondsStep = 5;
const _kDeltaMin = -60, _kDeltaMax = 60, _kDeltaStep = 5;

String _formatSeconds(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}

String _formatDelta(int seconds) {
  if (seconds == 0) return '0s';
  return seconds > 0 ? '+${seconds}s' : '${seconds}s';
}

/// Kaart voor een losse [TrainingExercise] — het blad van de boom, op elk
/// niveau bruikbaar. [path] is nodig als sleeplast-identiteit; de
/// inspringing wordt afgeleid van `path.length - 1`, zelfde formule als
/// [TrainingGroupCard]. Groeperen (oefening-op-oefening, zie
/// `groupWithTarget` in `training_tree.dart`) is niet langer per-niveau
/// hardgecodeerd doorgegeven door de aanroeper (v1's `onGroup`) — deze
/// kaart wikkelt zichzelf altijd in een [TrainingGroupTarget] en laat
/// `canGroupWithTarget` bepalen of een drop hier geldig is.
class TrainingExerciseCard extends ConsumerWidget {
  const TrainingExerciseCard({
    super.key,
    required this.exercise,
    required this.path,
    required this.onChanged,
    required this.onDelete,
  });

  final TrainingExercise exercise;
  final TrainingPath path;
  final ValueChanged<TrainingExercise> onChanged;
  final VoidCallback onDelete;

  Future<void> _rename(BuildContext context) async {
    final title = await showTrainingTitleDialog(
      context,
      title: 'Rename exercise',
      initial: exercise.title,
    );
    if (title != null && title.isNotEmpty) {
      onChanged(exercise.copyWith(title: title));
    }
  }

  Future<void> _saveAsTemplate(BuildContext context, WidgetRef ref) async {
    final details = await showTrainingTemplateDetailsDialog(
      context,
      dialogTitle: 'Save as template',
      initialTitle: exercise.title,
      allTags: ref.read(trainingTemplateTagCountsProvider).keys.toList(),
    );
    if (details == null) return;
    await ref
        .read(trainingCommandsProvider)
        .saveTemplate(
          details.title,
          TrainingTemplateKind.exercise,
          exercise.toJson(),
          subtreeHeight(TrainingNode.exercise(exercise: exercise)),
          tags: details.tags,
        );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showTrainingDeleteConfirmDialog(
      context,
      itemLabel: exercise.title,
    );
    if (confirmed == true) onDelete();
  }

  void _addGroup() {
    if (exercise.groups.length >= kMaxTrainingExerciseGroups) return;
    onChanged(
      exercise.copyWith(
        groups: [...exercise.groups, newTrainingExerciseGroup()],
      ),
    );
  }

  void _removeGroup(int index) {
    final groups = List<TrainingExerciseGroup>.of(exercise.groups)
      ..removeAt(index);
    onChanged(exercise.copyWith(groups: groups));
  }

  void _updateGroup(int index, TrainingExerciseGroup group) {
    final groups = List<TrainingExerciseGroup>.of(exercise.groups);
    groups[index] = group;
    onChanged(exercise.copyWith(groups: groups));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TrainingDragHandle(
                  payload: TrainingDragPayload(path),
                  label: exercise.title,
                ),
                const SizedBox(width: 4),
                TrainingRepeatCountPill(
                  value: exercise.repeatCount,
                  onChanged: (v) =>
                      onChanged(exercise.copyWith(repeatCount: v)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _rename(context),
                    child: Text(
                      exercise.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'addGroup':
                        _addGroup();
                      case 'rename':
                        _rename(context);
                      case 'template':
                        _saveAsTemplate(context, ref);
                      case 'delete':
                        _delete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'addGroup',
                      enabled:
                          exercise.groups.length < kMaxTrainingExerciseGroups,
                      child: const Text('Add group'),
                    ),
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem(
                      value: 'template',
                      child: Text('Save as template'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            for (var i = 0; i < exercise.groups.length; i++)
              _GroupPanel(
                group: exercise.groups[i],
                showName: exercise.groups.length > 1,
                onChanged: (group) => _updateGroup(i, group),
                onRemove: exercise.groups.length > 1
                    ? () => _removeGroup(i)
                    : null,
              ),
          ],
        ),
      ),
    );

    final draggable = LongPressDraggable<TrainingDragPayload>(
      data: TrainingDragPayload(path),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 280, child: Opacity(opacity: 0.85, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );

    final wrapped = TrainingGroupTarget(
      canAccept: (payload) => canGroupWithTarget(ref, payload.path, path),
      onAccept: (payload) => _handleMergeAccept(ref, context, payload),
      rejectionMessage: (_) =>
          'This exercise cannot be grouped with this (it would exceed the '
          'maximum depth of 3).',
      child: draggable,
    );

    return IndentedGuide(level: path.length - 1, child: wrapped);
  }

  Future<void> _handleMergeAccept(
    WidgetRef ref,
    BuildContext context,
    TrainingDragPayload payload,
  ) async {
    final result = await applyTrainingMerge(
      ref,
      source: payload.path,
      target: path,
    );
    if (!context.mounted) return;
    switch (result) {
      case TrainingMutationApplied():
        showTrainingUndoSnackBar(
          context,
          onUndo: () => ref.read(trainingCommandsProvider).undo(),
        );
      case TrainingMutationRejected(:final reason):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reason)));
    }
  }
}

/// Eén "timing rij" (werk/rust/delta + parameter-rijen) binnen een
/// oefening. [showName] is alleen `true` zodra de oefening meer dan één
/// groep heeft — met precies één groep is een naam overbodige ruis.
class _GroupPanel extends StatelessWidget {
  const _GroupPanel({
    required this.group,
    required this.showName,
    required this.onChanged,
    required this.onRemove,
  });

  final TrainingExerciseGroup group;
  final bool showName;
  final ValueChanged<TrainingExerciseGroup> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: group.name,
                      decoration: const InputDecoration(
                        labelText: 'Group name',
                        isDense: true,
                      ),
                      onChanged: (value) =>
                          onChanged(group.copyWith(name: value)),
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onRemove,
                      tooltip: 'Remove group',
                    ),
                ],
              ),
            ),
          for (var i = 0; i < group.parameterRows.length; i++) ...[
            _ParameterRowPills(
              row: group.parameterRows[i],
              color: scheme.primary,
              onChanged: (row) {
                final rows = List.of(group.parameterRows);
                rows[i] = row;
                onChanged(group.copyWith(parameterRows: rows));
              },
              onRemove: group.parameterRows.length > 1
                  ? () {
                      final rows = List.of(group.parameterRows)..removeAt(i);
                      onChanged(group.copyWith(parameterRows: rows));
                    }
                  : null,
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TrainingValuePill(
                label: 'Work',
                title: 'Work time',
                parseInput: numericInputParser(
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                  parseValue: parseSecondsInput,
                ),
                inputHint: 'e.g. 45 or 1:30',
                items: numericWheelItems(
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                  format: _formatSeconds,
                ),
                initialIndex: numericWheelIndex(
                  value: group.workSeconds,
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                ),
                color: scheme.secondary,
                onChanged: (index) => onChanged(
                  group.copyWith(
                    workSeconds: _kSecondsMin + index * _kSecondsStep,
                  ),
                ),
              ),
              TrainingValuePill(
                label: 'Rest',
                title: 'Rest time',
                parseInput: numericInputParser(
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                  parseValue: parseSecondsInput,
                ),
                inputHint: 'e.g. 45 or 1:30',
                items: numericWheelItems(
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                  format: _formatSeconds,
                ),
                initialIndex: numericWheelIndex(
                  value: group.restSeconds,
                  min: _kSecondsMin,
                  max: _kSecondsMax,
                  step: _kSecondsStep,
                ),
                color: scheme.secondary,
                onChanged: (index) => onChanged(
                  group.copyWith(
                    restSeconds: _kSecondsMin + index * _kSecondsStep,
                  ),
                ),
              ),
              TrainingValuePill(
                label: 'Delta',
                title: 'Delta per round',
                parseInput: numericInputParser(
                  min: _kDeltaMin,
                  max: _kDeltaMax,
                  step: _kDeltaStep,
                ),
                inputHint: 'seconds, e.g. -5 or 10',
                items: numericWheelItems(
                  min: _kDeltaMin,
                  max: _kDeltaMax,
                  step: _kDeltaStep,
                  format: _formatDelta,
                ),
                initialIndex: numericWheelIndex(
                  value: group.deltaSeconds,
                  min: _kDeltaMin,
                  max: _kDeltaMax,
                  step: _kDeltaStep,
                ),
                color: scheme.secondary,
                onChanged: (index) => onChanged(
                  group.copyWith(
                    deltaSeconds: _kDeltaMin + index * _kDeltaStep,
                  ),
                ),
              ),
              _AddParameterButton(
                onPressed: () => onChanged(
                  group.copyWith(
                    parameterRows: [
                      ...group.parameterRows,
                      newTrainingParameterRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Eén parameter-rij (reps/afstand/slag/intensiteit/zone) als vaste bundel
/// van 5 tikbare pills — elk veld onafhankelijk instelbaar, "–" wanneer niet
/// ingesteld. Lang indrukken op om het even welke van de 5 pills verwijdert
/// de hele rij: de velden horen bij elkaar (zie
/// `hs_coaching_core`'s `TrainingParameterRow`), niet individueel toe te
/// voegen of te verwijderen. [onRemove] is `null` wanneer dit de laatste
/// rij van de oefening is — een oefening heeft altijd minstens 1 rij.
class _ParameterRowPills extends StatelessWidget {
  const _ParameterRowPills({
    required this.row,
    required this.color,
    required this.onChanged,
    required this.onRemove,
  });

  final TrainingParameterRow row;
  final Color color;
  final ValueChanged<TrainingParameterRow> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TrainingValuePill(
          title: 'Reps',
          parseInput: numericInputParser(
            min: _kRepsMin,
            max: _kRepsMax,
            step: _kRepsStep,
            nullable: true,
          ),
          inputHint: 'e.g. 10',
          items: [
            '–',
            ...numericWheelItems(
              min: _kRepsMin,
              max: _kRepsMax,
              step: _kRepsStep,
              format: (v) => '${v}x',
            ),
          ],
          initialIndex: row.reps == null
              ? 0
              : 1 +
                    numericWheelIndex(
                      value: row.reps!,
                      min: _kRepsMin,
                      max: _kRepsMax,
                      step: _kRepsStep,
                    ),
          color: color,
          onChanged: (index) => onChanged(
            row.copyWith(
              reps: index == 0 ? null : _kRepsMin + (index - 1) * _kRepsStep,
            ),
          ),
          onLongPress: onRemove,
        ),
        TrainingValuePill(
          title: 'Distance',
          parseInput: numericInputParser(
            min: _kDistanceMin,
            max: _kDistanceMax,
            step: _kDistanceStep,
            nullable: true,
          ),
          inputHint: 'meters, e.g. 400',
          items: [
            '–',
            ...numericWheelItems(
              min: _kDistanceMin,
              max: _kDistanceMax,
              step: _kDistanceStep,
              format: (v) => '${v}m',
            ),
          ],
          initialIndex: row.distance == null
              ? 0
              : 1 +
                    numericWheelIndex(
                      value: row.distance!,
                      min: _kDistanceMin,
                      max: _kDistanceMax,
                      step: _kDistanceStep,
                    ),
          color: color,
          onChanged: (index) => onChanged(
            row.copyWith(
              distance: index == 0
                  ? null
                  : _kDistanceMin + (index - 1) * _kDistanceStep,
            ),
          ),
          onLongPress: onRemove,
        ),
        TrainingValuePill(
          title: 'Stroke',
          inputHint: _kStrokeValues.join(' / '),
          items: ['–', ..._kStrokeValues],
          initialIndex: () {
            final idx = _kStrokeValues.indexOf(row.stroke ?? '');
            return row.stroke == null || idx < 0 ? 0 : idx + 1;
          }(),
          color: color,
          onChanged: (index) => onChanged(
            row.copyWith(stroke: index == 0 ? null : _kStrokeValues[index - 1]),
          ),
          onLongPress: onRemove,
        ),
        TrainingValuePill(
          title: 'Intensity',
          parseInput: numericInputParser(
            min: _kIntensityMin,
            max: _kIntensityMax,
            step: _kIntensityStep,
            nullable: true,
          ),
          inputHint: 'percent, e.g. 80',
          items: [
            '–',
            ...numericWheelItems(
              min: _kIntensityMin,
              max: _kIntensityMax,
              step: _kIntensityStep,
              format: (v) => '$v%',
            ),
          ],
          initialIndex: row.intensity == null
              ? 0
              : 1 +
                    numericWheelIndex(
                      value: row.intensity!,
                      min: _kIntensityMin,
                      max: _kIntensityMax,
                      step: _kIntensityStep,
                    ),
          color: color,
          onChanged: (index) => onChanged(
            row.copyWith(
              intensity: index == 0
                  ? null
                  : _kIntensityMin + (index - 1) * _kIntensityStep,
            ),
          ),
          onLongPress: onRemove,
        ),
        TrainingValuePill(
          title: 'Zone',
          inputHint: _kZoneValues.join(' / '),
          items: ['–', ..._kZoneValues],
          initialIndex: () {
            final idx = _kZoneValues.indexOf(row.zone ?? '');
            return row.zone == null || idx < 0 ? 0 : idx + 1;
          }(),
          color: color,
          onChanged: (index) => onChanged(
            row.copyWith(zone: index == 0 ? null : _kZoneValues[index - 1]),
          ),
          onLongPress: onRemove,
        ),
      ],
    );
  }
}

/// Ronde "+"-knop om een nieuwe parameter-rij toe te voegen (alle 5 velden
/// leeg) — geen keuzemenu meer, elke rij heeft altijd dezelfde vaste 5
/// velden, zie [_ParameterRowPills].
class _AddParameterButton extends StatelessWidget {
  const _AddParameterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
