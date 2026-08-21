import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_global_settings_repository.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageContentEditor extends ConsumerStatefulWidget {
  const ImageContentEditor({
    super.key,
    this.initialImageUrl,
    this.onImageChanged,
  });

  final String? initialImageUrl;
  final ValueChanged<File?>? onImageChanged;

  @override
  ConsumerState<ImageContentEditor> createState() => _ImageContentEditorState();
}

class _ImageContentEditorState extends ConsumerState<ImageContentEditor> {
  File? _imageFile;
  //final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndCropImage() async {
    final theme = Theme.of(context);
    final settings = ref.read(globalSettingsProvider).value;

    // ToDo Content size settings
    final fullWidth = settings?.contentWidth.toDouble() ?? 624;
    final width = fullWidth - 12 - 12;
    final fullHeight = settings?.contentHeight.toDouble() ?? 416;
    final height = fullHeight - 12 - 42;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted || pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: width, ratioY: height),
      maxWidth: width.toInt(),
      maxHeight: height.toInt(),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );
    if (croppedFile != null) {
      final file = File(croppedFile.path);
      setState(() => _imageFile = file);
      widget.onImageChanged?.call(file);
    }
  }

  /*Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      widget.onImageChanged?.call(_imageFile);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (_imageFile != null) {
      imageWidget = Image.file(File(_imageFile!.path), fit: BoxFit.cover);
    } else if (widget.initialImageUrl != null) {
      imageWidget = Image.network(widget.initialImageUrl!, fit: BoxFit.cover);
    } else {
      imageWidget = const Center(
        child: Icon(Icons.add_a_photo_outlined, size: 48),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: widget.initialImageUrl == null || _imageFile != null
                ? _pickAndCropImage
                : null,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageWidget,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
