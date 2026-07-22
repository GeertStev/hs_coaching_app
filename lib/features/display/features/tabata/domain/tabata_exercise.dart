import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tabata_exercise.freezed.dart';
part 'tabata_exercise.g.dart';

/// Eén oefening (kaart in de editor): [rounds] werkrondes van [workSeconds]
/// met [restSeconds] rust ertussen (geen rust na de laatste ronde).
///
/// [stepSeconds] maakt elke volgende werkronde langer of korter dan de vorige:
/// negatief = korter (beeptest), positief = langer. Zie [workSecondsForRound].
///
/// [restAfter] is de rust ná deze oefening, vóór de volgende (sibling) kaart.
/// Wordt genegeerd wanneer dit de laatste kaart in zijn lijst is (top-level of
/// binnen een groep) — zie [TabataGroup]/[Tabata.items].
///
/// [id] is een stabiele sleutel (uuid) voor slepen/herordenen in de editor;
/// altijd expliciet meegeven (zie [newTabataExercise]).
@freezed
abstract class TabataExercise with _$TabataExercise {
  const TabataExercise._();

  const factory TabataExercise({
    required String id,
    @Default('') String title,
    @Default(20) int workSeconds,
    @Default(10) int restSeconds,
    @Default(8) int rounds,
    @Default(0) int stepSeconds,
    @Default(0) int restAfter,
  }) = _TabataExercise;

  factory TabataExercise.fromJson(Map<String, dynamic> json) =>
      _$TabataExerciseFromJson(json);

  /// Duur van werkronde [round] (1-gebaseerd), met de stap-aftrek/optelling
  /// toegepast en geklemd op minimaal 1 seconde.
  int workSecondsForRound(int round) {
    if (workSeconds <= 0) return 0;
    return math.max(workSeconds + (round - 1) * stepSeconds, 1);
  }

  /// Duur van deze oefening (zonder [restAfter]) — voor kaart-samenvattingen
  /// in de editor/lijst. Niet gebruikt door [Tabata.progressAt], die werkt op
  /// de volledige tijdlijn.
  int get durationMillis {
    if (rounds <= 0) return 0;
    var workTotal = 0;
    for (var round = 1; round <= rounds; round++) {
      workTotal += workSecondsForRound(round);
    }
    return (workTotal + (rounds - 1) * restSeconds) * 1000;
  }
}

/// Nieuwe lege oefening met een verse id (voor "+"-knoppen in de editor).
TabataExercise newTabataExercise({String title = ''}) {
  return TabataExercise(id: const Uuid().v4(), title: title);
}
