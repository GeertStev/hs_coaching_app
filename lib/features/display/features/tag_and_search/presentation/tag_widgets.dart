import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';

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
            selected: selectedTag == null,
            onSelected: (isSelected) {
              if (isSelected) onTagSelected(null);
            },
          ),
          ...allTags.map((tag) {
            return Padding(
              padding: EdgeInsets.only(left: metrics.spacingSm),
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
