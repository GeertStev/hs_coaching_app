import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/data/timer_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/presentation/timer_controller.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/presentation/widgets/timer_set_list.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/presentation/widgets/timer_set_content_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';

class TimerControlScreen extends ConsumerWidget {
  const TimerControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Luister naar de controller voor eventuele fouten tijdens mutaties
    ref.listen<AsyncValue<void>>(timerControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij het opslaan: ${state.error}')),
        );
      }
    });

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
          showSecondaryAction: false,
          contentSpecificWidget: TimerSetContentEditor(
            onChanged: (newRest, newExercises) {
              restBetween = newRest;
              exercises = newExercises;
            },
          ),
        ),
      );

      if (result == null || result.action == DialogAction.cancel) {
        return; // User cancelled
      }

      // Controller regelt het toevoegen, incl. ophalen van de huidige user
      ref
          .read(timerControllerProvider.notifier)
          .addTimerSet(
            title: result.title,
            description: result.description,
            restBetweenExercisesSeconds: restBetween,
            exercises: exercises,
            tags: result.tags,
          );
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
