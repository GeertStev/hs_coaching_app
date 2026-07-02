import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_screen.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/widgets/sketch_list.dart';

class SketchControlScreen extends ConsumerStatefulWidget {
  const SketchControlScreen({super.key});

  @override
  ConsumerState<SketchControlScreen> createState() =>
      _SketchControlScreenState();
}

class _SketchControlScreenState extends ConsumerState<SketchControlScreen> {
  Future<void> _createNewSketch() async {
    String? selectedBackgroundUrl;
    final allTags = ref.read(allSketchTagsProvider).value ?? [];
    final allBackgrounds = ref.read(sketchBackgroundsProvider).value ?? [];

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Create New Sketch',
        allTags: allTags,
        isNewItem: true,
        showSecondaryAction: true, // 'Add to List' is 'create off-screen'
        contentSpecificWidget: SketchContentEditor(
          allBackgrounds: allBackgrounds,
          selectedUrl: selectedBackgroundUrl,
          onSelected: (url) => selectedBackgroundUrl = url,
        ),
      ),
    );

    if (result == null || result.action == DialogAction.cancel) return;

    final repo = ref.read(sketchRepositoryProvider);
    final newSketchId = await repo.createSketch(
      title: result.title,
      description: result.description,
      tags: result.tags,
      backgroundUrl: selectedBackgroundUrl,
    );

    if (result.action == DialogAction.display) {
      await repo.setCurrentSketchId(newSketchId);
    }

    // Navigate to the new sketch screen if the user chose 'Display'
    if (result.action == DialogAction.display && context.mounted) {
      _navigateToSketch(context, newSketchId);
    }
  }

  void _navigateToSketch(BuildContext context, String sketchId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProviderScope(
          overrides: [
            // We no longer override currentSketchIdProvider here.
            // We keep the scope to provide a fresh command history for this sketch.
            commandHistoryProvider.overrideWith(CommandHistoryNotifier.new),
          ],
          child: SketchScreen(sketchId: sketchId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentControlScreen(
      contentList: const SketchList(),
      onAdd: _createNewSketch,
      addIcon: Icons.add,
      addTooltip: 'New Sketch',
      contentType: DisplayContentType.sketch,
    );
  }
}
