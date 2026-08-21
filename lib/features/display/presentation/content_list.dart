import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/search_and_tag_bar.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef FilterPredicate<T> = bool Function(T item, String query);

class ContentList<T> extends ConsumerWidget {
  const ContentList({
    super.key,
    required this.itemsProvider,
    required this.searchQueryProvider,
    required this.allTagsProvider,
    required this.selectedTagProvider,
    required this.itemBuilder,
    required this.filterPredicate,
    required this.itemTypeSingular,
    required this.itemTypePlural,
    this.emptyStateMessage,
  });
  final ProviderBase<AsyncValue<List<T>>> Function(String? tag) itemsProvider;
  final NotifierProvider<SearchNotifier, String> searchQueryProvider;
  final StreamProvider<List<String>> allTagsProvider;
  final NotifierProvider<TagNotifier, String?> selectedTagProvider;
  final ItemBuilder<T> itemBuilder;
  final FilterPredicate<T> filterPredicate;
  final String itemTypeSingular;
  final String itemTypePlural;

  /// Overrides the default "No $itemTypePlural have been added yet." copy
  /// shown when the (untagged) list is empty — e.g. sketch's "Tap + to create
  /// one!". Optional per-feature copy, not a hardcoded special case here.
  final String? emptyStateMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final itemsAsync = ref.watch(itemsProvider(selectedTag));
    final metrics = Theme.of(context).appMetrics;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SearchAndTagBar(
          searchQueryProvider: searchQueryProvider,
          searchLabelText: 'Search $itemTypePlural...',
          allTagsProvider: allTagsProvider,
          selectedTagProvider: selectedTagProvider,
        ),
        Expanded(
          child: itemsAsync.when(
            data: (items) {
              final searchQuery = ref.watch(searchQueryProvider);
              final filteredItems = items.where((item) {
                final query = searchQuery.toLowerCase();
                return filterPredicate(item, query);
              }).toList();

              final emptyText = selectedTag == null
                  ? emptyStateMessage ??
                        'No $itemTypePlural have been added yet.'
                  : 'No $itemTypePlural found with the tag "$selectedTag".';

              if (items.isEmpty) {
                return Center(child: Text(emptyText));
              }
              if (filteredItems.isEmpty) {
                return Center(
                  child: Text('No $itemTypePlural match your search.'),
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
            error: (error, stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(metrics.spacingMd),
                child: Text(
                  'Error loading items: $error',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
