import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch.dart';
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
    String? selectedBackgroundUrl = sketch.backgroundUrl;
    final allTags = ref.read(allSketchTagsProvider).value ?? [];
    final allBackgrounds = ref.read(sketchBackgroundsProvider).value ?? [];

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
        contentSpecificWidget: SketchContentEditor(
          allBackgrounds: allBackgrounds,
          selectedUrl: selectedBackgroundUrl,
          onSelected: (url) => selectedBackgroundUrl = url,
        ),
      ),
    );

    if (result == null || result.action != DialogAction.save) return;

    await ref
        .read(sketchRepositoryProvider)
        .updateSketch(
          id: sketch.id,
          title: result.title,
          description: result.description,
          tags: result.tags,
          backgroundUrl: selectedBackgroundUrl,
        );
  }

  void _navigateToSketch(BuildContext context, String sketchId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProviderScope(
          overrides: [
            // We keep the scope to provide a fresh command history for this sketch.
            commandHistoryProvider.overrideWith(CommandHistoryNotifier.new),
          ],
          child: SketchScreen(sketchId: sketchId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentList<Sketch>(
      itemsProvider: sketchListStreamProvider.call,
      searchQueryProvider: searchQueryProvider,
      itemTypeSingular: 'sketch',
      itemTypePlural: 'sketches',
      allTagsProvider: allSketchTagsProvider,
      selectedTagProvider: selectedTagProvider,
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
        return ContentItemCard(
          id: sketch.id,
          title: sketch.title,
          isCurrent: isCurrent,
          onDismissed: () {
            ref.read(sketchRepositoryProvider).archiveSketch(sketch.id);
          },
          onUndo: () {
            ref.read(sketchRepositoryProvider).unarchiveSketch(sketch.id);
          },
          onTap: () => ref
              .read(sketchRepositoryProvider)
              .setCurrentSketchId(isCurrent ? null : sketch.id),
          child: ItemTile(
            title: sketch.title,
            subtitle: sketch.description,
            dateModified: sketch.lastModified,
            onPrimaryIconPressed: () =>
                _showEditSketchDialog(context, ref, sketch),
            secondaryIcon: Icons.draw_outlined,
            secondaryIconTooltip: 'Open Sketch',
            onSecondaryIconPressed: () => _navigateToSketch(context, sketch.id),
          ),
        );
      },
    );
  }
}
