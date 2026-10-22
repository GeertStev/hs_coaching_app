import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_repository.dart';
import 'package:hs_coaching_core/image/display_image.dart';

final allActiveImagesProvider = StreamProvider<List<DisplayImage>>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchAllActiveImages();
});

final currentImageIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchCurrentImageId();
});

final currentImageProvider = StreamProvider<DisplayImage?>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchCurrentImage();
});

/// Tags van de actieve afbeeldingen met hun aantal; ongebruikte tags vallen
/// vanzelf weg.
final imageTagCountsProvider = Provider<Map<String, int>>((ref) {
  final images = ref.watch(allActiveImagesProvider).value ?? const [];
  return countTags(images.map((image) => image.tags));
});

final selectedTagsProvider =
    NotifierProvider<TagSelectionNotifier, Set<String>>(
      TagSelectionNotifier.new,
    );

/// Manages the state of the search query string for filtering images.
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
    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
