import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_group.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';

/// Pure boom-bewerkingen op `List<TabataItem>`, losstaand van Flutter, zodat
/// de editor-widgets (slepen/herordenen/groeperen) op deze functies kunnen
/// vertrouwen en ze los te unit-testen zijn.

/// Haalt de oefening met [id] op, waar die zich ook in de boom bevindt
/// (top-level of genest in een groep).
TabataExercise? findExercise(List<TabataItem> items, String id) {
  for (final item in items) {
    switch (item) {
      case TabataItemExercise(:final exercise):
        if (exercise.id == id) return exercise;
      case TabataItemGroup(:final group):
        for (final child in group.children) {
          if (child.id == id) return child;
        }
    }
  }
  return null;
}

/// Voegt [exercise] in als nieuwe top-level kaart op positie [index].
List<TabataItem> insertExercise(
  List<TabataItem> items,
  int index,
  TabataExercise exercise,
) {
  final clamped = index.clamp(0, items.length);
  return [...items]..insert(clamped, TabataItem.exercise(exercise));
}

/// Vervangt de oefening met [updated.id] overal in de boom (top-level of
/// genest in een groep) door [updated].
List<TabataItem> replaceExercise(List<TabataItem> items, TabataExercise updated) {
  return [
    for (final item in items)
      switch (item) {
        TabataItemExercise(:final exercise) =>
          exercise.id == updated.id ? TabataItem.exercise(updated) : item,
        TabataItemGroup(:final group) => TabataItem.group(
          group.copyWith(
            children: [
              for (final child in group.children)
                child.id == updated.id ? updated : child,
            ],
          ),
        ),
      },
  ];
}

/// Vervangt de groep met [updated.id] op het topniveau door [updated].
List<TabataItem> replaceGroup(List<TabataItem> items, TabataGroup updated) {
  return [
    for (final item in items)
      switch (item) {
        TabataItemGroup(:final group) =>
          group.id == updated.id ? TabataItem.group(updated) : item,
        TabataItemExercise() => item,
      },
  ];
}

/// Verwijdert de kaart met [id], waar die zich ook in de boom bevindt. Een
/// groep die hierdoor zonder kinderen komt te zitten, verdwijnt mee; een
/// groep met precies één overgebleven kind wordt automatisch teruggezet naar
/// een losse oefening (die de rust-ná van de groep overneemt, want die kaart
/// staat nu zelf weer op het topniveau).
List<TabataItem> removeItem(List<TabataItem> items, String id) {
  final result = <TabataItem>[];
  for (final item in items) {
    switch (item) {
      case TabataItemExercise(:final exercise):
        if (exercise.id != id) result.add(item);
      case TabataItemGroup(:final group):
        if (group.id == id) continue;
        final children = group.children.where((c) => c.id != id).toList();
        if (children.isEmpty) {
          continue;
        } else if (children.length == 1) {
          result.add(
            TabataItem.exercise(
              children.single.copyWith(restAfter: group.restAfter),
            ),
          );
        } else {
          result.add(TabataItem.group(group.copyWith(children: children)));
        }
    }
  }
  return result;
}

/// Verplaatst de kaart met [draggedId] (overal in de boom) naar top-level
/// positie [targetIndex] — voor het droppen van een kaart op een
/// tussenruimte (in plaats van op een andere kaart). Zat de kaart genest in
/// een groep, dan wordt hij daaruit verwijderd volgens dezelfde
/// opruimregels als [removeItem].
List<TabataItem> moveItem(
  List<TabataItem> items,
  String draggedId,
  int targetIndex,
) {
  TabataItem? dragged;
  for (final item in items) {
    switch (item) {
      case TabataItemExercise(:final exercise):
        if (exercise.id == draggedId) dragged = item;
      case TabataItemGroup(:final group):
        if (group.id == draggedId) {
          dragged = item;
        } else {
          for (final child in group.children) {
            if (child.id == draggedId) dragged = TabataItem.exercise(child);
          }
        }
    }
  }
  if (dragged == null) return items;

  final without = removeItem(items, draggedId);
  final clampedIndex = targetIndex.clamp(0, without.length);
  return [...without]..insert(clampedIndex, dragged);
}

/// Groepeert de gesleepte oefening [draggedId] (top-level of genest) met de
/// kaart [targetId] — voor het droppen van een kaart op de body van een
/// andere kaart. Is [targetId] al een groep, dan wordt de gesleepte oefening
/// een nieuw kind; is het een losse oefening, dan ontstaat een nieuwe groep
/// van beide. Groepen zijn één niveau diep: als de gesleepte kaart zelf een
/// groep is, is dit een no-op (geen wijziging aan [items]).
List<TabataItem> groupWithTarget(
  List<TabataItem> items,
  String draggedId,
  String targetId,
) {
  if (draggedId == targetId) return items;
  final draggedExercise = findExercise(items, draggedId);
  if (draggedExercise == null) return items;

  final without = removeItem(items, draggedId);
  final targetIndex = without.indexWhere((item) => item.id == targetId);
  if (targetIndex == -1) return items;

  final target = without[targetIndex];
  final updated = switch (target) {
    TabataItemExercise(:final exercise) => TabataItem.group(
      newTabataGroup(children: [exercise, draggedExercise]),
    ),
    TabataItemGroup(:final group) => TabataItem.group(
      group.copyWith(children: [...group.children, draggedExercise]),
    ),
  };
  return [...without]..[targetIndex] = updated;
}
