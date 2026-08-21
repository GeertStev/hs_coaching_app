import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';

/// Zelfde klokdrift-correctie als `hs_coaching_screen`'s ChronoScreenController
/// (via [serverTimeOffsetProvider]), plus het tik-geluid tijdens de countdown
/// dat de coach-app hier al had.
class ChronoScreenController extends Notifier<Duration> {
  Timer? _timer;
  int? _lastCountdownSecond;

  @override
  Duration build() {
    final chronoAsync = ref.watch(chronoNotifierProvider);
    final chrono = chronoAsync.value ?? const Chrono();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() {
      _timer?.cancel();
    });

    _timer?.cancel();

    if (chrono.status == ChronoStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        state = _calculateElapsed(chrono, currentOffset);
      });
    }

    return _calculateElapsed(chrono, offsetMillis);
  }

  Duration _calculateElapsed(Chrono chrono, double offsetMillis) {
    int currentElapsedMillis = 0;

    if (chrono.status == ChronoStatus.running) {
      final now = serverNowMillis(offsetMillis);
      final startMillis = chrono.authoritativeStartTimeMillis;

      currentElapsedMillis = now - startMillis;

      // Als de tijd negatief is, zitten we in een countdown.
      if (currentElapsedMillis < 0) {
        final secondsLeft = (currentElapsedMillis.abs() / 1000).ceil();

        // Speel een tik-geluid af als de seconde wijzigt
        if (_lastCountdownSecond != secondsLeft) {
          _lastCountdownSecond = secondsLeft;
          SystemSound.play(SystemSoundType.click);
        }

        // Return direct de pure (negatieve) countdown
        return Duration(milliseconds: currentElapsedMillis);
      } else {
        _lastCountdownSecond = null;
      }
    }

    return Duration(
      milliseconds: chrono.accumulatedElapsedMillis + currentElapsedMillis,
    );
  }
}

final chronoScreenControllerProvider =
    NotifierProvider<ChronoScreenController, Duration>(
      ChronoScreenController.new,
    );
