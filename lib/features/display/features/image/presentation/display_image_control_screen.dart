import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_providers.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_repository.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/widgets/image_content_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_sheet.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/widgets/image_list.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

class ImageControlScreen extends ConsumerWidget {
  const ImageControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showAddImageSheet() async {
      File? imageFile;
      final allTags = ref.read(allImageTagsProvider).value ?? [];

      final result = await showModalBottomSheet<ContentEditDialogResult>(
        context: context,
        isScrollControlled: true,
        builder: (context) => ContentEditSheet(
          dialogTitle: 'Add Image',
          allTags: allTags,
          isNewItem: true,
          showSecondaryAction: true,
          contentSpecificWidget: ImageContentEditor(
            onImageChanged: (file) => imageFile = file,
          ),
        ),
      );

      if (result == null ||
          result.action == DialogAction.cancel ||
          imageFile == null) {
        return;
      }

      final setAsCurrent = result.action == DialogAction.display;

      await ref
          .read(displayImageRepositoryProvider)
          .addImage(
            title: result.title,
            description: result.description,
            tags: result.tags,
            imageFile: imageFile!,
            setAsCurrent: setAsCurrent,
          );
    }

    return ContentControlScreen(
      contentList: const ImageList(),
      onAdd: showAddImageSheet,
      addIcon: Icons.add_a_photo_outlined,
      addTooltip: 'Add Image',
      contentType: DisplayContentType.image,
    );
  }
}
