import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

class ChronoScreenController extends Notifier<Duration> {
  Timer? _timer;
  int? _lastCountdownSecond;

  @override
  Duration build() {
    final chronoAsync = ref.watch(chronoNotifierProvider);
    final chrono = chronoAsync.value ?? const Chrono();

    ref.onDispose(() {
      _timer?.cancel();
    });

    _timer?.cancel();

    if (chrono.status == ChronoStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        state = _calculateElapsed(chrono);
      });
    }

    return _calculateElapsed(chrono);
  }

  Duration _calculateElapsed(Chrono chrono) {
    int currentElapsedMillis = 0;

    if (chrono.status == ChronoStatus.running) {
      final now = DateTime.now().millisecondsSinceEpoch;

      // FIX: Verwijder de serverWriteTimestamp override.
      // We gebruiken uitsluitend authoritativeStartTimeMillis omdat
      // de countdown daar al in is verwerkt.
      int startMillis = chrono.authoritativeStartTimeMillis;

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
