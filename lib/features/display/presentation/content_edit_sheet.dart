import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_metrics.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_editor.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';

class ContentEditSheet extends ConsumerStatefulWidget {
  const ContentEditSheet({
    super.key,
    required this.dialogTitle,
    this.contentSpecificWidget,
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
  final Widget? contentSpecificWidget;
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
    final metrics = Theme.of(context).appMetrics;

    return Padding(
      padding: EdgeInsets.only(
        top: metrics.spacingLg,
        left: metrics.spacingLg,
        right: metrics.spacingLg,
        bottom:
            mediaQuery.viewInsets.bottom +
            mediaQuery.padding.bottom +
            metrics.spacingMd,
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
            SizedBox(height: metrics.spacingLg),
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
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: metrics.spacingMd),
                    TextFormField(
                      controller: _descriptionController,
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Description',
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    SizedBox(height: metrics.spacingMd),
                    ReusableTagEditor(
                      initialTags: _tags,
                      allTags: widget.allTags,
                      onTagsChanged: (updatedTags) => _tags = updatedTags,
                    ),
                    SizedBox(height: metrics.spacingMd),
                    if (widget.contentSpecificWidget != null)
                      widget.contentSpecificWidget!,
                  ],
                ),
              ),
            ),
            SizedBox(height: metrics.spacingLg),
            _buildActions(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(AppMetrics metrics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _submit(DialogAction.cancel),
          child: const Text('Cancel'),
        ),
        SizedBox(width: metrics.spacingSm),
        if (widget.isNewItem) ...[
          if (widget.showSecondaryAction) ...[
            TextButton(
              onPressed: () => _submit(DialogAction.addToList),
              child: const Text('Add to List'),
            ),
            SizedBox(width: metrics.spacingSm),
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
            SizedBox(width: metrics.spacingSm),
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
