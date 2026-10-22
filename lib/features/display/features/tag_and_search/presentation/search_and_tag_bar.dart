import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/reusable_search_bar.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_filter_bar.dart';

class SearchAndTagBar extends ConsumerStatefulWidget {
  const SearchAndTagBar({
    super.key,
    required this.searchQueryProvider,
    required this.searchLabelText,
    required this.tagCounts,
    required this.selectedTagsProvider,
    required this.tagMaintenanceProvider,
  });

  final NotifierProvider<SearchNotifier, String> searchQueryProvider;
  final String searchLabelText;
  final Map<String, int> tagCounts;
  final NotifierProvider<TagSelectionNotifier, Set<String>>
  selectedTagsProvider;
  final ProviderListenable<TagMaintenance> tagMaintenanceProvider;

  @override
  ConsumerState<SearchAndTagBar> createState() => _SearchAndTagBarState();
}

class _SearchAndTagBarState extends ConsumerState<SearchAndTagBar> {
  bool _isSearchOpen = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearchOpen = true);
    // Request focus after the widget has been built in the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() => _isSearchOpen = false);
    ref.read(widget.searchQueryProvider.notifier).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final tagBar = ReusableTagFilterBar(
      tagCounts: widget.tagCounts,
      selectedTagsProvider: widget.selectedTagsProvider,
      tagMaintenanceProvider: widget.tagMaintenanceProvider,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: const AlignmentDirectional(-1, -1),
          child: child,
        );
      },
      child: _isSearchOpen
          ? Column(
              key: const ValueKey('search_open'),
              children: [
                ReusableSearchBar(
                  searchQueryProvider: widget.searchQueryProvider,
                  labelText: widget.searchLabelText,
                  onClose: _closeSearch,
                  focusNode: _searchFocusNode,
                ),
                tagBar,
              ],
            )
          : Row(
              key: const ValueKey('search_closed'),
              children: [
                Expanded(child: tagBar),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _openSearch,
                  tooltip: 'Search',
                ),
              ],
            ),
    );
  }
}
