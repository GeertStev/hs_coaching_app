import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main()` met de instance van `SharedPreferences.getInstance()`,
/// vóór `runApp` opgehaald (net als `Firebase.initializeApp`) zodat elke
/// synchrone provider die persisted voorkeuren nodig heeft (bv.
/// `themeModeControllerProvider`) er zonder async gap bij kan.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp.',
  ),
);
