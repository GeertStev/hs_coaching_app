import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/game/game_settings_repository.dart';

/// Provider for the game settings repository.
final gameSettingsRepositoryProvider = Provider<GameSettingsRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return GameSettingsRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Adds score-mutating writes on top of core's read-only
/// [DisplayGameSettingsRepository] base.
class GameSettingsRepository extends DisplayGameSettingsRepository {
  GameSettingsRepository({
    required super.firestore,
    required super.clubId,
    required super.displayId,
  });

  /// Increments the score for a given team.
  ///
  /// Uses `FieldValue.increment` for atomic updates.
  Future<void> incrementScore(bool isBlack) async {
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await gameSettingsRef.set({
      field: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Decrements the score for a given team, ensuring it doesn't go below zero.
  Future<void> decrementScore(bool isBlack, int currentScore) async {
    if (currentScore <= 0) return; // Prevent negative scores
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await gameSettingsRef.set({
      field: FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  /// Resets both team scores to 0.
  Future<void> resetScores() async {
    await gameSettingsRef.set({
      'blackScore': 0,
      'whiteScore': 0,
    }, SetOptions(merge: true));
  }
}
