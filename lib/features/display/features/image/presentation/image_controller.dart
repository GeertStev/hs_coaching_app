import 'dart:async'; // Nodig voor FutureOr
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/features/image/data/display_image_repository.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';

// 1. Gebruik nu AsyncNotifier in plaats van AutoDisposeAsyncNotifier
class ImageController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële state nodig, wordt enkel gebruikt voor side-effects
  }

  Future<void> addImage({
    required ContentEditDialogResult result,
    required File imageFile,
    required bool setAsCurrent,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(appUserProvider).value;
      if (user == null) {
        throw Exception('Gebruiker is niet ingelogd.');
      }

      await ref
          .read(displayImageRepositoryProvider)
          .addImage(
            userId: user.uid,
            title: result.title,
            description: result.description,
            tags: result.tags,
            imageFile: imageFile,
            setAsCurrent: setAsCurrent,
          );
    });
  }

  Future<void> updateImage({
    required String imageId,
    required ContentEditDialogResult result,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(displayImageRepositoryProvider)
          .updateImage(
            id: imageId,
            title: result.title,
            description: result.description,
            tags: result.tags,
          );
    });
  }

  Future<void> toggleCurrent(String imageId, bool isCurrentlyActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(displayImageRepositoryProvider);
      if (isCurrentlyActive) {
        await repo.clearCurrentImage();
      } else {
        await repo.setCurrentImageId(imageId);
      }
    });
  }

  Future<void> archiveImage(String imageId) async {
    state = await AsyncValue.guard(
      () => ref.read(displayImageRepositoryProvider).archiveImage(imageId),
    );
  }

  Future<void> unarchiveImage(String imageId) async {
    state = await AsyncValue.guard(
      () => ref.read(displayImageRepositoryProvider).unarchiveImage(imageId),
    );
  }
}

// 2. De .autoDispose modifier blijft WEL staan op je Provider
final imageControllerProvider =
    AsyncNotifierProvider.autoDispose<ImageController, void>(
      ImageController.new,
    );
