import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/presentation/tag_widgets.dart';

class ReusableTagFilterBar extends ConsumerWidget {
  const ReusableTagFilterBar({
    required this.allTagsProvider,
    required this.selectedTagProvider,
    super.key,
  });

  final StreamProvider<List<String>> allTagsProvider;
  final NotifierProvider<TagNotifier, String?> selectedTagProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTagsAsync = ref.watch(allTagsProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return allTagsAsync.when(
      data: (tags) => TagFilterBar(
        allTags: tags,
        selectedTag: selectedTag,
        onTagSelected: (tag) {
          ref.read(selectedTagProvider.notifier).setTag(tag);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
