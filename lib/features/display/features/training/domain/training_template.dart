import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';

/// Of een template een groep (Set/Subset — zelfde type, zie
/// `training_node.dart`) of een losse oefening bevat — bepaalt hoe
/// `payload` gedeserialiseerd wordt (zie [TrainingTemplate.toNode]).
enum TrainingTemplateKind { group, exercise }

/// Een opgeslagen groep- of oefening-kaart uit de club-bibliotheek
/// (`clubs/{clubId}/trainingTemplates/{id}`), app-only — geen live
/// Firestore-document zoals `Training` zelf, dus geen `@freezed`-model in
/// `hs_coaching_core` nodig.
class TrainingTemplate {
  const TrainingTemplate({
    required this.id,
    required this.title,
    required this.kind,
    required this.payload,
    required this.height,
    this.tags = const [],
  });

  final String id;
  final String title;
  final TrainingTemplateKind kind;

  /// Rauwe `toJson()`-output van de opgeslagen kaart; zie [toNode] om terug
  /// naar het echte modeltype te gaan.
  final Map<String, dynamic> payload;

  /// `subtreeHeight` van de opgeslagen knoop, berekend en opgeslagen op het
  /// moment van bewaren — zodat de open-template-picker kandidaten kan
  /// filteren op `parentLevel + height <= 3` zonder elke kandidaat eerst te
  /// moeten deserialiseren (zie `training-model-v2-unified-group.md` §7).
  final int height;

  /// Vrije tags om de bibliotheek te filteren (bv. "Warm-up", "Apnea").
  final List<String> tags;

  /// Deserialiseert [payload] naar het modeltype dat bij [kind] hoort, en
  /// wikkelt het in een [TrainingNode] zodat het direct in de boom
  /// ingevoegd kan worden.
  TrainingNode toNode() {
    return switch (kind) {
      TrainingTemplateKind.group => TrainingNode.group(
        group: TrainingGroup.fromJson(payload),
      ),
      TrainingTemplateKind.exercise => TrainingNode.exercise(
        exercise: TrainingExercise.fromJson(payload),
      ),
    };
  }
}
