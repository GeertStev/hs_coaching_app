import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/features/text/data/display_text_repository.dart';
import 'package:hs_coaching_app/features/display/presentation/content_edit_dialog.dart';

class TextController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Geen initiële state nodig, wordt enkel gebruikt voor mutaties
  }

  Future<void> addText({
    required ContentEditDialogResult result,
    required String textContent,
    required bool setAsCurrent,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(appUserProvider).value;
      if (user == null) {
        throw Exception('Gebruiker is niet ingelogd.');
      }

      await ref
          .read(displayTextRepositoryProvider)
          .addText(
            userId: user.uid,
            title: result.title,
            text: textContent,
            tags: result.tags,
            setAsCurrent: setAsCurrent,
          );
    });
  }

  Future<void> updateText({
    required String originalTextId,
    required bool isCurrent,
    required ContentEditDialogResult result,
    required String newTextContent,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(appUserProvider).value;
      if (user == null) {
        throw Exception('Gebruiker is niet ingelogd.');
      }

      await ref
          .read(displayTextRepositoryProvider)
          .updateTextByDuplicating(
            userId: user.uid,
            originalTextId: originalTextId,
            isCurrent: isCurrent,
            newTitle: result.title,
            newText: newTextContent,
            newTags: result.tags,
          );
    });
  }

  Future<void> toggleCurrent(String textId, bool isCurrentlyActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(displayTextRepositoryProvider);
      if (isCurrentlyActive) {
        await repo.clearCurrentText();
      } else {
        await repo.setCurrentTextId(textId);
      }
    });
  }

  Future<void> archiveText(String textId) async {
    state = await AsyncValue.guard(
      () => ref.read(displayTextRepositoryProvider).archiveText(textId),
    );
  }

  Future<void> unarchiveText(String textId) async {
    state = await AsyncValue.guard(
      () => ref.read(displayTextRepositoryProvider).unarchiveText(textId),
    );
  }
}

// .autoDispose wordt gedeclareerd op het niveau van de Provider
final textControllerProvider =
    AsyncNotifierProvider.autoDispose<TextController, void>(TextController.new);
