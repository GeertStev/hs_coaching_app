import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
//import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_service_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_ui_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/display_sketch_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
//import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_screen.dart';
import 'package:hs_coaching_app/features/display/presentation/content_item_card.dart';
import 'package:hs_coaching_app/features/display/presentation/item_tile.dart';
import 'package:hs_coaching_app/features/display/presentation/content_list.dart';

class SketchList extends ConsumerWidget {
  const SketchList({super.key});

  Future<void> _showEditSketchDialog(
    BuildContext context,
    WidgetRef ref,
    Sketch sketch,
  ) async {
    final allTags = ref.read(sketchTagCountsProvider).keys.toList();
    /*String? selectedBackgroundUrl = sketch.backgroundUrl;
    final allBackgrounds = ref.read(sketchBackgroundsProvider).value ?? [];*/

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Edit Sketch',
        initialTitle: sketch.title,
        initialDescription: sketch.description ?? '',
        initialTags: sketch.tags,
        allTags: allTags,
        isNewItem: false,
        showSecondaryAction: false,
        /*contentSpecificWidget: SketchContentEditor(
          allBackgrounds: allBackgrounds,
          selectedUrl: selectedBackgroundUrl,
          onSelected: (url) => selectedBackgroundUrl = url,
        ),*/
      ),
    );

    if (result == null || result.action != DialogAction.save) return;

    // Call de nieuwe controller
    await ref
        .read(sketchControllerProvider.notifier)
        .updateSketch(
          sketchId: sketch.id,
          result: result,
          backgroundUrl: sketch.backgroundUrl,
        );
  }

  void _navigateToSketch(BuildContext context, WidgetRef ref, String sketchId) {
    ref.read(sketchRepositoryProvider).updateSketchTimestamp(sketchId);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SketchScreen(sketchId: sketchId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentList<Sketch>(
      itemsProvider: sketchListStreamProvider,
      searchQueryProvider: searchQueryProvider,
      itemTypeSingular: 'sketch',
      itemTypePlural: 'sketches',
      tagCountsProvider: sketchTagCountsProvider,
      selectedTagsProvider: selectedTagsProvider,
      tagMaintenanceProvider: sketchRepositoryProvider,
      tagsOf: (sketch) => sketch.tags,
      emptyStateMessage: 'No sketches yet. Tap + to create one!',
      filterPredicate: (sketch, query) {
        final titleMatch = sketch.title.toLowerCase().contains(query);
        final descMatch =
            sketch.description?.toLowerCase().contains(query) ?? false;
        final tagMatch = sketch.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );
        return titleMatch || descMatch || tagMatch;
      },
      itemBuilder: (context, sketch) {
        final currentSketchId = ref.watch(currentSketchIdDocProvider).value;
        final isCurrent = currentSketchId == sketch.id;
        final controller = ref.read(sketchControllerProvider.notifier);

        return ContentItemCard(
          id: sketch.id,
          title: sketch.title,
          isCurrent: isCurrent,
          // De cleane controller calls:
          onDismissed: () => controller.archiveSketch(sketch.id),
          onUndo: () => controller.unarchiveSketch(sketch.id),
          onTap: () => controller.toggleCurrent(sketch.id, isCurrent),
          child: ItemTile(
            title: sketch.title,
            subtitle: sketch.description,
            dateModified: sketch.lastModified,
            onPrimaryIconPressed: () =>
                _showEditSketchDialog(context, ref, sketch),
            secondaryIcon: Icons.draw_outlined,
            secondaryIconTooltip: 'Open Sketch',
            onSecondaryIconPressed: () =>
                _navigateToSketch(context, ref, sketch.id),
          ),
        );
      },
    );
  }
}
