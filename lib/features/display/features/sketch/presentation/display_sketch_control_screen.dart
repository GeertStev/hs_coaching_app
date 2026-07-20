import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
//import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_service_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/display_sketch_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
//import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog_parts.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
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
    /*String? selectedBackgroundUrl;
    final allBackgrounds = ref.read(sketchBackgroundsProvider).value ?? [];*/
    final allTags = ref.read(allSketchTagsProvider).value ?? [];

    final result = await showModalBottomSheet<ContentEditDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContentEditSheet(
        dialogTitle: 'Create New Sketch',
        allTags: allTags,
        isNewItem: true,
        showSecondaryAction: true, // 'Add to List' is 'create off-screen'
        /*contentSpecificWidget: SketchContentEditor(
          allBackgrounds: allBackgrounds,
          selectedUrl: selectedBackgroundUrl,
          onSelected: (url) => selectedBackgroundUrl = url,
        ),*/
      ),
    );

    if (result == null || result.action == DialogAction.cancel) return;

    final isDisplayAction = result.action == DialogAction.display;

    // Call de nieuwe controller
    final newSketchId = await ref
        .read(sketchControllerProvider.notifier)
        .createSketch(
          result: result,
          backgroundUrl: null,
          setAsCurrent: isDisplayAction,
        );

    // Controleer of de widget nog in de tree zit na de async acties
    if (!mounted) return;

    // Navigeer enkel als de sketch correct is aangemaakt en de actie 'display' was
    if (newSketchId != null && isDisplayAction) {
      _navigateToSketch(newSketchId); // Geen context meer nodig als parameter!
    }
  }

  void _navigateToSketch(String sketchId) {
    if (!mounted) return;

    ref.read(sketchRepositoryProvider).updateSketchTimestamp(sketchId);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SketchScreen(sketchId: sketchId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(sketchControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });
    return ContentControlScreen(
      contentList: const SketchList(),
      onAdd: _createNewSketch,
      addIcon: Icons.add,
      addTooltip: 'New Sketch',
      contentType: DisplayContentType.sketch,
    );
  }
}
