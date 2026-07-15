import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_providers.dart';
import 'package:hs_coaching_app/features/display/features/image/domain/display_image.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/image_controller.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/widgets/image_content_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/content_item_card.dart';
import 'package:hs_coaching_app/features/display/presentation/content_list.dart';
import 'package:hs_coaching_app/features/display/presentation/item_tile.dart';

class ImageList extends ConsumerWidget {
  const ImageList({super.key});

  Future<void> _showEditImageSheet(
    BuildContext context,
    WidgetRef ref,
    DisplayImage imageItem,
  ) async {
    final allTags = ref.read(allImageTagsProvider).value ?? [];

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Edit Image',
        initialTitle: imageItem.title ?? '',
        initialDescription: imageItem.description ?? '',
        initialTags: imageItem.tags,
        allTags: allTags,
        isNewItem: false,
        showSecondaryAction: false,
        contentSpecificWidget: ImageContentEditor(
          initialImageUrl: imageItem.url,
        ),
      ),
    );

    if (result == null || result.action == DialogAction.cancel) return;

    if (result.action == DialogAction.save) {
      await ref
          .read(imageControllerProvider.notifier)
          .updateImage(imageId: imageItem.id, result: result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentList<DisplayImage>(
      itemsProvider: allActiveImagesProvider.call,
      searchQueryProvider: searchQueryProvider,
      itemTypeSingular: 'image',
      itemTypePlural: 'images',
      allTagsProvider: allImageTagsProvider,
      selectedTagProvider: selectedTagProvider,
      filterPredicate: (image, query) {
        final titleMatch = image.title?.toLowerCase().contains(query) ?? false;
        final descMatch =
            image.description?.toLowerCase().contains(query) ?? false;
        final tagMatch = image.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );
        return titleMatch || descMatch || tagMatch;
      },
      itemBuilder: (context, imageItem) {
        final currentImageId = ref.watch(currentImageIdProvider).value;
        final isCurrent = currentImageId == imageItem.id;
        final controller = ref.read(imageControllerProvider.notifier);

        return ContentItemCard(
          id: imageItem.id,
          title: imageItem.title ?? 'Untitled Image',
          isCurrent: isCurrent,
          onDismissed: () => controller.archiveImage(imageItem.id),
          onUndo: () => controller.unarchiveImage(imageItem.id),
          onTap: () => controller.toggleCurrent(imageItem.id, isCurrent),
          child: ItemTile(
            title: imageItem.title ?? '',
            imageUrl: imageItem.url,
            subtitle: imageItem.description,
            dateModified: imageItem.timestamp,
            onPrimaryIconPressed: () =>
                _showEditImageSheet(context, ref, imageItem),
          ),
        );
      },
    );
  }
}
