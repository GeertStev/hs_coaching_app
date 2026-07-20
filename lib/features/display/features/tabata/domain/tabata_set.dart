import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tabata_set.freezed.dart';
part 'tabata_set.g.dart';

/// Eén tabata-set: [rounds] werkrondes met [restSeconds] rust ertussen
/// (geen rust na de laatste ronde). Met [workDecrementSeconds] > 0 wordt
/// elke werkronde korter dan de vorige (beeptest).
@freezed
abstract class TabataSet with _$TabataSet {
  const TabataSet._();

  const factory TabataSet({
    /// Titel van de set (bv. "Onderwaters" of "Half onder half boven").
    @Default('') String title,
    @Default(20) int workSeconds,
    @Default(10) int restSeconds,
    @Default(8) int rounds,

    /// Beeptest: elke werkronde duurt zoveel seconden korter dan de vorige.
    @Default(0) int workDecrementSeconds,

    /// Rust ná deze set, vóór de volgende set. Genegeerd bij de laatste set.
    @Default(60) int setRestSeconds,
  }) = _TabataSet;

  factory TabataSet.fromJson(Map<String, dynamic> json) =>
      _$TabataSetFromJson(json);

  /// Duur van werkronde [round] (1-gebaseerd), met de beeptest-aftrek
  /// toegepast en geklemd op minimaal 1 seconde.
  int workSecondsForRound(int round) {
    if (workSeconds <= 0) return 0;
    return math.max(workSeconds - (round - 1) * workDecrementSeconds, 1);
  }

  /// Totale duur van deze set (zonder de rust ná de set).
  int get durationMillis {
    if (rounds <= 0) return 0;
    var workTotal = 0;
    for (var round = 1; round <= rounds; round++) {
      workTotal += workSecondsForRound(round);
    }
    return (workTotal + (rounds - 1) * restSeconds) * 1000;
  }
}
