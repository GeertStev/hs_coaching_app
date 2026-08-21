import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_core/text/display_text.dart';

final allActiveTextsProvider =
    StreamProvider.family<List<DisplayText>, String?>((ref, tag) {
      return ref
          .watch(displayTextRepositoryProvider)
          .watchAllActiveTexts(tag: tag);
    });

final currentTextIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchCurrentTextIdDoc().map((
    snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['currentId'] as String?;
  });
});

final currentTextProvider = StreamProvider<DisplayText?>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchCurrentText();
});

final allTextTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchAllTextTags();
});

/// Manages the state of the currently selected tag for filtering.
class SelectedTagNotifier extends Notifier<String?> implements TagNotifier {
  @override
  String? build() {
    // The initial state of the filter is null (showing all items).
    return null;
  }

  /// Sets the filter to a new tag, or null to clear the filter.
  @override
  void setTag(String? newTag) {
    state = newTag;
  }
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
);

/// Manages the state of the search query string for filtering texts.
class SearchQueryNotifier extends Notifier<String> implements SearchNotifier {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  @override
  void setQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => state = query);
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
