import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/data/timer_providers.dart';
import 'package:hs_coaching_app/features/display/features/timer_old/domain/timer_set.dart';

/// Beheert de mutaties en Firebase state voor TimerSets.
class TimerController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële state nodig
  }

  Future<void> addTimerSet({
    required String title,
    required String description,
    required int restBetweenExercisesSeconds,
    required List<ExerciseInSet> exercises,
    required List<String> tags,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // User fetch verplaatst naar Controller
      final ownerId = ref.read(appUserProvider).value?.uid;
      if (ownerId == null) {
        throw Exception('Geen ingelogde gebruiker gevonden.');
      }

      final newSet = TimerSet(
        title: title,
        description: description,
        restBetweenExercisesSeconds: restBetweenExercisesSeconds,
        exercises: exercises,
        ownerId: ownerId,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(timerRepositoryProvider);
      await repository.addTimerSet(newSet);
    });
  }

  Future<void> updateTimerSet(TimerSet timerSet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(timerRepositoryProvider);
      await repository.updateTimerSet(timerSet);
    });
  }

  Future<void> deleteTimerSet(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(timerRepositoryProvider);
      await repository.deleteTimerSet(id);
    });
  }

  Future<void> restoreTimerSet(TimerSet timerSet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(timerRepositoryProvider);
      // Gebruikt voor de 'undo' actie
      await repository.addTimerSet(timerSet);
    });
  }
}

final timerControllerProvider =
    AsyncNotifierProvider.autoDispose<TimerController, void>(
      TimerController.new,
    );
