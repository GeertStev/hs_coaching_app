import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_navigation.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_provider.dart';

/// Vertaalt de gesynchroniseerde [Training] state naar een lokaal tikkende
/// [TrainingSessionProgress], zelfde RTDB-klokdrift-principe als
/// `TabataScreenController`. Twee dingen maken dit anders dan Tabata:
///
/// 1. **Alleen tikken op een getimede stap.** Zolang de huidige stap
///    ongetimed is (`TrainingStep.isTimed == false`), draait er geen
///    `Timer.periodic` — de sessie wacht stil op een handmatige `next` (zie
///    `training.dart`'s doc comment).
/// 2. **Auto-advance schrijft zelf naar Firestore.** Zodra een getimede stap
///    afloopt terwijl de sessie op `running` staat
///    (`TrainingSessionProgress.autoAdvanceDue`), roept deze controller zelf
///    `trainingCommandsProvider.next(...)` aan — in tegenstelling tot Tabata
///    (dat nooit tussentijds schrijft, alles is puur uit verstreken tijd
///    afgeleid) kan Training's positie niet zuiver afgeleid worden, dus iets
///    moet de pointer daadwerkelijk verzetten.
///
/// [_maybeAutoAdvance] wordt zowel direct in [build] als in elke tik
/// aangeroepen. Dat is bewust: het levert de "inhaal-logica" voor gratis op
/// als de coach het scherm een tijd gesloten had terwijl de sessie
/// doorliep — de eerste [build] na het heropenen ziet meteen dat de huidige
/// stap allang voorbij is, schrijft `next`, wat een nieuwe [build] triggert
/// (de stream levert de nieuwe `Training` op), die op zijn beurt opnieuw
/// controleert — net zo lang tot de sessie de daadwerkelijk actuele stap
/// heeft ingehaald. Geen aparte catch-up-lus nodig.
class TrainingScreenController extends Notifier<TrainingSessionProgress> {
  Timer? _timer;

  // Guard tegen dubbele `next()`-writes: tick-interval en Firestore-
  // round-trip lopen niet synchroon, dus zonder deze guard zou zowel de
  // directe aanroep in [build] als een volgende tik vóór de write is
  // aangekomen allebei `next()` kunnen vuren voor dezelfde stap.
  TrainingPathKey? _autoAdvancedFor;

  @override
  TrainingSessionProgress build() {
    final trainingAsync = ref.watch(trainingNotifierProvider);
    final training = trainingAsync.value ?? const Training();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    final steps = flattenTraining(training);
    final pointer = pointerFor(
      steps,
      path: training.currentPath,
      groupIndex: training.currentGroupIndex,
      phase: training.currentPhase,
    );

    final progress = computeTrainingProgress(
      steps: steps,
      status: training.status,
      pointer: pointer,
      elapsedInStepMillis: _elapsedInStepMillis(training, offsetMillis),
    );

    _maybeAutoAdvance(training, progress);

    if (training.status == TrainingStatus.running &&
        progress.currentStep?.isTimed == true) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        final tickProgress = computeTrainingProgress(
          steps: steps,
          status: training.status,
          pointer: pointer,
          elapsedInStepMillis: _elapsedInStepMillis(training, currentOffset),
        );
        state = tickProgress;
        _maybeAutoAdvance(training, tickProgress);
        if (tickProgress.isFinished || tickProgress.autoAdvanceDue) {
          // Wacht op de [build] die de write hierboven veroorzaakt in
          // plaats van door te tikken op een stap die al voorbij is.
          _timer?.cancel();
        }
      });
    }

    return progress;
  }

  int _elapsedInStepMillis(Training training, double offsetMillis) {
    var elapsed = training.accumulatedElapsedMillis;
    if (training.status == TrainingStatus.running) {
      elapsed +=
          serverNowMillis(offsetMillis) - training.authoritativeStartTimeMillis;
    }
    return elapsed;
  }

  void _maybeAutoAdvance(Training training, TrainingSessionProgress progress) {
    if (!progress.autoAdvanceDue) return;

    final key = TrainingPathKey(
      training.currentPath,
      training.currentGroupIndex,
      training.currentPhase,
    );
    if (_autoAdvancedFor == key) return;
    _autoAdvancedFor = key;

    unawaited(ref.read(trainingCommandsProvider).next(training));
  }
}

/// Waarde-vergelijkbare sleutel voor `Training.currentPath`/
/// `currentGroupIndex`/`currentPhase`, puur voor de auto-advance-guard
/// hierboven (`TrainingPath` is een `List<int>`, dat vergelijkt standaard op
/// identiteit, niet op inhoud).
class TrainingPathKey {
  const TrainingPathKey(this.path, this.groupIndex, this.phase);

  final List<int> path;
  final int groupIndex;
  final TrainingStepPhase phase;

  @override
  bool operator ==(Object other) {
    if (other is! TrainingPathKey) return false;
    if (groupIndex != other.groupIndex || phase != other.phase) return false;
    if (path.length != other.path.length) return false;
    for (var i = 0; i < path.length; i++) {
      if (path[i] != other.path[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(groupIndex, phase, Object.hashAll(path));
}

final trainingScreenControllerProvider =
    NotifierProvider<TrainingScreenController, TrainingSessionProgress>(
      TrainingScreenController.new,
    );
