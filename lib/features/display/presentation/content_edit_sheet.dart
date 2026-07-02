import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';

class ContentEditSheet extends ConsumerStatefulWidget {
  const ContentEditSheet({
    super.key,
    required this.dialogTitle,
    required this.contentSpecificWidget,
    required this.allTags,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialTags = const [],
    this.isNewItem = true,
    this.showSecondaryAction = false,
  });

  final String dialogTitle;
  final String initialTitle;
  final String initialDescription;
  final List<String> initialTags;
  final List<String> allTags;
  final Widget contentSpecificWidget;
  final bool isNewItem;
  final bool showSecondaryAction;

  @override
  ConsumerState<ContentEditSheet> createState() => _ContentEditSheetState();
}

class _ContentEditSheetState extends ConsumerState<ContentEditSheet> {
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

  void _submit(DialogAction action) {
    if (action != DialogAction.cancel && !_formKey.currentState!.validate()) {
      return;
    }

    final result = ContentEditDialogResult(
      action: action,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      tags: _tags,
    );

    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dialogTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Flexible(
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
                    widget.contentSpecificWidget,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _submit(DialogAction.cancel),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        if (widget.isNewItem) ...[
          if (widget.showSecondaryAction) ...[
            TextButton(
              onPressed: () => _submit(DialogAction.addToList),
              child: const Text('Add to List'),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton(
            onPressed: () => _submit(DialogAction.display),
            child: const Text('Display'),
          ),
        ] else ...[
          if (widget.showSecondaryAction) ...[
            TextButton(
              onPressed: () => _submit(DialogAction.copy),
              child: const Text('Save a Copy'),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton(
            onPressed: () => _submit(DialogAction.save),
            child: const Text('Save'),
          ),
        ],
      ],
    );
  }
}
