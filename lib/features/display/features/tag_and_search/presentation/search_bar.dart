import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';

class ReusableSearchBar extends ConsumerStatefulWidget {
  const ReusableSearchBar({
    super.key,
    required this.searchQueryProvider,
    required this.labelText,
  });

  final NotifierProvider<SearchNotifier, String> searchQueryProvider;
  final String labelText;

  @override
  ConsumerState<ReusableSearchBar> createState() => _ReusableSearchBarState();
}

class _ReusableSearchBarState extends ConsumerState<ReusableSearchBar> {
  late final TextEditingController _searchQueryController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current query from the provider.
    _searchQueryController = TextEditingController(
      text: ref.read(widget.searchQueryProvider),
    );
    // Listen to external changes to the provider to update the text field.
    ref.listenManual(widget.searchQueryProvider, (previous, next) {
      if (next != _searchQueryController.text) {
        _searchQueryController.text = next;
      }
    });
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild the suffix icon when the text is cleared externally.
    ref.watch(widget.searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: TextField(
        controller: _searchQueryController,
        onChanged: (value) =>
            ref.read(widget.searchQueryProvider.notifier).setQuery(value),
        decoration: InputDecoration(
          labelText: widget.labelText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQueryController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchQueryController.clear();
                    ref.read(widget.searchQueryProvider.notifier).setQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
