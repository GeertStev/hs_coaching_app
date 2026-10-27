import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_exercise_group.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:uuid/uuid.dart';

/// Editor-gemak: nieuwe kaarten met een vers `uuid`-id. App-only, net als
/// Tabata's oude `tabata_factories.dart` — `hs_coaching_core` en
/// `hs_coaching_screen` hebben geen `uuid`-afhankelijkheid en hoeven ook
/// nooit nieuwe kaarten aan te maken (alleen te lezen).
const _uuid = Uuid();

TrainingParameterRow newTrainingParameterRow() {
  return TrainingParameterRow(id: _uuid.v4());
}

/// Een oefening heeft altijd minstens 1 parameter-rij (zie
/// `training_exercise_card.dart`'s `_ParameterRowPills` — de laatste rij kan
/// niet weggehaald worden), dus start hier al met één (lege) rij in plaats
/// van een lege lijst.
TrainingExerciseGroup newTrainingExerciseGroup() {
  return TrainingExerciseGroup(
    id: _uuid.v4(),
    parameterRows: [newTrainingParameterRow()],
  );
}

TrainingExercise newTrainingExercise({String title = 'New exercise'}) {
  return TrainingExercise(
    id: _uuid.v4(),
    title: title,
    groups: [newTrainingExerciseGroup()],
  );
}

/// Vervangt v1's `newTrainingSet`/`newTrainingSubset` — "Set" en "Subset"
/// zijn nu positionele labels van hetzelfde type, geen aparte factories
/// meer nodig. Altijd met één voorgevulde oefening (hoogte 2, nooit 1):
/// een lege groep zou volgens de zuivere hoogte-formule op elk niveau
/// ingevoegd mogen worden (hoogte 1, net als een oefening) maar daarna
/// nooit meer een kind kunnen krijgen op diepte 3 — dat vermijden we hier
/// in de praktijk in plaats van de formule zelf uit te zonderen.
TrainingGroup newTrainingGroup({String title = 'New set'}) {
  return TrainingGroup(
    id: _uuid.v4(),
    title: title,
    children: [TrainingNode.exercise(exercise: newTrainingExercise())],
  );
}
