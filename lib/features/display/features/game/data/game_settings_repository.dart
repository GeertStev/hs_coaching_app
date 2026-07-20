import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/game/domain/game_settings.dart';

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

/// A repository for managing game-related settings in Firestore.
class GameSettingsRepository {
  GameSettingsRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  /// Reference to the 'game' settings document for a specific display.
  /// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/game
  DocumentReference get _gameSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('game');
  }

  /// Returns a stream of the current game settings.
  Stream<GameSettings> watchGameSettings() {
    return _gameSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const GameSettings(); // Default settings if document doesn't exist
      }
      return GameSettings.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Increments the score for a given team.
  ///
  /// Uses `FieldValue.increment` for atomic updates.
  Future<void> incrementScore(bool isBlack) async {
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await _gameSettingsRef.set({
      field: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Decrements the score for a given team, ensuring it doesn't go below zero.
  Future<void> decrementScore(bool isBlack, int currentScore) async {
    if (currentScore <= 0) return; // Prevent negative scores
    final field = isBlack ? 'blackScore' : 'whiteScore';
    await _gameSettingsRef.set({
      field: FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  /// Resets both team scores to 0.
  Future<void> resetScores() async {
    await _gameSettingsRef.set({
      'blackScore': 0,
      'whiteScore': 0,
    }, SetOptions(merge: true));
  }
}
