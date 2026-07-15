import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';

/// Beheert de mutaties en Firebase state voor de Chrono.
class ChronoController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële laad-logica nodig voor mutaties
  }

  Future<void> start(Chrono currentChrono) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(chronoRepositoryProvider);
      await repository.start(currentChrono);
    });
  }

  Future<void> pause(Chrono currentChrono) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(chronoRepositoryProvider);
      await repository.pause(currentChrono);
    });
  }

  Future<void> reset() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(chronoRepositoryProvider);
      await repository.reset();
    });
  }
}

final chronoControllerProvider =
    AsyncNotifierProvider.autoDispose<ChronoController, void>(
      ChronoController.new,
    );
