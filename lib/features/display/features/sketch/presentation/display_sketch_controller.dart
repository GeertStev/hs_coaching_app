import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';

class SketchController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële state nodig, wordt enkel gebruikt voor mutaties
  }

  Future<String?> createSketch({
    required ContentEditDialogResult result,
    required String? backgroundUrl,
    required bool setAsCurrent,
  }) async {
    state = const AsyncLoading();
    String? newSketchId;

    state = await AsyncValue.guard(() async {
      final user = ref.read(appUserProvider).value;
      if (user == null) {
        throw Exception('Gebruiker is niet ingelogd.');
      }

      final repo = ref.read(sketchRepositoryProvider);

      newSketchId = await repo.createSketch(
        title: result.title,
        description: result.description,
        tags: result.tags,
        backgroundUrl: backgroundUrl,
        userId: user.uid,
      );

      if (setAsCurrent && newSketchId != null) {
        await repo.setCurrentSketchId(newSketchId);
      }
    });

    // Retourneer het ID (als er geen fout was) zodat de UI kan navigeren
    return state.hasError ? null : newSketchId;
  }

  Future<void> updateSketch({
    required String sketchId,
    required ContentEditDialogResult result,
    required String? backgroundUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(sketchRepositoryProvider)
          .updateSketch(
            id: sketchId,
            title: result.title,
            description: result.description,
            tags: result.tags,
            backgroundUrl: backgroundUrl,
          );
    });
  }

  Future<void> toggleCurrent(String sketchId, bool isCurrentlyActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(sketchRepositoryProvider);
      if (isCurrentlyActive) {
        await repo.clearCurrentSketch();
      } else {
        await repo.setCurrentSketchId(sketchId);
      }
    });
  }

  Future<void> archiveSketch(String sketchId) async {
    state = await AsyncValue.guard(
      () => ref.read(sketchRepositoryProvider).archiveSketch(sketchId),
    );
  }

  Future<void> unarchiveSketch(String sketchId) async {
    state = await AsyncValue.guard(
      () => ref.read(sketchRepositoryProvider).unarchiveSketch(sketchId),
    );
  }

  Future<void> updateBackground(String sketchId, String? backgroundUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(sketchRepositoryProvider)
          .updateSketchBackground(sketchId, backgroundUrl);
    });
  }
}

// .autoDispose gedeclareerd op Provider-niveau (Riverpod 3.0 standaard)
final sketchControllerProvider =
    AsyncNotifierProvider.autoDispose<SketchController, void>(
      SketchController.new,
    );
