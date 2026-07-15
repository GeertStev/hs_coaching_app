import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/game/data/game_settings_repository.dart';
import 'package:hs_coaching_app/features/display/features/game/domain/game_settings.dart';

/// A provider that streams the latest game settings from Firestore.
final gameSettingsProvider = StreamProvider<GameSettings>((ref) {
  final repository = ref.watch(gameSettingsRepositoryProvider);
  return repository.watchGameSettings();
});
