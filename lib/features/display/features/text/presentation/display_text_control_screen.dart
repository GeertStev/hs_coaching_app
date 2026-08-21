import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/display_text_controller.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/widgets/text_list.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_providers.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';

class TextControlScreen extends ConsumerStatefulWidget {
  const TextControlScreen({super.key});

  @override
  ConsumerState<TextControlScreen> createState() => _TextControlScreenState();
}

class _TextControlScreenState extends ConsumerState<TextControlScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _showAddTextSheet() async {
    // Zorg dat hij leeg is voor je een nieuwe toevoegt
    _textController.clear();

    final allTags = ref.read(allTextTagsProvider).value ?? [];

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Add Display Text',
        allTags: allTags,
        isNewItem: true,
        showSecondaryAction: true,
        contentSpecificWidget: TextContentEditor(controller: _textController),
      ),
    );

    if (result == null ||
        result.action == DialogAction.cancel ||
        _textController.text.trim().isEmpty) {
      return;
    }

    final setAsCurrent = result.action == DialogAction.display;

    await ref
        .read(textControllerProvider.notifier)
        .addText(
          result: result,
          textContent: _textController.text.trim(),
          setAsCurrent: setAsCurrent,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Luister naar foutmeldingen van de controller
    ref.listen<AsyncValue<void>>(textControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    return ContentControlScreen(
      body: const TextList(),
      addAction: (
        icon: Icons.add,
        tooltip: 'Add Text',
        onPressed: _showAddTextSheet,
      ),
      contentType: DisplayContentType.text,
    );
  }
}
