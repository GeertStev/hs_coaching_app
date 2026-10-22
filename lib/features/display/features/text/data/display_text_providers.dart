import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_core/text/display_text.dart';

final allActiveTextsProvider = StreamProvider<List<DisplayText>>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchAllActiveTexts();
});

final currentTextIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchCurrentTextId();
});

final currentTextProvider = StreamProvider<DisplayText?>((ref) {
  return ref.watch(displayTextRepositoryProvider).watchCurrentText();
});

/// Tags van de actieve teksten met hun aantal; ongebruikte tags vallen
/// vanzelf weg.
final textTagCountsProvider = Provider<Map<String, int>>((ref) {
  final texts = ref.watch(allActiveTextsProvider).value ?? const [];
  return countTags(texts.map((text) => text.tags));
});

final selectedTagsProvider =
    NotifierProvider<TagSelectionNotifier, Set<String>>(
      TagSelectionNotifier.new,
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
