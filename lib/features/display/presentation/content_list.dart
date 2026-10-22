import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/search_and_tag_bar.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef FilterPredicate<T> = bool Function(T item, String query);

class ContentList<T> extends ConsumerWidget {
  const ContentList({
    super.key,
    required this.itemsProvider,
    required this.searchQueryProvider,
    required this.tagCountsProvider,
    required this.selectedTagsProvider,
    required this.tagMaintenanceProvider,
    required this.tagsOf,
    required this.itemBuilder,
    required this.filterPredicate,
    required this.itemTypeSingular,
    required this.itemTypePlural,
    this.emptyStateMessage,
  });

  /// Alle actieve items; tag- en zoekfilters worden lokaal toegepast.
  final ProviderListenable<AsyncValue<List<T>>> itemsProvider;
  final NotifierProvider<SearchNotifier, String> searchQueryProvider;

  /// Gebruikte tags met hun aantal items (zie `countTags`).
  final ProviderListenable<Map<String, int>> tagCountsProvider;
  final NotifierProvider<TagSelectionNotifier, Set<String>>
  selectedTagsProvider;
  final ProviderListenable<TagMaintenance> tagMaintenanceProvider;
  final List<String> Function(T item) tagsOf;
  final ItemBuilder<T> itemBuilder;
  final FilterPredicate<T> filterPredicate;
  final String itemTypeSingular;
  final String itemTypePlural;

  /// Overrides the default "No $itemTypePlural have been added yet." copy
  /// shown when the list is empty — e.g. sketch's "Tap + to create
  /// one!". Optional per-feature copy, not a hardcoded special case here.
  final String? emptyStateMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    final itemsAsync = ref.watch(itemsProvider);
    final metrics = Theme.of(context).appMetrics;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SearchAndTagBar(
          searchQueryProvider: searchQueryProvider,
          searchLabelText: 'Search $itemTypePlural...',
          tagCounts: ref.watch(tagCountsProvider),
          selectedTagsProvider: selectedTagsProvider,
          tagMaintenanceProvider: tagMaintenanceProvider,
        ),
        Expanded(
          child: itemsAsync.when(
            data: (items) {
              final searchQuery = ref.watch(searchQueryProvider);
              final query = searchQuery.toLowerCase();
              final filteredItems = items
                  .where(
                    (item) =>
                        matchesAllTags(tagsOf(item), selectedTags) &&
                        filterPredicate(item, query),
                  )
                  .toList();

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    emptyStateMessage ??
                        'No $itemTypePlural have been added yet.',
                  ),
                );
              }
              if (filteredItems.isEmpty) {
                return Center(
                  child: Text(
                    selectedTags.isEmpty
                        ? 'No $itemTypePlural match your search.'
                        : 'No $itemTypePlural with all selected tags.',
                  ),
                );
              }
              return ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return itemBuilder(context, item);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(itemsProvider(selectedTag)),
            ),
          ),
        ),
      ],
    );
  }
}
