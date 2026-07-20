import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_editor.dart';

enum DialogAction {
  // ToDo: Move to its own file
  cancel,
  addToList,
  copy,
  display,
  save,
}

class ContentEditDialogResult {
  const ContentEditDialogResult({
    required this.action,
    required this.title,
    required this.description,
    required this.tags,
  });

  final DialogAction action;
  final String title;
  final String description;
  final List<String> tags;
}

class ContentEditDialog extends ConsumerStatefulWidget {
  const ContentEditDialog({
    super.key,
    required this.dialogTitle,
    this.contentSpecificWidget,
    required this.allTags,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialTags = const [],
    this.isNewItem = true,
    this.showSecondaryAction = false,
    this.onWillPop,
  });

  final String dialogTitle;
  final String initialTitle;
  final String initialDescription;
  final List<String> initialTags;
  final List<String> allTags;
  final Widget? contentSpecificWidget;
  final bool isNewItem;
  final bool showSecondaryAction;
  final Future<bool> Function(ContentEditDialogResult?)? onWillPop;

  @override
  ConsumerState<ContentEditDialog> createState() => _ContentEditDialogState();
}

class _ContentEditDialogState extends ConsumerState<ContentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(DialogAction action) async {
    if (action != DialogAction.cancel && !_formKey.currentState!.validate()) {
      return;
    }

    final result = ContentEditDialogResult(
      action: action,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      tags: _tags,
    );

    bool shouldPop = true;
    if (widget.onWillPop != null) {
      shouldPop = await widget.onWillPop!(result);
    }

    if (mounted && shouldPop) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      //titlePadding: const EdgeInsets.only(top: 24, left: 24, bottom: 12),
      //contentPadding: const EdgeInsets.only(left: 24, right: 24),
      //actionsPadding: const EdgeInsets.only(top: 12, bottom: 12, right: 24),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ReusableTagEditor(
                initialTags: _tags,
                allTags: widget.allTags,
                onTagsChanged: (updatedTags) => _tags = updatedTags,
              ),
              const SizedBox(height: 16),
              //widget.contentSpecificWidget,
              if (widget.contentSpecificWidget != null)
                widget.contentSpecificWidget!, // <-- Voeg null-check toe
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async => await _submit(DialogAction.cancel),
          child: const Text('Cancel'),
        ),
        if (widget.isNewItem) ...[
          if (widget.showSecondaryAction)
            TextButton(
              onPressed: () async => await _submit(DialogAction.addToList),
              child: const Text('Add to List'),
            ),
          FilledButton(
            onPressed: () async => await _submit(DialogAction.display),
            child: const Text('Display'),
          ),
        ] else ...[
          if (widget.showSecondaryAction)
            TextButton(
              onPressed: () async => await _submit(DialogAction.copy),
              child: const Text('Save a Copy'),
            ),
          FilledButton(
            onPressed: () async => await _submit(DialogAction.save),
            child: const Text('Save'),
          ),
        ],
      ],
    );
  }
}
