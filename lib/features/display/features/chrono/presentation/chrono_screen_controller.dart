import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

/// Manages the UI state for the ChronoControlScreen, including the timer
/// for live updates.
class ChronoScreenController extends Notifier<Duration> {
  Timer? _timer;

  @override
  Duration build() {
    // Watch the authoritative chrono state from the repository.
    final chronoAsync = ref.watch(chronoProvider);
    final chrono = chronoAsync.asData?.value ?? const Chrono();

    // When the notifier is disposed (e.g., user navigates away), cancel the timer.
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Stop any previous timer when the chrono state changes.
    _timer?.cancel();

    // If the chrono is running, start a timer to update the UI periodically.
    if (chrono.status == ChronoStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        // We don't need to read the full chrono object again, just recalculate
        // the elapsed time based on the original start time.
        state = _calculateElapsed(chrono);
      });
    }

    // Return the initial or final calculated duration.
    return _calculateElapsed(chrono);
  }

  Duration _calculateElapsed(Chrono chrono) {
    int currentElapsedMillis = 0;
    if (chrono.status == ChronoStatus.running) {
      final now = DateTime.now().millisecondsSinceEpoch;
      currentElapsedMillis = now - chrono.authoritativeStartTimeMillis;
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
