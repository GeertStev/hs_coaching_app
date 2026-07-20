import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart'; // Gebruik FilePicker in plaats van ImagePicker
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';

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
  File? _svgFile;
  String? _fileName;
  bool _isUploading = false;

  Future<void> _pickSvgFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg'], // Selecteer enkel SVG bestanden
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _svgFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij selecteren bestand: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _uploadBackground() async {
    if (_svgFile == null || !_formKey.currentState!.validate() || !mounted) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      // De repository uploadt de file direct naar Firebase Storage
      await ref
          .read(sketchRepositoryProvider)
          .addSketchBackground(
            imageFile: _svgFile!,
            title: _titleController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload mislukt: $e'),
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
      title: const Text('Nieuwe SVG Achtergrond'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_svgFile == null)
                OutlinedButton.icon(
                  onPressed: _pickSvgFile,
                  icon: const Icon(Icons.image),
                  label: const Text('Selecteer SVG-bestand'),
                )
              else
                ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue,
                  ),
                  title: Text(_fileName ?? 'Geselecteerd bestand'),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _svgFile = null;
                      _fileName = null;
                    }),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Naam van achtergrond (bijv. Zwembad 50m)',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Naam is verplicht'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: (_svgFile == null || _isUploading)
              ? null
              : _uploadBackground,
          child: _isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Text('Uploaden'),
        ),
      ],
    );
  }
}

/*import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
}*/
