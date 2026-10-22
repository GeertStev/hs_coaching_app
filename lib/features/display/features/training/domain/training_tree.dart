import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_core/training/training_path.dart';
import 'package:hs_coaching_core/training/training_validation.dart';

export 'package:hs_coaching_core/training/training_path.dart' show TrainingPath;

/// Gegooid wanneer een [TrainingPath] niet bij de daadwerkelijke vorm van
/// de boom past (bijv. een index buiten bereik, of een pad dat door een
/// losse oefening probeert te lopen alsof het een groep is).
class TrainingPathError extends Error {
  TrainingPathError(this.message);
  final String message;

  @override
  String toString() => 'TrainingPathError: $message';
}

/// Gegooid door [moveNode]/[groupWithTarget] wanneer de bewerking
/// structureel zin heeft (juiste padvorm) maar de max-diepte-3-invariant
/// zou schenden (zie `training_validation.dart`'s `subtreeHeight`). Bewust
/// een ander type dan [TrainingPathError]: dit is een afgewezen
/// sleepgebaar (de UI toont [reason]), geen programmeerfout.
class TrainingInvalidMoveException implements Exception {
  TrainingInvalidMoveException(this.node, this.parentPath, this.reason);
  final TrainingNode node;
  final TrainingPath parentPath;
  final String reason;

  @override
  String toString() => 'TrainingInvalidMoveException: $reason';
}

/// Geeft de knoop op [path] terug.
TrainingNode nodeAt(Training training, TrainingPath path) {
  if (path.isEmpty) {
    throw TrainingPathError('path mag niet leeg zijn');
  }

  var node = _at(training.children, path[0], 'root');
  for (var i = 1; i < path.length; i++) {
    node = _at(_asGroup(node).children, path[i], 'niveau $i');
  }
  return node;
}

/// Geeft een kopie van [training] terug met de knoop op [path] vervangen
/// door [node].
Training replaceAt(Training training, TrainingPath path, TrainingNode node) {
  if (path.isEmpty) {
    throw TrainingPathError('path mag niet leeg zijn');
  }

  if (path.length == 1) {
    return training.copyWith(
      children: _replaceIndex(training.children, path[0], node),
    );
  }

  final parentPath = path.sublist(0, path.length - 1);
  final parentGroup = _asGroup(nodeAt(training, parentPath));
  final updatedGroup = parentGroup.copyWith(
    children: _replaceIndex(parentGroup.children, path.last, node),
  );
  return replaceAt(
    training,
    parentPath,
    TrainingNode.group(group: updatedGroup),
  );
}

/// Geeft een kopie van [training] terug zonder de knoop op [path]. Een
/// (Sub)Set zonder kinderen heeft geen zin (zie `training_group_card.dart`'s
/// "Set"/"Subset"-label) — als het verwijderen van [path] diens ouder-groep
/// leeg achterlaat, wordt die groep zelf ook meteen verwijderd, cascaderend
/// omhoog via dezelfde functie (elk recursief niveau checkt opnieuw of de
/// eigen verwijdering zijn ouder op zijn beurt ook leeg maakt).
Training removeAt(Training training, TrainingPath path) {
  if (path.isEmpty) {
    throw TrainingPathError('path mag niet leeg zijn');
  }

  if (path.length == 1) {
    final copy = List<TrainingNode>.of(training.children)
      ..removeAt(path[0]);
    return training.copyWith(children: copy);
  }

  final parentPath = path.sublist(0, path.length - 1);
  final parentGroup = _asGroup(nodeAt(training, parentPath));
  final copy = List<TrainingNode>.of(parentGroup.children)
    ..removeAt(path.last);

  if (copy.isEmpty) {
    return removeAt(training, parentPath);
  }

  return replaceAt(
    training,
    parentPath,
    TrainingNode.group(group: parentGroup.copyWith(children: copy)),
  );
}

/// Voegt [node] toe op positie [index] in de kinderlijst aangeduid door
/// [parentPath]: lengte 0 is de root-lijst zelf, elke grotere lengte is de
/// `children` van de groep op dat pad.
Training insertAt(
  Training training,
  TrainingPath parentPath,
  int index,
  TrainingNode node,
) {
  if (parentPath.isEmpty) {
    final copy = List<TrainingNode>.of(training.children)
      ..insert(index, node);
    return training.copyWith(children: copy);
  }

  final parentGroup = _asGroup(nodeAt(training, parentPath));
  final copy = List<TrainingNode>.of(parentGroup.children)
    ..insert(index, node);
  return replaceAt(
    training,
    parentPath,
    TrainingNode.group(group: parentGroup.copyWith(children: copy)),
  );
}

/// Of [node] ingevoegd mag worden in de kinderlijst aangeduid door
/// [parentPath] — de enige validatieregel van de hele boom (zie
/// `training-model-v2-unified-group.md` §4): `parentPath.length +
/// subtreeHeight(node) <= 3`. Gooit [TrainingPathError] als [parentPath]
/// niet naar een bestaande groep wijst (onzinnig pad, geen "nee").
bool canInsert(TrainingNode node, TrainingPath parentPath, Training tree) {
  if (parentPath.isNotEmpty) {
    _asGroup(nodeAt(tree, parentPath));
  }
  return parentPath.length + subtreeHeight(node) <= 3;
}

/// Verplaatst de knoop op [from] naar positie [toIndex] in de kinderlijst
/// aangeduid door [toParent] (zie [insertAt]). [toIndex] is de gewenste
/// eindpositie in de resulterende lijst — de aanroeper is verantwoordelijk
/// voor het eventueel corrigeren daarvan (bijv. bij het herordenen binnen
/// dezelfde lijst); [toParent] zelf wordt hier wél automatisch
/// gecorrigeerd wanneer het naar een index in dezelfde lijst als [from]
/// wijst (zie [_adjustPathAfterRemoval]).
///
/// In tegenstelling tot v1 is dit nu een generieke, diepte-onafhankelijke
/// operatie: geldigheid wordt volledig bepaald door [canInsert], niet meer
/// door een `from.length - 1 == toParent.length`-restrictie. Dat is precies
/// wat "Oefeningen/Subsets moeten tussen de niveaus verplaatst kunnen
/// worden" mogelijk maakt.
Training moveNode(
  Training training,
  TrainingPath from,
  TrainingPath toParent,
  int toIndex,
) {
  if (_isDescendantOrSelf(toParent, from)) {
    throw TrainingInvalidMoveException(
      nodeAt(training, from),
      toParent,
      'Cannot move an item into itself',
    );
  }

  final node = nodeAt(training, from);
  if (!canInsert(node, toParent, training)) {
    throw TrainingInvalidMoveException(
      node,
      toParent,
      'This item cannot go here (it would exceed the maximum depth '
      'of 3)',
    );
  }

  final removed = removeAt(training, from);
  final adjustedToParent = _adjustPathAfterRemoval(toParent, from);
  return insertAt(removed, adjustedToParent, toIndex, node);
}

/// Groepeert de knoop op [sourcePath] met de knoop op [targetPath] — deze
/// hoeven niet in dezelfde kinderlijst te zitten (bijv. een losse
/// root-oefening op een oefening die al ergens genest zit): de enige
/// structurele eis is dat de een niet de voorouder-of-zichzelf van de ander
/// is (anders zou de onderliggende `removeAt` [targetPath] zelf verwijderen,
/// of een stale kopie van [targetPath]'s groep gebruiken). Twee symmetrische
/// gevallen (zie §6 van het ontwerpdocument):
///
/// - Oefening op oefening: wikkelt beide in een nieuwe [TrainingGroup] op
///   de plek van [targetPath] — hoogte-gevalideerd via [canInsert] tegen
///   [targetPath]'s eigen ouder-lijst, dus nu correct afgewezen op diepte 3
///   in plaats van v1's hardgecodeerde "niet ondersteund".
/// - Kale groep op groep: [sourcePath]'s groep wordt een kind van
///   [targetPath]'s groep, mits [canInsert] slaagt (dit is de "kale Set
///   wordt Subset"-conversie).
Training groupWithTarget(
  Training training,
  TrainingPath sourcePath,
  TrainingPath targetPath, {
  required String Function() newId,
}) {
  if (sourcePath.isEmpty || targetPath.isEmpty) {
    throw TrainingPathError('source/target mogen niet leeg zijn');
  }
  if (_pathEquals(sourcePath, targetPath)) {
    throw TrainingPathError('kan niet groeperen met zichzelf');
  }
  if (_isDescendantOrSelf(targetPath, sourcePath) ||
      _isDescendantOrSelf(sourcePath, targetPath)) {
    throw TrainingInvalidMoveException(
      nodeAt(training, sourcePath),
      targetPath,
      'Cannot group an item with its own parent or child',
    );
  }

  final sourceNode = nodeAt(training, sourcePath);
  final targetNode = nodeAt(training, targetPath);
  final targetParent = targetPath.sublist(0, targetPath.length - 1);

  if (sourceNode is TrainingNodeExercise && targetNode is TrainingNodeExercise) {
    return _wrapIntoNewGroup(
      training,
      sourcePath,
      targetPath,
      targetParent,
      sourceExercise: sourceNode.exercise,
      targetExercise: targetNode.exercise,
      newId: newId,
    );
  }

  if (sourceNode is TrainingNodeGroup && targetNode is TrainingNodeGroup) {
    return _mergeGroupIntoTarget(
      training,
      sourcePath,
      targetPath,
      sourceNode: sourceNode,
      targetGroup: targetNode.group,
    );
  }

  throw TrainingPathError(
    'groeperen ondersteunt alleen oefening-op-oefening of groep-op-groep',
  );
}

/// Bouwt de nieuwe groep op de plek van [targetPath] — [targetParent] (niet
/// [sourcePath]'s ouder, die kan intussen een heel andere lijst zijn) is
/// dus de lijst waar [canInsert] tegen valideert.
Training _wrapIntoNewGroup(
  Training training,
  TrainingPath sourcePath,
  TrainingPath targetPath,
  TrainingPath targetParent, {
  required TrainingExercise sourceExercise,
  required TrainingExercise targetExercise,
  required String Function() newId,
}) {
  final newGroup = TrainingNode.group(
    group: TrainingGroup(
      id: newId(),
      title: targetExercise.title,
      children: [
        TrainingNode.exercise(exercise: targetExercise),
        TrainingNode.exercise(exercise: sourceExercise),
      ],
    ),
  );
  if (!canInsert(newGroup, targetParent, training)) {
    throw TrainingInvalidMoveException(
      newGroup,
      targetParent,
      'A new group cannot go here (it would exceed the maximum depth '
      'of 3)',
    );
  }

  final updated = removeAt(training, sourcePath);
  final adjustedTargetPath = _adjustPathAfterRemoval(targetPath, sourcePath);
  return replaceAt(updated, adjustedTargetPath, newGroup);
}

/// [targetGroup] is hier veilig om vóór de verwijdering vast te leggen: de
/// ancestor-guards in [groupWithTarget] sluiten uit dat [sourcePath] ergens
/// in [targetPath]'s eigen subboom zit, dus [removeAt] hieronder kan
/// [targetGroup]'s kinderlijst nooit stiekem veranderen.
Training _mergeGroupIntoTarget(
  Training training,
  TrainingPath sourcePath,
  TrainingPath targetPath, {
  required TrainingNodeGroup sourceNode,
  required TrainingGroup targetGroup,
}) {
  if (!canInsert(sourceNode, targetPath, training)) {
    throw TrainingInvalidMoveException(
      sourceNode,
      targetPath,
      'This group does not fit here (it would exceed the maximum depth of 3)',
    );
  }

  final updated = removeAt(training, sourcePath);
  final adjustedTargetPath = _adjustPathAfterRemoval(targetPath, sourcePath);
  final mergedGroup = targetGroup.copyWith(
    children: [...targetGroup.children, sourceNode],
  );
  return replaceAt(
    updated,
    adjustedTargetPath,
    TrainingNode.group(group: mergedGroup),
  );
}

T _at<T>(List<T> list, int index, String level) {
  if (index < 0 || index >= list.length) {
    throw TrainingPathError(
      'index $index buiten bereik op $level-niveau (${list.length} kinderen)',
    );
  }
  return list[index];
}

List<T> _replaceIndex<T>(List<T> list, int index, T value) {
  final copy = List<T>.of(list);
  copy[index] = value;
  return copy;
}

bool _pathEquals(TrainingPath a, TrainingPath b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Of [maybeDescendant] gelijk is aan [ancestor] of daar binnen ligt —
/// gebruikt om te voorkomen dat [moveNode] een knoop naar zijn eigen
/// (voormalige) subboom verplaatst, wat na de onderliggende `removeAt` een
/// pad zou opleveren dat niet meer bestaat, of erger, per ongeluk een
/// heel andere knoop zou raken die toevallig op dezelfde index terecht is
/// gekomen.
bool _isDescendantOrSelf(TrainingPath maybeDescendant, TrainingPath ancestor) {
  if (maybeDescendant.length < ancestor.length) return false;
  for (var i = 0; i < ancestor.length; i++) {
    if (maybeDescendant[i] != ancestor[i]) return false;
  }
  return true;
}

/// Corrigeert [path] voor de index-verschuiving die het verwijderen van de
/// knoop op [removedFrom] veroorzaakt in *diens eigen* kinderlijst. Als
/// [path] niet door diezelfde lijst loopt, blijft het ongewijzigd. Dit is
/// wat een generieke cross-parent [moveNode]/groepeer-bewerking correct
/// houdt: v1 kon dit negeren omdat verplaatsen daar altijd binnen dezelfde
/// lijst gebeurde (de aanroeper corrigeerde de index zelf), maar zodra
/// [toParent] een ándere lijst kan aanduiden dan die van [removedFrom],
/// kan een naïeve `removeAt` + `insertAt` een pad naar de verkeerde knoop
/// laten wijzen.
TrainingPath _adjustPathAfterRemoval(
  TrainingPath path,
  TrainingPath removedFrom,
) {
  final removedParent = removedFrom.sublist(0, removedFrom.length - 1);
  final removedIndex = removedFrom.last;

  if (path.length <= removedParent.length) return path;
  for (var i = 0; i < removedParent.length; i++) {
    if (path[i] != removedParent[i]) return path;
  }

  final adjusted = List<int>.of(path);
  if (adjusted[removedParent.length] > removedIndex) {
    adjusted[removedParent.length] -= 1;
  }
  return adjusted;
}

TrainingGroup _asGroup(TrainingNode node) => switch (node) {
  TrainingNodeGroup(:final group) => group,
  _ => throw TrainingPathError('knoop is geen TrainingGroup'),
};
