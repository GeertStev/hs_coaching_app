import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/game/data/game_settings_repository.dart';

/// Beheert de mutaties en Firebase state voor de Game score.
class GameController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële laad-logica nodig voor mutaties
  }

  Future<void> incrementScore(bool isBlack) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gameSettingsRepositoryProvider);
      await repository.incrementScore(isBlack);
    });
  }

  Future<void> decrementScore(bool isBlack, int currentScore) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gameSettingsRepositoryProvider);
      await repository.decrementScore(isBlack, currentScore);
    });
  }

  Future<void> resetScores() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gameSettingsRepositoryProvider);
      await repository.resetScores();
    });
  }
}

final gameControllerProvider =
    AsyncNotifierProvider.autoDispose<GameController, void>(GameController.new);
