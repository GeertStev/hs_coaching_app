import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/text/domain/text_markup_editing.dart';
import 'package:hs_coaching_core/text/text_markup_view.dart';

/// Content-specific widget for editing text content, met opmaakknoppen
/// (vet, cursief, onderlijnd, twee titelgroottes, kolommen, tabel) en een voorbeeld van hoe
/// de opgemaakte tekst op het scherm komt. De opmaak wordt als codes in de
/// tekst bewaard (zie core's `text_markup.dart`).
class TextContentEditor extends StatefulWidget {
  const TextContentEditor({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextContentEditor> createState() => _TextContentEditorState();
}

class _TextContentEditorState extends State<TextContentEditor> {
  final _focusNode = FocusNode();
  bool _showPreview = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _apply(TextEditingValue Function(TextEditingValue) edit) {
    widget.controller.value = edit(widget.controller.value);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: metrics.spacingXs,
          children: [
            IconButton(
              tooltip: 'Bold',
              icon: const Icon(Icons.format_bold),
              onPressed: () => _apply((v) => toggleInlineMarker(v, '**')),
            ),
            IconButton(
              tooltip: 'Italic',
              icon: const Icon(Icons.format_italic),
              onPressed: () => _apply((v) => toggleInlineMarker(v, '_')),
            ),
            IconButton(
              tooltip: 'Underline',
              icon: const Icon(Icons.format_underlined),
              onPressed: () => _apply((v) => toggleInlineMarker(v, '++')),
            ),
            IconButton(
              tooltip: 'Large heading',
              icon: const Text('H1'),
              onPressed: () => _apply((v) => toggleHeading(v, 1)),
            ),
            IconButton(
              tooltip: 'Small heading',
              icon: const Text('H2'),
              onPressed: () => _apply((v) => toggleHeading(v, 2)),
            ),
            IconButton(
              tooltip: 'Columns',
              icon: const Icon(Icons.view_column_outlined),
              onPressed: () => _apply(insertColumns),
            ),
            IconButton(
              tooltip: 'Table',
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: () => _apply(insertTable),
            ),
            IconButton(
              tooltip: _showPreview ? 'Hide preview' : 'Show preview',
              isSelected: _showPreview,
              icon: const Icon(Icons.visibility_outlined),
              selectedIcon: const Icon(Icons.visibility),
              onPressed: () => setState(() => _showPreview = !_showPreview),
            ),
          ],
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          minLines: 4,
          maxLines: 10,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Text to display'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a text.';
            }
            return null;
          },
        ),
        if (_showPreview) ...[
          SizedBox(height: metrics.spacingMd),
          Text('Preview', style: Theme.of(context).appTypography.labelCaps),
          SizedBox(height: metrics.spacingXs),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) => _TextMarkupPreview(value.text),
          ),
        ],
      ],
    );
  }
}

class _TextMarkupPreview extends StatelessWidget {
  const _TextMarkupPreview(this.source);

  final String source;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = textTheme.bodyLarge ?? const TextStyle();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(Theme.of(context).appMetrics.cardPadding),
        child: SizedBox(
          width: double.infinity,
          child: TextMarkupView(
            source,
            bodyStyle: body,
            heading1Style: textTheme.headlineMedium ?? body,
            heading2Style: textTheme.headlineSmall ?? body,
            lineColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
