import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/widgets/text_list.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_providers.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';

class TextControlScreen extends ConsumerWidget {
  const TextControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showAddTextSheet() async {
      final allTags = ref.read(allTextTagsProvider).value ?? [];
      final textController = TextEditingController();

      final result = await showModalBottomSheet<ContentEditDialogResult>(
        context: context,
        isScrollControlled: true,
        builder: (context) => ContentEditSheet(
          dialogTitle: 'Add Display Text',
          allTags: allTags,
          isNewItem: true,
          showSecondaryAction: true,
          contentSpecificWidget: TextContentEditor(controller: textController),
        ),
      );

      if (result == null ||
          result.action == DialogAction.cancel ||
          textController.text.trim().isEmpty) {
        return;
      }

      final setAsCurrent = result.action == DialogAction.display;

      await ref
          .read(displayTextRepositoryProvider)
          .addText(
            result.title,
            textController.text.trim(),
            result.tags,
            setAsCurrent: setAsCurrent,
          );
    }

    return ContentControlScreen(
      contentList: const TextList(),
      onAdd: showAddTextSheet,
      addIcon: Icons.add,
      addTooltip: 'Add Text',
      contentType: DisplayContentType.text,
    );
  }
}
