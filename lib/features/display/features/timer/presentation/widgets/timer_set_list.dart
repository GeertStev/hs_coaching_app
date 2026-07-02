import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/timer/data/timer_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/widgets/timer_set_tile.dart';
import 'package:hs_coaching_app/features/display/presentation/content_list.dart';

class TimerSetList extends ConsumerWidget {
  const TimerSetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentList<TimerSet>(
      itemsProvider: timerSetListProvider.call,
      searchQueryProvider: searchQueryProvider,
      allTagsProvider: allTimerSetTagsProvider,
      selectedTagProvider: selectedTagProvider,
      itemTypePlural: 'timer sets',
      itemTypeSingular: 'timer set',
      filterPredicate: (item, query) =>
          item.title.toLowerCase().contains(query),
      itemBuilder: (context, item) => TimerSetTile(timerSet: item),
    );
  }
}
