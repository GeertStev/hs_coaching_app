import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_factories.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_dialogs.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_drag_drop.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_exercise_card.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_group_card.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_mutations.dart';

/// Een lege groep met exact één oefening, alleen om de "kan hier een nieuwe
/// groep bij" (`canInsert`) te bevragen zonder de echte `newTrainingGroup`-
/// factory (en diens `uuid`-generatie) aan te roepen op elke rebuild.
const _probeGroupNode = TrainingNode.group(
  group: TrainingGroup(
    id: '_probe',
    children: [
      TrainingNode.exercise(exercise: TrainingExercise(id: '_probe', title: '_probe')),
    ],
  ),
);

/// Gedeelde lijst-renderer voor een kinderlijst op willekeurige diepte:
/// gebruikt door zowel `_EditorTab` (root, `parentPath: []`) als elke
/// `TrainingGroupCard` (`parentPath: <eigen pad>`). Vervangt v1's drie
/// bijna-identieke implementaties (`_EditorTab`, `TrainingSetCard`,
/// `TrainingSubsetCard` hadden elk hun eigen `_reorder`/`_group`/`_addX`,
/// en `_EditorTab` dupliceerde `groupWithTarget`'s root-logica zelfs
/// inline) — nu is er precies één plek die weet hoe je een kinderlijst
/// tekent, herordent en groepeert, op elk niveau.
class TrainingChildrenEditor extends ConsumerWidget {
  const TrainingChildrenEditor({
    super.key,
    required this.children,
    required this.parentPath,
    required this.onChanged,
  });

  final List<TrainingNode> children;
  final TrainingPath parentPath;
  final ValueChanged<List<TrainingNode>> onChanged;

  void _updateChild(int index, TrainingNode node) {
    final copy = List<TrainingNode>.of(children);
    copy[index] = node;
    onChanged(copy);
  }

  /// In tegenstelling tot [_updateChild]/[_addExercise]/etc. loopt dit niet
  /// via [onChanged] (dat kent alleen de lokale `children`-lijst, niet de
  /// rest van de boom): verwijderen moet mogelijk ook de eigen ouder-(Sub)Set
  /// leegmaken en dus zichzelf cascaderend meeverwijderen (zie
  /// `training_tree.dart`'s `removeAt`) — dat kan alleen met het volledige
  /// pad tegen de actuele boom, dus dispatcht dit rechtstreeks via [ref],
  /// net als de sleep-gedreven mutaties in `training_mutations.dart`.
  void _removeChild(WidgetRef ref, int index) {
    final path = [...parentPath, index];
    final tree = ref.read(trainingNotifierProvider).requireValue;
    ref.read(trainingCommandsProvider).save(removeAt(tree, path));
  }

  void _addExercise() {
    onChanged([
      ...children,
      TrainingNode.exercise(exercise: newTrainingExercise()),
    ]);
  }

  void _addGroup() {
    onChanged([...children, TrainingNode.group(group: newTrainingGroup())]);
  }

  Future<void> _openTemplate(BuildContext context, WidgetRef ref) async {
    final templates = ref.read(trainingTemplatesProvider).value ?? const [];
    final eligible = templates
        .where((t) => parentPath.length + t.height <= 3)
        .toList();
    final template = await showTrainingTemplatePicker(
      context,
      title: 'Template openen',
      templates: eligible,
    );
    if (template == null) return;
    onChanged([...children, template.toNode()]);
  }

  bool _isOwnChild(TrainingPath path) {
    if (path.length != parentPath.length + 1) return false;
    for (var i = 0; i < parentPath.length; i++) {
      if (path[i] != parentPath[i]) return false;
    }
    return true;
  }

  Future<void> _handleGapAccept(
    WidgetRef ref,
    BuildContext context,
    TrainingDragPayload payload,
    int toIndex,
  ) async {
    final result = await applyTrainingMove(
      ref,
      from: payload.path,
      toParent: parentPath,
      toIndex: toIndex,
    );
    if (!context.mounted) return;
    switch (result) {
      case TrainingMutationApplied():
        _showUndoSnackBar(context, ref);
      case TrainingMutationRejected(:final reason):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reason)));
    }
  }

  void _showUndoSnackBar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gewijzigd'),
        action: SnackBarAction(
          label: 'Ongedaan maken',
          onPressed: () => ref.read(trainingCommandsProvider).undo(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(trainingNotifierProvider).requireValue;
    final canAddGroup = canInsert(_probeGroupNode, parentPath, tree);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainingInsertGap(
          canAccept: (payload) => canMoveInto(ref, payload.path, parentPath),
          onAccept: (payload) => _handleGapAccept(ref, context, payload, 0),
        ),
        for (var i = 0; i < children.length; i++) ...[
          _buildChild(context, ref, i),
          TrainingInsertGap(
            canAccept: (payload) => canMoveInto(ref, payload.path, parentPath),
            onAccept: (payload) {
              final fromIndex = _isOwnChild(payload.path)
                  ? payload.path.last
                  : null;
              final toIndex = fromIndex != null && fromIndex < i ? i : i + 1;
              _handleGapAccept(ref, context, payload, toIndex);
            },
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Oefening'),
              ),
              if (canAddGroup)
                TextButton.icon(
                  onPressed: _addGroup,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Set'),
                ),
              TextButton.icon(
                onPressed: () => _openTemplate(context, ref),
                icon: const Icon(Icons.folder_open),
                label: const Text('Template'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChild(BuildContext context, WidgetRef ref, int index) {
    final node = children[index];
    final path = [...parentPath, index];

    return switch (node) {
      TrainingNodeExercise(:final exercise) => TrainingExerciseCard(
        exercise: exercise,
        path: path,
        onChanged: (updated) =>
            _updateChild(index, TrainingNode.exercise(exercise: updated)),
        onDelete: () => _removeChild(ref, index),
      ),
      TrainingNodeGroup(:final group) => TrainingGroupCard(
        group: group,
        path: path,
        onChanged: (updated) =>
            _updateChild(index, TrainingNode.group(group: updated)),
        onDelete: () => _removeChild(ref, index),
      ),
    };
  }
}
