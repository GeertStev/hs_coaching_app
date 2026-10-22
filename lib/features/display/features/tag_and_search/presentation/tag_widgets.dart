import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

/// A horizontal list of filter chips for tags, each with its usage count.
/// Several tags can be selected at once; an item must have all of them.
/// Long-pressing a tag calls [onTagLongPress] (rename/delete menu).
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    required this.tagCounts,
    required this.selectedTags,
    required this.onTagToggled,
    required this.onClear,
    this.onTagLongPress,
    super.key,
  });

  final Map<String, int> tagCounts;
  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onClear;
  final ValueChanged<String>? onTagLongPress;

  @override
  Widget build(BuildContext context) {
    // Geselecteerde tags blijven zichtbaar, ook als geen enkel item ze nog
    // heeft, zodat je ze kunt uitvinken.
    final tags = {
      ...tagCounts,
      for (final tag in selectedTags)
        if (!containsTag(tagCounts.keys, tag)) tag: 0,
    };
    if (tags.isEmpty) return const SizedBox.shrink();

    final metrics = Theme.of(context).appMetrics;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: metrics.spacingSm,
        vertical: metrics.spacingXs,
      ),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedTags.isEmpty,
            onSelected: (isSelected) {
              if (isSelected) onClear();
            },
          ),
          ...tags.entries.map((entry) {
            final tag = entry.key;
            return Padding(
              padding: EdgeInsets.only(left: metrics.spacingSm),
              child: GestureDetector(
                onLongPress: onTagLongPress == null
                    ? null
                    : () => onTagLongPress!(tag),
                child: FilterChip(
                  label: Text('$tag (${entry.value})'),
                  selected: containsTag(selectedTags, tag),
                  onSelected: (_) => onTagToggled(tag),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
