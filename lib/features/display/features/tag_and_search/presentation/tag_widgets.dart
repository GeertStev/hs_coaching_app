import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_providers.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_providers.dart';

/// A widget that displays a horizontal list of filter chips for tags.
class TagFilterBar extends ConsumerWidget {
  const TagFilterBar({
    required this.allTags,
    required this.selectedTag,
    required this.onTagSelected,
    super.key,
  });

  final List<String> allTags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (allTags.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedTag == null,
            onSelected: (isSelected) {
              if (isSelected) onTagSelected(null);
            },
          ),
          ...allTags.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(tag),
                selected: selectedTag == tag,
                onSelected: (isSelected) {
                  onTagSelected(isSelected ? tag : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// A widget for inputting and managing a list of tags.
class TagInput extends ConsumerStatefulWidget {
  const TagInput({
    required this.onTagsChanged,
    this.isImageTags = false,
    this.initialTags = const [],
    this.enabled = true,
    super.key,
  });

  final ValueChanged<List<String>> onTagsChanged;
  final bool isImageTags;
  final List<String> initialTags;
  final bool enabled;

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  late final List<String> _selectedTags;
  final _tagInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final newTag = tag.trim();
    if (newTag.isNotEmpty && !_selectedTags.contains(newTag)) {
      setState(() {
        _selectedTags.add(newTag);
      });
      widget.onTagsChanged(_selectedTags);
    }
    _tagInputController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    widget.onTagsChanged(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final allTagsAsync = widget.isImageTags
        ? ref.watch(allImageTagsProvider)
        : ref.watch(allTextTagsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        allTagsAsync.when(
          data: (allTags) {
            return RawAutocomplete<String>(
              textEditingController: _tagInputController,
              focusNode: FocusNode(),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return allTags.where(
                  (option) => option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: _addTag,
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  focusNode: focusNode,
                  decoration: const InputDecoration(hintText: 'Add a tag'),
                  onSubmitted: _addTag,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => const Text('Could not load tags.'),
        ),
        const SizedBox(height: 8),
        if (_selectedTags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedTags.map((tag) {
              return InputChip(
                label: Text(tag),
                onDeleted: widget.enabled ? () => _removeTag(tag) : null,
              );
            }).toList(),
          ),
      ],
    );
  }
}
