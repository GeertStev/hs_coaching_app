import 'package:flutter/material.dart';
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
        decoration: const InputDecoration(labelText: 'Titel'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Bewaren'),
        ),
      ],
    );
  }
}

/// Toont een keuzelijst van opgeslagen templates (al gefilterd op het
/// kaartniveau dat op deze plek geldig is — bijv. een Subset kan geen
/// Set-templates aanbieden) en geeft de gekozen template terug (`null` als
/// geannuleerd of niets gekozen).
Future<TrainingTemplate?> showTrainingTemplatePicker(
  BuildContext context, {
  required String title,
  required List<TrainingTemplate> templates,
}) {
  return showDialog<TrainingTemplate>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(title),
      children: [
        if (templates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Nog geen templates opgeslagen op dit niveau.'),
          ),
        for (final template in templates)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(template),
            child: Text(template.title),
          ),
      ],
    ),
  );
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
      title: const Text('Verwijderen?'),
      content: Text('"$itemLabel" wordt definitief verwijderd.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Verwijderen'),
        ),
      ],
    ),
  );
}
