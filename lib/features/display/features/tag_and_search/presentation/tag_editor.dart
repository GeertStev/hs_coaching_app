import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

class ReusableTagEditor extends StatefulWidget {
  const ReusableTagEditor({
    super.key,
    required this.initialTags,
    required this.allTags,
    required this.onTagsChanged,
  });

  final List<String> initialTags;
  final List<String> allTags;
  final ValueChanged<List<String>> onTagsChanged;

  @override
  State<ReusableTagEditor> createState() => _ReusableTagEditorState();
}

class _ReusableTagEditorState extends State<ReusableTagEditor> {
  late final List<String> _tags;
  final _tagInputController = TextEditingController();
  final _tagFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the initial tags
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    _tagInputController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _addTag(String input) {
    // Bestaat de tag al in een andere schrijfwijze ("defense" vs "Defense"),
    // dan wordt de bestaande spelling hergebruikt.
    final tag = canonicalTag(input, [..._tags, ...widget.allTags]);
    if (tag.isNotEmpty && !containsTag(_tags, tag)) {
      setState(() {
        _tags.add(tag);
      });
      widget.onTagsChanged(_tags);
      _tagInputController.clear();
      _tagFocusNode.requestFocus();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Autocomplete<String>(
          focusNode: _tagFocusNode,
          textEditingController: _tagInputController,
          // Ook bij een leeg veld alle tags voorstellen, zodat de lijst
          // meteen opent bij het aantikken.
          optionsBuilder: (TextEditingValue textEditingValue) => tagSuggestions(
            allTags: widget.allTags,
            current: _tags,
            query: textEditingValue.text,
          ),
          onSelected: _addTag,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Tags',
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(controller.text),
                  tooltip: 'Add Tag',
                ),
              ),
              onSubmitted: (value) {
                _addTag(value);
                // onFieldSubmitted is not called to prevent adding the same tag twice
              },
            );
          },
        ),
        if (_tags.isNotEmpty) SizedBox(height: metrics.spacingMd),

        Wrap(
          spacing: metrics.spacingSm,
          children: _tags.map((tag) {
            return Chip(label: Text(tag), onDeleted: () => _removeTag(tag));
          }).toList(),
        ),
      ],
    );
  }
}
