import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_providers.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/display_text_controller.dart';
import 'package:hs_coaching_core/text/display_text.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_item_card.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/content_list.dart';
import 'package:hs_coaching_app/features/display/presentation/item_tile.dart';

class TextList extends ConsumerStatefulWidget {
  const TextList({super.key});

  @override
  ConsumerState<TextList> createState() => _TextListState();
}

class _TextListState extends ConsumerState<TextList> {
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

  Future<void> _showEditTextSheet(DisplayText textItem) async {
    final allTags = ref.read(textTagCountsProvider).keys.toList();
    _textController.text = textItem.text;

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Edit Display Text',
        initialTitle: textItem.title ?? '',
        initialTags: textItem.tags,
        allTags: allTags,
        isNewItem: false,
        showSecondaryAction: false,
        contentSpecificWidget: TextContentEditor(controller: _textController),
      ),
    );

    if (result == null || result.action == DialogAction.cancel) {
      _textController.clear();
      return;
    }

    if (result.action == DialogAction.save) {
      final isCurrent = ref.read(currentTextIdProvider).value == textItem.id;

      // Call de nieuwe controller
      await ref
          .read(textControllerProvider.notifier)
          .updateText(
            originalTextId: textItem.id,
            isCurrent: isCurrent,
            result: result,
            newTextContent: _textController.text.trim(),
          );
    }

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ContentList<DisplayText>(
      itemsProvider: allActiveTextsProvider,
      searchQueryProvider: searchQueryProvider,
      itemTypeSingular: 'text',
      itemTypePlural: 'texts',
      tagCountsProvider: textTagCountsProvider,
      selectedTagsProvider: selectedTagsProvider,
      tagMaintenanceProvider: displayTextRepositoryProvider,
      tagsOf: (text) => text.tags,
      filterPredicate: (text, query) {
        final titleMatch = text.title?.toLowerCase().contains(query) ?? false;
        final contentMatch = text.text.toLowerCase().contains(query);
        final tagMatch = text.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );

        return titleMatch || contentMatch || tagMatch;
      },
      itemBuilder: (context, textItem) {
        final currentTextId = ref.watch(currentTextIdProvider).value;
        final isCurrent = currentTextId == textItem.id;
        final controller = ref.read(textControllerProvider.notifier);

        return ContentItemCard(
          id: textItem.id,
          title: textItem.title ?? 'Untitled Text',
          isCurrent: isCurrent,
          // Korte en cleane aanroepen naar de controller
          onDismissed: () => controller.archiveText(textItem.id),
          onUndo: () => controller.unarchiveText(textItem.id),
          onTap: () => controller.toggleCurrent(textItem.id, isCurrent),
          child: ItemTile(
            title: textItem.title,
            subtitle: textItem.text,
            dateModified: textItem.timestamp,
            onPrimaryIconPressed: () => _showEditTextSheet(textItem),
          ),
        );
      },
    );
  }
}
