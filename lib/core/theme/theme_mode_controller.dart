import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/shared_preferences_provider.dart';

const _themeModeKey = 'themeMode';

/// Persisted licht/donker/systeem-voorkeur. Leest de opgeslagen waarde
/// synchroon uit `sharedPreferencesProvider` (al opgehaald vóór `runApp`, zie
/// `main.dart`), zodat [build] — net als elke andere Riverpod 3 Notifier hier —
/// geen `AsyncNotifier` hoeft te zijn.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.name);
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
