import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/timer/data/timer_repository.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_exercise.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_state.dart';

/// Provider for the timer repository.
final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository(ref);
});

/// A provider that streams the list of all available TimerExercises.
final timerExerciseListProvider = StreamProvider<List<TimerExercise>>((ref) {
  final repository = ref.watch(timerRepositoryProvider);
  return repository.watchAllTimerExercises();
});

/// A provider that streams the list of all available TimerSets.
final timerSetListProvider = StreamProvider.family<List<TimerSet>, String?>((
  ref,
  tag,
) {
  return ref.watch(timerRepositoryProvider).watchAllTimerSets(tag: tag);
});

/// A provider that streams the latest timer state from Firestore for the
/// currently selected display.
final timerStateProvider = StreamProvider<TimerState>((ref) {
  final repository = ref.watch(timerRepositoryProvider);
  return repository.watchTimerState();
});

/// A provider that streams the list of all used timer set tags.
final allTimerSetTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(timerRepositoryProvider).watchAllTimerSetTags();
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

/// Manages the state of the search query string for filtering timer sets.
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
