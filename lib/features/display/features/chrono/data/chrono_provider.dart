import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_repository.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

final chronoRepositoryProvider = Provider<ChronoRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return ChronoRepository(
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

  Future<void> start(Chrono currentChrono, {int countdownMillis = 0}) async {
    final repository = ref.read(chronoRepositoryProvider);
    final notifier = ref.read(chronoNotifierProvider.notifier);

    final eventTime = DateTime.now().millisecondsSinceEpoch + countdownMillis;
    final optimisticState = currentChrono.copyWith(
      status: ChronoStatus.running,
      authoritativeStartTimeMillis: eventTime,
    );

    notifier.setOptimistic(optimisticState);

    try {
      await repository.start(currentChrono, countdownMillis: countdownMillis);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> pause(Chrono currentChrono) async {
    final repository = ref.read(chronoRepositoryProvider);
    final notifier = ref.read(chronoNotifierProvider.notifier);

    final pauseEventTime = DateTime.now().millisecondsSinceEpoch;
    final newlyElapsed =
        pauseEventTime - currentChrono.authoritativeStartTimeMillis;
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
      await repository.pause(currentChrono);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> lap(Chrono currentChrono, int elapsedMillis) async {
    final repository = ref.read(chronoRepositoryProvider);
    final notifier = ref.read(chronoNotifierProvider.notifier);

    // Optimistische update array
    final newLaps = List<int>.from(currentChrono.laps)..add(elapsedMillis);
    notifier.setOptimistic(currentChrono.copyWith(laps: newLaps));

    try {
      // FIX: Stuur de volledige nieuwe lijst (newLaps) door naar de repository
      await repository.lap(currentChrono, newLaps);
    } catch (e) {
      ref.invalidate(chronoNotifierProvider);
      rethrow;
    }
  }

  Future<void> reset() async {
    final repository = ref.read(chronoRepositoryProvider);
    ref.read(chronoNotifierProvider.notifier).setOptimistic(const Chrono());
    await repository.reset();
  }
}

final chronoCommandsProvider = Provider((ref) => ChronoCommands(ref));
