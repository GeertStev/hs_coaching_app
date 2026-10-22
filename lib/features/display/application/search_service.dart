import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

abstract class SearchNotifier extends Notifier<String> {
  void setQuery(String query);
}

/// De geselecteerde filter-tags van één lijst. Een item moet ze allemaal
/// hebben om getoond te worden (zie `matchesAllTags`); leeg = alles tonen.
class TagSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String tag) {
    state = containsTag(state, tag)
        ? {
            for (final t in state)
              if (tagKey(t) != tagKey(tag)) t,
          }
        : {...state, tag};
  }

  void clear() => state = const {};

  /// Houdt de selectie in lijn na het hernoemen (of met een lege [to]:
  /// verwijderen) van een tag.
  void rename(String from, String to) {
    if (!containsTag(state, from)) return;
    state = renameTagIn(state.toList(), from, to).toSet();
  }
}
