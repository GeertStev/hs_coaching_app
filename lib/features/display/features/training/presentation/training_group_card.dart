import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_core/training/training_validation.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/indented_guide.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_children_editor.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_dialogs.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_drag_drop.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_mutations.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_pill.dart';

/// "Set" en "Subset" zijn positionele UI-labels van hetzelfde
/// [TrainingGroup]-type (zie `training_node.dart`) — dit is het enige
/// verschil tussen v1's `TrainingSetCard`/`TrainingSubsetCard`, dus die
/// twee kaarttypes zijn hier samengevoegd tot één, geparametriseerd door
/// het pad. [path]'s lengte bepaalt het label en de visuele inspringing;
/// een groep op niveau 3+ is formule-toegestaan maar in de praktijk
/// onbereikbaar (zie `canInsert`'s hoogte-formule) — cosmetisch ook als
/// "Subset" gelabeld in dat geval, geen aparte derde naam nodig.
class TrainingGroupCard extends ConsumerWidget {
  const TrainingGroupCard({
    super.key,
    required this.group,
    required this.path,
    required this.onChanged,
    required this.onDelete,
  });

  final TrainingGroup group;
  final TrainingPath path;
  final ValueChanged<TrainingGroup> onChanged;
  final VoidCallback onDelete;

  String get _label => path.length <= 1 ? 'Set' : 'Subset';

  Future<void> _rename(BuildContext context) async {
    final title = await showTrainingTitleDialog(
      context,
      title: 'Rename $_label',
      initial: group.title ?? '',
    );
    if (title != null && title.isNotEmpty) {
      onChanged(group.copyWith(title: title));
    }
  }

  Future<void> _saveAsTemplate(BuildContext context, WidgetRef ref) async {
    final details = await showTrainingTemplateDetailsDialog(
      context,
      dialogTitle: 'Save as template',
      initialTitle: group.title ?? '',
      allTags: ref.read(trainingTemplateTagCountsProvider).keys.toList(),
    );
    if (details == null) return;
    await ref
        .read(trainingCommandsProvider)
        .saveTemplate(
          details.title,
          TrainingTemplateKind.group,
          group.toJson(),
          subtreeHeight(TrainingNode.group(group: group)),
          tags: details.tags,
        );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showTrainingDeleteConfirmDialog(
      context,
      itemLabel: group.title ?? _label,
    );
    if (confirmed == true) onDelete();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Changed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => ref.read(trainingCommandsProvider).undo(),
            ),
          ),
        );
      case TrainingMutationRejected(:final reason):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reason)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indentLevel = path.length - 1;
    final card = _buildCard(context, ref);

    final draggable = LongPressDraggable<TrainingDragPayload>(
      data: TrainingDragPayload(path),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 360, child: Opacity(opacity: 0.85, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );

    // Alleen kale/andere groepen zijn een geldig doel voor het
    // groepeer-gebaar (§6 van het ontwerpdocument) — een losse oefening op
    // een groep laten vallen is geen ondersteunde combinatie in
    // `groupWithTarget`; die valt gewoon terug op een gewone verplaatsing
    // via de laatste TrainingInsertGap binnenin deze kaart.
    final wrapped = TrainingGroupTarget(
      canAccept: (payload) => canGroupWithTarget(ref, payload.path, path),
      onAccept: (payload) => _handleMergeAccept(ref, context, payload),
      rejectionMessage: (_) =>
          'This $_label cannot hold this (it would exceed the maximum depth of 3).',
      child: draggable,
    );

    return IndentedGuide(level: indentLevel, child: wrapped);
  }

  Widget _buildCard(BuildContext context, WidgetRef ref) {
    return Card(
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
                  label: group.title?.isNotEmpty == true
                      ? group.title!
                      : _label,
                ),
                const SizedBox(width: 4),
                TrainingRepeatCountPill(
                  value: group.repeatCount,
                  onChanged: (v) => onChanged(group.copyWith(repeatCount: v)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _rename(context),
                    child: Text(
                      group.title?.isNotEmpty == true ? group.title! : _label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _rename(context);
                      case 'template':
                        _saveAsTemplate(context, ref);
                      case 'delete':
                        _delete(context);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(
                      value: 'template',
                      child: Text('Save as template'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            TrainingChildrenEditor(
              children: group.children,
              parentPath: path,
              onChanged: (updated) =>
                  onChanged(group.copyWith(children: updated)),
            ),
          ],
        ),
      ),
    );
  }
}
