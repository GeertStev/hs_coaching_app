import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/chrono/chrono_laps.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_repository.dart';

final chronoRepositoryProvider = Provider<DisplayChronoRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayChronoRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

class ChronoNotifier extends StreamNotifier<Chrono> {
  @override
  Stream<Chrono> build() {
    final repository = ref.watch(chronoRepositoryProvider);
    return repository.watchChrono();
  }

  void setOptimistic(Chrono chrono) {
    state = AsyncData(chrono);
  }
}

final chronoNotifierProvider = StreamNotifierProvider<ChronoNotifier, Chrono>(
  ChronoNotifier.new,
);

class ChronoCommands {
  const ChronoCommands(this.ref);
  final Ref ref;

  int get _nowServerMillis {
    final offsetMillis = ref.read(serverTimeOffsetProvider).value ?? 0;
    return serverNowMillis(offsetMillis);
  }

  Future<void> start(Chrono currentChrono, {int countdownMillis = 0}) async {
    final repository = ref.read(chronoRepositoryProvider);
    final notifier = ref.read(chronoNotifierProvider.notifier);

    final eventTime = _nowServerMillis + countdownMillis;
    final optimisticState = currentChrono.copyWith(
      status: ChronoStatus.running,
      authoritativeStartTimeMillis: eventTime,
    );

    notifier.setOptimistic(optimisticState);

    try {
      await repository.start(
        currentChrono,
        nowServerMillis: _nowServerMillis,
        countdownMillis: countdownMillis,
      );
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> pause(Chrono currentChrono) async {
    final repository = ref.read(chronoRepositoryProvider);
    final notifier = ref.read(chronoNotifierProvider.notifier);

    final nowServerMillis = _nowServerMillis;
    final newlyElapsed =
        nowServerMillis - currentChrono.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentChrono.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    notifier.setOptimistic(
      currentChrono.copyWith(
        status: ChronoStatus.paused,
        accumulatedElapsedMillis: totalAccumulated,
      ),
    );

    try {
      await repository.pause(currentChrono, nowServerMillis: nowServerMillis);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  /// Neemt een tijd op: [lane] null voor de Lap-knop, anders het baannummer
  /// van een baanknop. Doet niets als de chrono niet loopt of nog aftelt, als
  /// die baan zijn maximum laps heeft, of bij een dubbele druk op dezelfde
  /// baan (zie `isLapAccepted`).
  Future<void> recordLap({int? lane}) async {
    // Tijd op het moment van de druk, niet die van de laatste schermtik.
    final nowServerMillis = _nowServerMillis;
    final current = ref.read(chronoNotifierProvider).value;
    if (current == null || current.status != ChronoStatus.running) return;

    final elapsedMillis = chronoElapsedMillisAt(current, nowServerMillis);
    if (elapsedMillis < 0) return;
    if (!isLapAccepted(current, lane, elapsedMillis)) return;

    final lap = ChronoLap(elapsedMillis: elapsedMillis, lane: lane);
    ref
        .read(chronoNotifierProvider.notifier)
        .setOptimistic(current.copyWith(lapTimes: [...current.lapTimes, lap]));

    try {
      await ref.read(chronoRepositoryProvider).addLap(lap);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> setMaxLaps(int? maxLaps) async {
    final current = ref.read(chronoNotifierProvider).value ?? const Chrono();
    ref
        .read(chronoNotifierProvider.notifier)
        .setOptimistic(current.copyWith(maxLaps: maxLaps));
    try {
      await ref.read(chronoRepositoryProvider).setMaxLaps(maxLaps);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> reset() async {
    final repository = ref.read(chronoRepositoryProvider);
    final maxLaps = ref.read(chronoNotifierProvider).value?.maxLaps;
    ref
        .read(chronoNotifierProvider.notifier)
        .setOptimistic(Chrono(maxLaps: maxLaps));
    await repository.reset(maxLaps: maxLaps);
  }
}

final chronoCommandsProvider = Provider((ref) => ChronoCommands(ref));
