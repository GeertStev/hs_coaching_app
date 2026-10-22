import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
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
  final _fieldKey = GlobalKey<FormFieldState<File>>();
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
      // Foutmelding onder het vak wissen zodra er een afbeelding is.
      _fieldKey.currentState?.didChange(file);
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

    // FormField zodat de Form van ContentEditSheet ook de afbeelding valideert,
    // net zoals de titel: foutmelding onder het vak, knoppen blijven actief.
    return FormField<File>(
      key: _fieldKey,
      validator: (_) => _imageFile == null && widget.initialImageUrl == null
          ? 'Please select an image.'
          : null,
      builder: (field) {
        final colorScheme = Theme.of(context).colorScheme;
        final metrics = Theme.of(context).appMetrics;
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
                      color: field.hasError
                          ? colorScheme.error
                          : colorScheme.outline,
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
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(
                  top: metrics.spacingSm,
                  left: metrics.spacingMd,
                ),
                child: Text(
                  field.errorText!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
