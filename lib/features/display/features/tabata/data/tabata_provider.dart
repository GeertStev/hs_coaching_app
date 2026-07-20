import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/tabata/data/tabata_repository.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_preset.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';

final tabataRepositoryProvider = Provider<TabataRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return TabataRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

class TabataNotifier extends StreamNotifier<Tabata> {
  @override
  Stream<Tabata> build() {
    final repository = ref.watch(tabataRepositoryProvider);
    return repository.watchTabata();
  }

  void setOptimistic(Tabata tabata) {
    state = AsyncData(tabata);
  }
}

final tabataNotifierProvider = StreamNotifierProvider<TabataNotifier, Tabata>(
  TabataNotifier.new,
);

/// Standaard sets (snelkoppelingen) uit de club-bibliotheek.
final tabataPresetsProvider = StreamProvider<List<TabataPreset>>((ref) {
  return ref.watch(tabataRepositoryProvider).watchPresets();
});

/// Commands met optimistische updates + rollback via invalidate, naar het
/// voorbeeld van [ChronoCommands].
class TabataCommands {
  const TabataCommands(this.ref);
  final Ref ref;

  /// Schrijft een aangepaste configuratie (voorbereiding en/of sets).
  Future<void> updateConfig(Tabata newTabata) async {
    final repository = ref.read(tabataRepositoryProvider);
    final notifier = ref.read(tabataNotifierProvider.notifier);

    notifier.setOptimistic(newTabata);

    try {
      await repository.saveConfig(newTabata);
    } catch (e) {
      ref.invalidate(tabataNotifierProvider);
      rethrow;
    }
  }

  /// Start of hervat (na pauze) de timer.
  Future<void> start(Tabata currentTabata) async {
    final repository = ref.read(tabataRepositoryProvider);
    final notifier = ref.read(tabataNotifierProvider.notifier);

    final eventTime = DateTime.now().millisecondsSinceEpoch;
    notifier.setOptimistic(
      currentTabata.copyWith(
        status: TabataStatus.running,
        authoritativeStartTimeMillis: eventTime,
      ),
    );

    try {
      await repository.start(currentTabata);
    } catch (e) {
      ref.invalidate(tabataNotifierProvider);
      rethrow;
    }
  }

  Future<void> pause(Tabata currentTabata) async {
    final repository = ref.read(tabataRepositoryProvider);
    final notifier = ref.read(tabataNotifierProvider.notifier);

    final pauseEventTime = DateTime.now().millisecondsSinceEpoch;
    final newlyElapsed =
        pauseEventTime - currentTabata.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentTabata.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    notifier.setOptimistic(
      currentTabata.copyWith(
        status: TabataStatus.paused,
        accumulatedElapsedMillis: totalAccumulated,
      ),
    );

    try {
      await repository.pause(currentTabata);
    } catch (e) {
      ref.invalidate(tabataNotifierProvider);
      rethrow;
    }
  }

  Future<void> reset(Tabata currentTabata) async {
    final repository = ref.read(tabataRepositoryProvider);
    final notifier = ref.read(tabataNotifierProvider.notifier);

    notifier.setOptimistic(
      currentTabata.copyWith(
        status: TabataStatus.stopped,
        authoritativeStartTimeMillis: 0,
        accumulatedElapsedMillis: 0,
      ),
    );

    try {
      await repository.reset(currentTabata);
    } catch (e) {
      ref.invalidate(tabataNotifierProvider);
      rethrow;
    }
  }

  // ------------------------------------------------------ Standaard sets
  // Geen optimistische update nodig: de presets-stream is geen onderdeel
  // van de lopende timer-state.

  Future<void> savePreset(TabataSet set) {
    return ref.read(tabataRepositoryProvider).savePreset(set);
  }

  Future<void> deletePreset(String presetId) {
    return ref.read(tabataRepositoryProvider).deletePreset(presetId);
  }
}

final tabataCommandsProvider = Provider((ref) => TabataCommands(ref));
