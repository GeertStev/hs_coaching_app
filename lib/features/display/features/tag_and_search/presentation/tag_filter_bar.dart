import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_management.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_widgets.dart';

/// [TagFilterBar] wired to a selection provider, with long-press tag
/// management through [tagMaintenanceProvider].
class ReusableTagFilterBar extends ConsumerWidget {
  const ReusableTagFilterBar({
    required this.tagCounts,
    required this.selectedTagsProvider,
    required this.tagMaintenanceProvider,
    super.key,
  });

  final Map<String, int> tagCounts;
  final NotifierProvider<TagSelectionNotifier, Set<String>>
  selectedTagsProvider;
  final ProviderListenable<TagMaintenance> tagMaintenanceProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    final selection = ref.read(selectedTagsProvider.notifier);

    return TagFilterBar(
      tagCounts: tagCounts,
      selectedTags: selectedTags,
      onTagToggled: selection.toggle,
      onClear: selection.clear,
      onTagLongPress: (tag) => showTagActions(
        context,
        tag: tag,
        usageCount: tagCounts[tag] ?? 0,
        allTags: tagCounts.keys,
        maintenance: ref.read(tagMaintenanceProvider),
        onChanged: selection.rename,
      ),
    );
  }
}
