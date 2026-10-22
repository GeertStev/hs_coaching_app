import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_providers.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/image_controller.dart';
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
    // Optioneel: Luister naar errors van de controller om een SnackBar te tonen
    ref.listen<AsyncValue<void>>(imageControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    Future<void> handleAddImage() async {
      File? imageFile;
      final allTags = ref.read(imageTagCountsProvider).keys.toList();

      // UI Logica: Tonen van de dialoog
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

      // Early return bij annuleren
      if (result == null ||
          result.action == DialogAction.cancel ||
          imageFile == null) {
        return;
      }

      // Business Logica delegatie
      final setAsCurrent = result.action == DialogAction.display;

      // Roep de controller aan, let op de .notifier
      await ref
          .read(imageControllerProvider.notifier)
          .addImage(
            result: result,
            imageFile: imageFile!,
            setAsCurrent: setAsCurrent,
          );
    }

    return ContentControlScreen(
      body: const ImageList(),
      addAction: (
        icon: Icons.add_a_photo_outlined,
        tooltip: 'Add Image',
        onPressed: handleAddImage,
      ),
      contentType: DisplayContentType.image,
    );
  }
}
