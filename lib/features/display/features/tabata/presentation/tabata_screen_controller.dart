import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_provider.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_progress.dart';

/// Vertaalt de gesynchroniseerde [Tabata] state naar een lokaal tikkende
/// [TabataProgress], volgens hetzelfde RTDB-klokdrift-principe als
/// `ChronoScreenController`.
class TabataScreenController extends Notifier<TabataProgress> {
  Timer? _timer;
  int? _lastTickSecond;
  TabataPhase? _lastTickPhase;

  @override
  TabataProgress build() {
    final tabataAsync = ref.watch(tabataNotifierProvider);
    final tabata = tabataAsync.value ?? const Tabata();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() {
      _timer?.cancel();
    });

    _timer?.cancel();

    if (tabata.status == TabataStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        final progress = _calculateProgress(tabata, currentOffset);
        if (progress.phase == TabataPhase.finished) {
          _timer?.cancel();
        }
        state = progress;
      });
    }

    return _calculateProgress(tabata, offsetMillis);
  }

  TabataProgress _calculateProgress(Tabata tabata, double offsetMillis) {
    var elapsedMillis = tabata.accumulatedElapsedMillis;
    if (tabata.status == TabataStatus.running) {
      elapsedMillis += serverNowMillis(offsetMillis) - tabata.authoritativeStartTimeMillis;
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
