import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/timer/data/timer_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/timer_controller.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/widgets/timer_set_content_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_item_card.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/item_tile.dart';

class TimerSetTile extends ConsumerWidget {
  const TimerSetTile({super.key, required this.timerSet});

  final TimerSet timerSet;

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  int _calculateTotalDuration(TimerSet set) {
    if (set.exercises.isEmpty) return 0;

    int total = 0;
    for (final exercise in set.exercises) {
      total += exercise.rounds * (exercise.workSeconds + exercise.restSeconds);
    }
    // Add rest between exercises
    total += (set.exercises.length - 1) * set.restBetweenExercisesSeconds;
    return total;
  }

  Future<void> _editSet(BuildContext context, WidgetRef ref) async {
    int restBetween = timerSet.restBetweenExercisesSeconds;
    List<ExerciseInSet> exercises = List.from(timerSet.exercises);
    final allTags = ref.read(allTimerSetTagsProvider).value ?? [];

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Edit Timer Set',
        initialTitle: timerSet.title,
        initialDescription: timerSet.description,
        initialTags: timerSet.tags,
        allTags: allTags,
        isNewItem: false,
        showSecondaryAction: false,
        contentSpecificWidget: TimerSetContentEditor(
          initialSet: timerSet,
          onChanged: (newRest, newExercises) {
            restBetween = newRest;
            exercises = newExercises;
          },
        ),
      ),
    );

    if (result == null || result.action == DialogAction.cancel) {
      return;
    }

    if (result.action == DialogAction.save) {
      final updatedSet = timerSet.copyWith(
        title: result.title,
        description: result.description,
        restBetweenExercisesSeconds: restBetween,
        exercises: exercises,
        tags: result.tags,
      );

      ref.read(timerControllerProvider.notifier).updateTimerSet(updatedSet);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDuration = _calculateTotalDuration(timerSet);
    final subtitle =
        '${timerSet.exercises.length} exercises - ${_formatDuration(totalDuration)}';

    final controller = ref.read(timerControllerProvider.notifier);

    return ContentItemCard(
      id: timerSet.id!,
      title: timerSet.title,
      isCurrent: false, // TODO: Implement "is casting" logic
      onTap: () {
        // TODO: Navigate to the "Run" tab and select this set
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped on ${timerSet.title}')));
      },
      onDismissed: () => controller.deleteTimerSet(timerSet.id!),
      onUndo: () => controller.restoreTimerSet(timerSet),
      child: ItemTile(
        title: timerSet.title,
        subtitle: subtitle,
        dateModified: timerSet.updatedAt,
        onPrimaryIconPressed: () => _editSet(context, ref),
      ),
    );
  }
}
