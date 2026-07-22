import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';

part 'tabata.freezed.dart';
part 'tabata.g.dart';

enum TabataStatus { stopped, running, paused }

/// Tabata-interval timer: voorbereiding gevolgd door één of meer [TabataItem]s
/// (losse oefeningen of groepen oefeningen) die na elkaar worden afgewerkt.
/// De sessie eindigt na de laatste werkronde van de laatste oefening (geen
/// rust na de laatste kaart, geen rust na de laatste herhaling van een groep).
///
/// De runtime-synchronisatie werkt identiek aan [Chrono]:
/// de control app schrijft alleen start/pauze/reset-events; de verstreken
/// tijd (en daarmee kaart, fase en ronde) wordt lokaal afgeleid via [progressAt].
@freezed
abstract class Tabata with _$Tabata {
  const Tabata._();

  @JsonSerializable(explicitToJson: true)
  const factory Tabata({
    // --- Configuratie ---
    @Default(10) int prepareSeconds,
    @Default([
      TabataItem.exercise(TabataExercise(id: 'default')),
    ])
    List<TabataItem> items,

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

  /// Totale duur van de sessie: voorbereiding + de volledig uitgewerkte
  /// tijdlijn van alle kaarten (inclusief rust, exclusief rust ná de laatste
  /// kaart).
  int get totalDurationMillis {
    var total = prepareSeconds * 1000;
    for (final step in _flatten(items)) {
      total += step.durationMillis;
    }
    return total;
  }

  /// Berekent kaart, fase, ronde en resterende tijden op [elapsedMillis]
  /// sinds de start van de voorbereiding.
  TabataProgress progressAt(int elapsedMillis) {
    final timeline = _flatten(items);
    final totalItems = items.length;
    final totalMs = totalDurationMillis;
    final hasWork = timeline.any((step) => step.phase == TabataPhase.work);
    final clampedElapsed = math.max(0, math.min(elapsedMillis, totalMs));

    // Defensief: zonder speelbare werkrondes is de sessie meteen klaar.
    if (!hasWork || timeline.isEmpty || clampedElapsed >= totalMs) {
      final lastStep = timeline.isEmpty ? null : timeline.last;
      return TabataProgress(
        phase: TabataPhase.finished,
        itemIndex: math.max(totalItems, 1),
        totalItems: totalItems,
        itemTitle: lastStep?.itemTitle ?? '',
        round: lastStep?.totalRounds ?? 0,
        totalRounds: lastStep?.totalRounds ?? 0,
        groupRepeat: lastStep?.groupRepeat,
        totalGroupRepeats: lastStep?.totalGroupRepeats,
        phaseRemaining: Duration.zero,
        phaseTotal: Duration.zero,
        elapsed: Duration(milliseconds: clampedElapsed),
        totalRemaining: Duration.zero,
      );
    }

    final elapsed = Duration(milliseconds: clampedElapsed);
    final totalRemaining = Duration(milliseconds: totalMs - clampedElapsed);

    TabataProgress progressFor(_TimelineStep step, int remainingMs) {
      return TabataProgress(
        phase: step.phase,
        itemIndex: step.itemIndex,
        totalItems: totalItems,
        itemTitle: step.itemTitle,
        round: step.round,
        totalRounds: step.totalRounds,
        groupRepeat: step.groupRepeat,
        totalGroupRepeats: step.totalGroupRepeats,
        phaseRemaining: Duration(milliseconds: remainingMs),
        phaseTotal: Duration(milliseconds: step.durationMillis),
        elapsed: elapsed,
        totalRemaining: totalRemaining,
      );
    }

    var t = clampedElapsed;

    final prepareMs = prepareSeconds * 1000;
    if (t < prepareMs) {
      return TabataProgress(
        phase: TabataPhase.prepare,
        itemIndex: 1,
        totalItems: totalItems,
        itemTitle: timeline.first.itemTitle,
        round: 1,
        totalRounds: timeline.first.totalRounds,
        groupRepeat: timeline.first.groupRepeat,
        totalGroupRepeats: timeline.first.totalGroupRepeats,
        phaseRemaining: Duration(milliseconds: prepareMs - t),
        phaseTotal: Duration(milliseconds: prepareMs),
        elapsed: elapsed,
        totalRemaining: totalRemaining,
      );
    }
    t -= prepareMs;

    // Wandel door de tijdlijn: elke stap is een werk- of rustfase.
    for (final step in timeline) {
      if (t < step.durationMillis) {
        return progressFor(step, step.durationMillis - t);
      }
      t -= step.durationMillis;
    }

    // Onbereikbaar zolang totalDurationMillis en de tijdlijn hierboven
    // consistent zijn; valt terug op de klaar-toestand.
    return progressAt(totalMs);
  }
}

/// Eén fase (werk of rust) in de plat geslagen tijdlijn van een [Tabata].
class _TimelineStep {
  const _TimelineStep({
    required this.phase,
    required this.durationMillis,
    this.itemIndex = 0,
    this.itemTitle = '',
    this.round = 0,
    this.totalRounds = 0,
    this.groupRepeat,
    this.totalGroupRepeats,
    this.contextFromNext = false,
  });

  final TabataPhase phase;
  final int durationMillis;
  final int itemIndex;
  final String itemTitle;
  final int round;
  final int totalRounds;
  final int? groupRepeat;
  final int? totalGroupRepeats;

  /// Rust-stappen tussen kaarten (top-level of tussen kinderen van een groep)
  /// dragen zelf geen zinvolle ronde/titel-context; die wordt achteraf
  /// overgenomen van de eerstvolgende "echte" stap, zodat het scherm al
  /// toont waarvoor er gerust wordt (zelfde principe als de vroegere
  /// setRest-aanpak op sets-niveau).
  final bool contextFromNext;

  _TimelineStep withContextOf(_TimelineStep other) => _TimelineStep(
    phase: phase,
    durationMillis: durationMillis,
    itemIndex: other.itemIndex,
    itemTitle: other.itemTitle,
    round: other.round,
    totalRounds: other.totalRounds,
    groupRepeat: other.groupRepeat,
    totalGroupRepeats: other.totalGroupRepeats,
  );
}

/// Slaat [items] plat naar een lineaire lijst van werk/rust-stappen: rondes
/// van elke oefening, rust tussen kinderen van een groep, rust tussen
/// herhalingen van een groep, en rust tussen top-level kaarten.
List<_TimelineStep> _flatten(List<TabataItem> items) {
  final steps = <_TimelineStep>[];

  void appendExercise(
    TabataExercise exercise, {
    required int itemIndex,
    required int? groupRepeat,
    required int? totalGroupRepeats,
  }) {
    for (var round = 1; round <= exercise.rounds; round++) {
      steps.add(
        _TimelineStep(
          phase: TabataPhase.work,
          durationMillis: exercise.workSecondsForRound(round) * 1000,
          itemIndex: itemIndex,
          itemTitle: exercise.title,
          round: round,
          totalRounds: exercise.rounds,
          groupRepeat: groupRepeat,
          totalGroupRepeats: totalGroupRepeats,
        ),
      );
      if (round < exercise.rounds && exercise.restSeconds > 0) {
        steps.add(
          _TimelineStep(
            phase: TabataPhase.rest,
            durationMillis: exercise.restSeconds * 1000,
            itemIndex: itemIndex,
            itemTitle: exercise.title,
            round: round,
            totalRounds: exercise.rounds,
            groupRepeat: groupRepeat,
            totalGroupRepeats: totalGroupRepeats,
          ),
        );
      }
    }
  }

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    switch (item) {
      case TabataItemExercise(:final exercise):
        appendExercise(
          exercise,
          itemIndex: i + 1,
          groupRepeat: null,
          totalGroupRepeats: null,
        );
      case TabataItemGroup(:final group):
        for (var rep = 1; rep <= group.rounds; rep++) {
          for (var c = 0; c < group.children.length; c++) {
            final child = group.children[c];
            appendExercise(
              child,
              itemIndex: i + 1,
              groupRepeat: rep,
              totalGroupRepeats: group.rounds,
            );
            if (c < group.children.length - 1 && child.restAfter > 0) {
              steps.add(
                _TimelineStep(
                  phase: TabataPhase.setRest,
                  durationMillis: child.restAfter * 1000,
                  contextFromNext: true,
                ),
              );
            }
          }
          if (rep < group.rounds && group.restBetweenRepeats > 0) {
            steps.add(
              _TimelineStep(
                phase: TabataPhase.rest,
                durationMillis: group.restBetweenRepeats * 1000,
                contextFromNext: true,
              ),
            );
          }
        }
    }

    if (i < items.length - 1 && item.restAfter > 0) {
      steps.add(
        _TimelineStep(
          phase: TabataPhase.setRest,
          durationMillis: item.restAfter * 1000,
          contextFromNext: true,
        ),
      );
    }
  }

  // Vul de context van rust-stappen tussen kaarten achteraf in (zie
  // [_TimelineStep.contextFromNext]).
  _TimelineStep? followingContext;
  final resolved = <_TimelineStep>[];
  for (var i = steps.length - 1; i >= 0; i--) {
    final step = steps[i];
    if (step.contextFromNext) {
      resolved.add(step.withContextOf(followingContext!));
    } else {
      resolved.add(step);
      followingContext = step;
    }
  }
  return resolved.reversed.toList();
}
