import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';

part 'tabata.freezed.dart';
part 'tabata.g.dart';

enum TabataStatus { stopped, running, paused }

/// Tabata-interval timer: voorbereiding gevolgd door één of meer [TabataSet]s
/// die na elkaar worden afgewerkt, met [TabataSet.setRestSeconds] rust tussen
/// de sets. De sessie eindigt na de laatste werkronde van de laatste set
/// (geen rust na de laatste ronde, geen setrust na de laatste set).
///
/// De runtime-synchronisatie werkt identiek aan [Chrono]:
/// de control app schrijft alleen start/pauze/reset-events; de verstreken
/// tijd (en daarmee set, fase en ronde) wordt lokaal afgeleid via [progressAt].
@freezed
abstract class Tabata with _$Tabata {
  const Tabata._();

  @JsonSerializable(explicitToJson: true)
  const factory Tabata({
    // --- Configuratie ---
    @Default(10) int prepareSeconds,
    @Default([TabataSet()]) List<TabataSet> sets,

    // --- Runtime status (zelfde mechanisme als Chrono) ---
    @Default(TabataStatus.stopped) TabataStatus status,

    /// The local timestamp from the control app when the button was pressed.
    @Default(0) int authoritativeStartTimeMillis,

    /// Firestore server timestamp of when the start event was written.
    @ServerTimestampConverter() Timestamp? serverWriteTimestamp,

    /// Time accumulated before the current running session.
    @Default(0) int accumulatedElapsedMillis,
  }) = _Tabata;

  factory Tabata.fromJson(Map<String, dynamic> json) => _$TabataFromJson(json);

  /// True zolang de timer nog nooit gestart (of net gereset) is.
  bool get isIdle =>
      status == TabataStatus.stopped && accumulatedElapsedMillis == 0;

  /// Totale duur van de sessie: voorbereiding + alle sets + de setrust tussen
  /// de sets (dus géén setrust na de laatste set).
  int get totalDurationMillis {
    var total = prepareSeconds * 1000;
    for (var i = 0; i < sets.length; i++) {
      total += sets[i].durationMillis;
      if (i < sets.length - 1) total += sets[i].setRestSeconds * 1000;
    }
    return total;
  }

  /// Berekent set, fase, ronde en resterende tijden op [elapsedMillis] sinds
  /// de start van de voorbereiding.
  TabataProgress progressAt(int elapsedMillis) {
    final totalMs = totalDurationMillis;
    final totalSets = sets.length;
    final hasWork = sets.any((s) => s.rounds > 0 && s.workSeconds > 0);
    final clampedElapsed = math.max(0, math.min(elapsedMillis, totalMs));

    // Defensief: zonder speelbare werkrondes is de sessie meteen klaar.
    if (!hasWork || clampedElapsed >= totalMs) {
      final lastSet = sets.isEmpty ? const TabataSet(rounds: 0) : sets.last;
      return TabataProgress(
        phase: TabataPhase.finished,
        setIndex: math.max(totalSets, 1),
        totalSets: totalSets,
        setTitle: lastSet.title,
        round: lastSet.rounds,
        totalRounds: lastSet.rounds,
        phaseRemaining: Duration.zero,
        phaseTotal: Duration.zero,
        elapsed: Duration(milliseconds: clampedElapsed),
        totalRemaining: Duration.zero,
      );
    }

    final elapsed = Duration(milliseconds: clampedElapsed);
    final totalRemaining = Duration(milliseconds: totalMs - clampedElapsed);

    TabataProgress progress({
      required TabataPhase phase,
      required int setIndex,
      required TabataSet set,
      required int round,
      required int remainingMs,
      required int phaseMs,
    }) {
      return TabataProgress(
        phase: phase,
        setIndex: setIndex,
        totalSets: totalSets,
        setTitle: set.title,
        round: round,
        totalRounds: set.rounds,
        phaseRemaining: Duration(milliseconds: remainingMs),
        phaseTotal: Duration(milliseconds: phaseMs),
        elapsed: elapsed,
        totalRemaining: totalRemaining,
      );
    }

    var t = clampedElapsed;

    final prepareMs = prepareSeconds * 1000;
    if (t < prepareMs) {
      return progress(
        phase: TabataPhase.prepare,
        setIndex: 1,
        set: sets.first,
        round: 1,
        remainingMs: prepareMs - t,
        phaseMs: prepareMs,
      );
    }
    t -= prepareMs;

    // Wandel door de tijdlijn: per set alle werk/rust-rondes, gevolgd door de
    // setrust (behalve na de laatste set).
    for (var i = 0; i < totalSets; i++) {
      final set = sets[i];
      for (var round = 1; round <= set.rounds; round++) {
        final workMs = set.workSecondsForRound(round) * 1000;
        if (t < workMs) {
          return progress(
            phase: TabataPhase.work,
            setIndex: i + 1,
            set: set,
            round: round,
            remainingMs: workMs - t,
            phaseMs: workMs,
          );
        }
        t -= workMs;
        if (round < set.rounds) {
          final restMs = set.restSeconds * 1000;
          if (t < restMs) {
            return progress(
              phase: TabataPhase.rest,
              setIndex: i + 1,
              set: set,
              round: round,
              remainingMs: restMs - t,
              phaseMs: restMs,
            );
          }
          t -= restMs;
        }
      }
      if (i < totalSets - 1) {
        final setRestMs = set.setRestSeconds * 1000;
        if (t < setRestMs) {
          // De setrust hoort visueel bij de vólgende set: het scherm toont
          // dan al waarvoor er gerust wordt.
          return progress(
            phase: TabataPhase.setRest,
            setIndex: i + 2,
            set: sets[i + 1],
            round: 1,
            remainingMs: setRestMs - t,
            phaseMs: setRestMs,
          );
        }
        t -= setRestMs;
      }
    }

    // Onbereikbaar zolang totalDurationMillis en de wandeling hierboven
    // consistent zijn; valt terug op de klaar-toestand.
    return progressAt(totalMs);
  }
}
