import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:hs_coaching_app/features/display/data/display_global_settings_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddSketchBackgroundDialog extends ConsumerStatefulWidget {
  const AddSketchBackgroundDialog({super.key});

  @override
  ConsumerState<AddSketchBackgroundDialog> createState() =>
      _AddSketchBackgroundDialogState();
}

class _AddSketchBackgroundDialogState
    extends ConsumerState<AddSketchBackgroundDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickAndCropImage() async {
    final theme = Theme.of(context);
    // ToDo Uniform settings across features
    //final settings = ref.read(globalSettingsProvider).value;
    final width = 540.0;
    //settings?.width.toDouble() ?? 1920.0;
    final height = 360.0;
    //settings?.height.toDouble() ?? 1080.0;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted || pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: width, ratioY: height),
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      maxWidth: width.toInt(),
      maxHeight: height.toInt(),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Background',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Background',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() => _imageFile = File(croppedFile.path));
    }
  }

  Future<void> _uploadBackground() async {
    if (_imageFile == null || !_formKey.currentState!.validate() || !mounted) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .addSketchBackground(
            imageFile: _imageFile!,
            title: _titleController.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Background'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile == null)
                OutlinedButton.icon(
                  onPressed: _pickAndCropImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Select Image'),
                )
              else
                Image.file(_imageFile!, height: 150),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Background Title',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_imageFile == null || _isUploading)
              ? null
              : _uploadBackground,
          child: _isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }
}
