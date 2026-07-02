import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/timer/data/timer_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/widgets/timer_set_list.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/widgets/timer_set_content_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';

class TimerControlScreen extends ConsumerWidget {
  const TimerControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showAddTimerSheet() async {
      int restBetween = 30;
      List<ExerciseInSet> exercises = [];
      final allTags = ref.read(allTimerSetTagsProvider).value ?? [];

      final result = await showModalBottomSheet<ContentEditDialogResult>(
        context: context,
        isScrollControlled: true,
        builder: (context) => ContentEditSheet(
          dialogTitle: 'Add Timer Set',
          allTags: allTags,
          isNewItem: true,
          showSecondaryAction: false, // 'Add to List' is not used here
          contentSpecificWidget: TimerSetContentEditor(
            onChanged: (newRest, newExercises) {
              restBetween = newRest;
              exercises = newExercises;
            },
          ),
        ),
      );

      final ownerId = ref.read(appUserProvider).value?.uid;
      if (result == null ||
          result.action == DialogAction.cancel ||
          ownerId == null) {
        return; // User cancelled or is not logged in
      }

      final newSet = TimerSet(
        title: result.title,
        description: result.description,
        restBetweenExercisesSeconds: restBetween,
        exercises: exercises,
        ownerId: ownerId,
        tags: result.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(timerRepositoryProvider).addTimerSet(newSet);
    }

    return ContentControlScreen(
      contentList: const TimerSetList(),
      onAdd: showAddTimerSheet,
      addIcon: Icons.add,
      addTooltip: 'Add Timer Set',
      contentType: DisplayContentType.timer,
    );
  }
}
