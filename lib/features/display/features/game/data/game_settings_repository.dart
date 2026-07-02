import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/game/domain/game_settings.dart';

/// Provider for the game settings repository.
final gameSettingsRepositoryProvider = Provider<GameSettingsRepository>((ref) {
  return GameSettingsRepository(ref);
});

/// A repository for managing game-related settings in Firestore.
class GameSettingsRepository {
  GameSettingsRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);

  /// Reference to the 'game' settings document for a specific display.
  /// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/game
  DocumentReference _gameSettingsRef(String clubId, String displayId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('game');
  }

  /// Returns a stream of the current game settings.
  Stream<GameSettings> watchGameSettings() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _gameSettingsRef(ids.clubId, ids.displayDeviceId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const GameSettings(); // Default settings if document doesn't exist
      }
      return GameSettings.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Increments the score for a given team.
  ///
  /// Uses `FieldValue.increment` for atomic updates.
  Future<void> incrementScore(bool isBlack) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await _gameSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({field: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  /// Decrements the score for a given team, ensuring it doesn't go below zero.
  Future<void> decrementScore(bool isBlack, int currentScore) async {
    if (currentScore <= 0) return; // Prevent negative scores
    final ids = _ref.read(displayDeviceIdsProvider);
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await _gameSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({field: FieldValue.increment(-1)}, SetOptions(merge: true));
  }

  /// Resets both team scores to 0.
  Future<void> resetScores() async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _gameSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({'blackScore': 0, 'whiteScore': 0}, SetOptions(merge: true));
  }
}
