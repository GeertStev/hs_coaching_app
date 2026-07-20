import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_provider.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_progress.dart';

/// Vertaalt de gesynchroniseerde [Tabata] state naar een lokaal tikkende
/// [TabataProgress], naar het voorbeeld van [ChronoScreenController].
class TabataScreenController extends Notifier<TabataProgress> {
  Timer? _timer;
  int? _lastTickSecond;
  TabataPhase? _lastTickPhase;

  @override
  TabataProgress build() {
    final tabataAsync = ref.watch(tabataNotifierProvider);
    final tabata = tabataAsync.value ?? const Tabata();

    ref.onDispose(() {
      _timer?.cancel();
    });

    _timer?.cancel();

    if (tabata.status == TabataStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final progress = _calculateProgress(tabata);
        if (progress.phase == TabataPhase.finished) {
          _timer?.cancel();
        }
        state = progress;
      });
    }

    return _calculateProgress(tabata);
  }

  TabataProgress _calculateProgress(Tabata tabata) {
    var elapsedMillis = tabata.accumulatedElapsedMillis;
    if (tabata.status == TabataStatus.running) {
      elapsedMillis +=
          DateTime.now().millisecondsSinceEpoch -
          tabata.authoritativeStartTimeMillis;
    }

    final progress = tabata.progressAt(elapsedMillis);

    if (tabata.status == TabataStatus.running) {
      _playTickSounds(progress);
    }

    return progress;
  }

  /// Tik-geluid in de laatste 3 seconden van elke fase, zodat de spelers de
  /// wissel horen aankomen.
  void _playTickSounds(TabataProgress progress) {
    if (progress.phase == TabataPhase.finished) return;

    final secondsLeft = (progress.phaseRemaining.inMilliseconds / 1000).ceil();
    if (secondsLeft <= 3 &&
        (secondsLeft != _lastTickSecond || progress.phase != _lastTickPhase)) {
      SystemSound.play(SystemSoundType.click);
    }
    _lastTickSecond = secondsLeft;
    _lastTickPhase = progress.phase;
  }
}

final tabataScreenControllerProvider =
    NotifierProvider<TabataScreenController, TabataProgress>(
      TabataScreenController.new,
    );
