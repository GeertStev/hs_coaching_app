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
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_wheel_picker.dart';

const _kRepeatCountMin = 1, _kRepeatCountMax = 20, _kRepeatCountStep = 1;

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
      title: '$_label hernoemen',
      initial: group.title ?? '',
    );
    if (title != null && title.isNotEmpty) {
      onChanged(group.copyWith(title: title));
    }
  }

  Future<void> _editRepeatCount(BuildContext context) async {
    final items = numericWheelItems(
      min: _kRepeatCountMin,
      max: _kRepeatCountMax,
      step: _kRepeatCountStep,
      format: (v) => '${v}x',
    );
    final index = await showTrainingWheelPicker(
      context,
      title: 'Herhalingen',
      items: items,
      initialIndex: numericWheelIndex(
        value: group.repeatCount,
        min: _kRepeatCountMin,
        max: _kRepeatCountMax,
        step: _kRepeatCountStep,
      ),
    );
    if (index != null) {
      onChanged(group.copyWith(repeatCount: _kRepeatCountMin + index));
    }
  }

  Future<void> _saveAsTemplate(BuildContext context, WidgetRef ref) async {
    final title = await showTrainingTitleDialog(
      context,
      title: 'Bewaar als template',
      initial: group.title ?? '',
    );
    if (title == null || title.isEmpty) return;
    await ref
        .read(trainingCommandsProvider)
        .saveTemplate(
          title,
          TrainingTemplateKind.group,
          group.toJson(),
          subtreeHeight(TrainingNode.group(group: group)),
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
            content: const Text('Gewijzigd'),
            action: SnackBarAction(
              label: 'Ongedaan maken',
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
          'Deze $_label kan dit niet bevatten (max-diepte-3 zou overschreden worden).',
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
                const TrainingDragHandle(),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _editRepeatCount(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text('${group.repeatCount}x'),
                    ],
                  ),
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
                    PopupMenuItem(value: 'rename', child: Text('Hernoemen')),
                    PopupMenuItem(
                      value: 'template',
                      child: Text('Bewaren als template'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Verwijderen')),
                  ],
                ),
              ],
            ),
            TrainingChildrenEditor(
              children: group.children,
              parentPath: path,
              onChanged: (updated) => onChanged(group.copyWith(children: updated)),
            ),
          ],
        ),
      ),
    );
  }
}

