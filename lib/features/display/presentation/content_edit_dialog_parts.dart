import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_background.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/widgets/select_sketch_background_dialog.dart';

/// Content-specific widget for selecting a sketch background.
class SketchContentEditor extends StatefulWidget {
  const SketchContentEditor({
    super.key,
    required this.allBackgrounds,
    required this.selectedUrl,
    required this.onSelected,
  });

  final List<SketchBackground> allBackgrounds;
  final String? selectedUrl;
  final ValueChanged<String?> onSelected;

  @override
  State<SketchContentEditor> createState() => _SketchContentEditorState();
}

class _SketchContentEditorState extends State<SketchContentEditor> {
  Future<void> _showSelectionDialog(BuildContext context) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) =>
          SelectSketchBackgroundDialog(initialSelectedUrl: widget.selectedUrl),
    );

    if (result != null || widget.selectedUrl != null) {
      widget.onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBackground = widget.allBackgrounds.firstWhere(
      (bg) => bg.url == widget.selectedUrl,
      orElse: () => const SketchBackground(title: 'None', url: ''),
    );

    final title = widget.selectedUrl == null
        ? 'None'
        : selectedBackground.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ToDo Styling
        Text('Background', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          title: Text(title, overflow: TextOverflow.ellipsis),
          trailing: const Text('Change'),
          onTap: () => _showSelectionDialog(context),
        ),
      ],
    );
  }
}

/// Content-specific widget for selecting/previewing an image.
class ImageContentEditor extends StatelessWidget {
  const ImageContentEditor({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPickImage,
  });

  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    if (imageFile == null && imageUrl == null) {
      return Center(
        child: OutlinedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Select Image'),
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: onPickImage,
        child: imageFile != null
            ? Image.file(imageFile!, height: 150)
            : Image.network(imageUrl!, height: 150),
      ),
    );
  }
}

/// Content-specific widget for editing text content.
class TextContentEditor extends StatelessWidget {
  const TextContentEditor({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 4,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Text to display',
        border: OutlineInputBorder(),
      ),
    );
  }
}
