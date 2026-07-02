import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_providers.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_app/features/display/features/text/domain/display_text.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_item_card.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/content_list.dart';
import 'package:hs_coaching_app/features/display/presentation/item_tile.dart';

class TextList extends ConsumerWidget {
  const TextList({super.key});

  Future<void> _showEditTextSheet(
    BuildContext context,
    WidgetRef ref,
    DisplayText textItem,
  ) async {
    final allTags = ref.read(allTextTagsProvider).value ?? [];
    final textController = TextEditingController(text: textItem.text);

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
        contentSpecificWidget: TextContentEditor(controller: textController),
      ),
    );

    if (result == null || result.action == DialogAction.cancel) return;

    if (result.action == DialogAction.save) {
      final repo = ref.read(displayTextRepositoryProvider);
      final isCurrent = ref.read(currentTextIdProvider).value == textItem.id;
      await repo.updateTextByDuplicating(
        originalTextId: textItem.id,
        isCurrent: isCurrent,
        newTitle: result.title,
        newText: textController.text.trim(),
        newTags: result.tags,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentList<DisplayText>(
      itemsProvider: allActiveTextsProvider.call,
      searchQueryProvider: searchQueryProvider,
      itemTypeSingular: 'text',
      itemTypePlural: 'texts',
      allTagsProvider: allTextTagsProvider,
      selectedTagProvider: selectedTagProvider,
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
        return ContentItemCard(
          id: textItem.id,
          title: textItem.title ?? 'Untitled Text',
          isCurrent: isCurrent,
          onDismissed: () {
            ref.read(displayTextRepositoryProvider).archiveText(textItem.id);
          },
          onUndo: () {
            ref.read(displayTextRepositoryProvider).unarchiveText(textItem.id);
          },
          onTap: () {
            ref
                .read(displayTextRepositoryProvider)
                .setCurrentTextId(isCurrent ? null : textItem.id);
          },
          child: ItemTile(
            title: textItem.title,
            subtitle: textItem.text,
            dateModified: textItem.timestamp,
            onPrimaryIconPressed: () =>
                _showEditTextSheet(context, ref, textItem),
          ),
        );
      },
    );
  }
}
