import 'package:flutter/material.dart';

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

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Autocomplete<String>(
          focusNode: _tagFocusNode,
          textEditingController: _tagInputController,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.allTags.where((String option) {
              return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) &&
                  !_tags.contains(option);
            });
          },
          onSelected: _addTag,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Tags',
                isDense: true,
                border: const OutlineInputBorder(),
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
        if (_tags.isNotEmpty) const SizedBox(height: 16),

        Wrap(
          spacing: 6.0,
          runSpacing: -2.0,

          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              //labelPadding: const EdgeInsets.all(2),
              //padding: const EdgeInsets.all(2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
