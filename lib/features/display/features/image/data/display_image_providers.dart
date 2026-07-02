import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_repository.dart';
import 'package:hs_coaching_app/features/display/features/image/domain/display_image.dart';

final allActiveImagesProvider =
    StreamProvider.family<List<DisplayImage>, String?>((ref, tag) {
      return ref
          .watch(displayImageRepositoryProvider)
          .watchAllActiveImages(tag: tag);
    });

final currentImageIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchCurrentImageIdDoc().map(
    (snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['currentId'] as String?;
    },
  );
});

final currentImageProvider = StreamProvider<DisplayImage?>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchCurrentImage();
});

final allImageTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(displayImageRepositoryProvider).watchAllImageTags();
});

/// Manages the state of the currently selected tag for filtering.
class SelectedTagNotifier extends Notifier<String?> implements TagNotifier {
  @override
  String? build() => null;
  @override
  void setTag(String? newTag) => state = newTag;
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
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
