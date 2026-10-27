import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_editor.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_widgets.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';

/// Dialoog om (enkel) een titel in te voeren — gedeeld door Set/Subset/
/// Oefening-kaarten (hernoemen, bewaren als template) zodat er maar één
/// implementatie is in plaats van drie bijna-identieke kopieën.
Future<String?> showTrainingTitleDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TitleDialog(title: title, initial: initial),
  );
}

class _TitleDialog extends StatefulWidget {
  const _TitleDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Toont een keuzelijst van opgeslagen templates (al gefilterd op het
/// kaartniveau dat op deze plek geldig is — bijv. een Subset kan geen
/// Set-templates aanbieden) en geeft de gekozen template terug (`null` als
/// geannuleerd of niets gekozen). Bovenaan kan op tags gefilterd worden.
Future<TrainingTemplate?> showTrainingTemplatePicker(
  BuildContext context, {
  required String title,
  required List<TrainingTemplate> templates,
}) {
  return showDialog<TrainingTemplate>(
    context: context,
    builder: (context) =>
        _TemplatePickerDialog(title: title, templates: templates),
  );
}

class _TemplatePickerDialog extends StatefulWidget {
  const _TemplatePickerDialog({required this.title, required this.templates});

  final String title;
  final List<TrainingTemplate> templates;

  @override
  State<_TemplatePickerDialog> createState() => _TemplatePickerDialogState();
}

class _TemplatePickerDialogState extends State<_TemplatePickerDialog> {
  Set<String> _selectedTags = const {};

  void _toggle(String tag) {
    setState(() {
      _selectedTags = containsTag(_selectedTags, tag)
          ? {
              for (final t in _selectedTags)
                if (tagKey(t) != tagKey(tag)) t,
            }
          : {..._selectedTags, tag};
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagCounts = countTags(widget.templates.map((t) => t.tags));
    final visible = widget.templates
        .where((t) => matchesAllTags(t.tags, _selectedTags))
        .toList();

    return SimpleDialog(
      title: Text(widget.title),
      children: [
        if (tagCounts.isNotEmpty)
          TagFilterBar(
            tagCounts: tagCounts,
            selectedTags: _selectedTags,
            onTagToggled: _toggle,
            onClear: () => setState(() => _selectedTags = const {}),
          ),
        if (widget.templates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('No templates saved at this level yet.'),
          )
        else if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('No templates with all selected tags.'),
          ),
        for (final template in visible)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(template),
            child: Text(template.title),
          ),
      ],
    );
  }
}

/// Dialoog om titel en tags van een template in te stellen — bij "bewaar als
/// template" en bij het bewerken vanuit de LIST-tab. Geeft `null` terug als
/// geannuleerd.
Future<({String title, List<String> tags})?> showTrainingTemplateDetailsDialog(
  BuildContext context, {
  required String dialogTitle,
  required String initialTitle,
  List<String> initialTags = const [],
  required List<String> allTags,
}) {
  return showDialog<({String title, List<String> tags})>(
    context: context,
    builder: (context) => _TemplateDetailsDialog(
      dialogTitle: dialogTitle,
      initialTitle: initialTitle,
      initialTags: initialTags,
      allTags: allTags,
    ),
  );
}

class _TemplateDetailsDialog extends StatefulWidget {
  const _TemplateDetailsDialog({
    required this.dialogTitle,
    required this.initialTitle,
    required this.initialTags,
    required this.allTags,
  });

  final String dialogTitle;
  final String initialTitle;
  final List<String> initialTags;
  final List<String> allTags;

  @override
  State<_TemplateDetailsDialog> createState() => _TemplateDetailsDialogState();
}

class _TemplateDetailsDialogState extends State<_TemplateDetailsDialog> {
  late final TextEditingController _controller;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _tags = List.of(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop((title: title, tags: _tags));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            ReusableTagEditor(
              initialTags: _tags,
              allTags: widget.allTags,
              onTagsChanged: (tags) => _tags = List.of(tags),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

/// Bevestigingsdialoog voor het verwijderen van een kaart — gedeeld door
/// Set/Subset/Oefening.
Future<bool?> showTrainingDeleteConfirmDialog(
  BuildContext context, {
  required String itemLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete?'),
      content: Text('"$itemLabel" will be deleted permanently.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
