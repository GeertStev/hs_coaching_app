import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_tree.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Uitkomst van [applyTrainingMove]/[applyTrainingMerge] — de aanroepende
/// widget (die de `BuildContext` heeft) beslist wat ermee te doen: een
/// undo-snackbar tonen bij [TrainingMutationApplied], of niets (de
/// drag-target zelf toont al een afwijzingsbericht via `canAccept`, zie
/// `training_drag_drop.dart`) bij [TrainingMutationRejected].
sealed class TrainingMutationResult {}

class TrainingMutationApplied extends TrainingMutationResult {
  TrainingMutationApplied(this.previous);
  final Training previous;
}

class TrainingMutationRejected extends TrainingMutationResult {
  TrainingMutationRejected(this.reason);
  final String reason;
}

/// Of de knoop op [source] verplaatst mag worden naar de kinderlijst
/// aangeduid door [parentPath] — gebruikt door `TrainingInsertGap`s
/// `canAccept`. Voert `moveNode` daadwerkelijk (zuiver, geen bijwerkingen)
/// uit tegen de huidige boom en vangt de afwijzing op, in plaats van de
/// validatieregels hier te dupliceren: zo blijft dit altijd in lockstap
/// met wat [applyTrainingMove] verderop echt zou doen, inclusief de
/// eigen-subboom-bescherming die een losse `canInsert`-aanroep zou missen.
bool canMoveInto(WidgetRef ref, TrainingPath source, TrainingPath parentPath) {
  final tree = ref.read(trainingNotifierProvider).requireValue;
  try {
    moveNode(tree, source, parentPath, 0);
    return true;
  } on TrainingPathError {
    return false;
  } on TrainingInvalidMoveException {
    return false;
  }
}

/// Zelfde principe als [canMoveInto], maar voor `TrainingGroupTarget`s
/// laat-hier-los-om-te-groeperen-gebaar (`groupWithTarget`).
bool canGroupWithTarget(
  WidgetRef ref,
  TrainingPath source,
  TrainingPath target,
) {
  final tree = ref.read(trainingNotifierProvider).requireValue;
  try {
    groupWithTarget(tree, source, target, newId: () => '');
    return true;
  } on TrainingPathError {
    return false;
  } on TrainingInvalidMoveException {
    return false;
  }
}

/// Voert een verplaatsing (`moveNode`) daadwerkelijk uit en bewaart het
/// resultaat via `saveWithUndo`. Verwacht dat de aanroeper al [canMoveInto]
/// gebruikte om het sleepdoel te gaten — een afwijzing hier is dus vooral
/// een defensieve tweede laag (bijv. verouderde sleeplast omdat de boom
/// intussen elders gewijzigd is), niet het primaire pad.
Future<TrainingMutationResult> applyTrainingMove(
  WidgetRef ref, {
  required TrainingPath from,
  required TrainingPath toParent,
  required int toIndex,
}) async {
  final current = ref.read(trainingNotifierProvider).requireValue;
  final Training next;
  try {
    next = moveNode(current, from, toParent, toIndex);
  } on TrainingInvalidMoveException catch (e) {
    return TrainingMutationRejected(e.reason);
  } on TrainingPathError {
    return TrainingMutationRejected('Dit slepen is niet meer geldig.');
  }

  await ref
      .read(trainingCommandsProvider)
      .saveWithUndo(previous: current, next: next);
  return TrainingMutationApplied(current);
}

/// Voert een groepering (`groupWithTarget`) daadwerkelijk uit en bewaart
/// het resultaat via `saveWithUndo`. Zie [applyTrainingMove] voor de
/// verwachte aanroepvolgorde (eerst [canGroupWithTarget]).
Future<TrainingMutationResult> applyTrainingMerge(
  WidgetRef ref, {
  required TrainingPath source,
  required TrainingPath target,
}) async {
  final current = ref.read(trainingNotifierProvider).requireValue;
  final Training next;
  try {
    next = groupWithTarget(current, source, target, newId: () => _uuid.v4());
  } on TrainingInvalidMoveException catch (e) {
    return TrainingMutationRejected(e.reason);
  } on TrainingPathError {
    return TrainingMutationRejected('Dit slepen is niet meer geldig.');
  }

  await ref
      .read(trainingCommandsProvider)
      .saveWithUndo(previous: current, next: next);
  return TrainingMutationApplied(current);
}
