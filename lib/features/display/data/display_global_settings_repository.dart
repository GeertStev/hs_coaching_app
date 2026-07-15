import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/domain/display_global_settings.dart';

/// Provider for the global settings repository.
final displayGlobalSettingsRepositoryProvider =
    Provider<DisplayGlobalSettingsRepository>((ref) {
      final firestore = ref.watch(firebaseFirestoreProvider);
      final ids = ref.watch(displayDeviceIdsProvider);

      return DisplayGlobalSettingsRepository(
        firestore: firestore,
        clubId: ids.clubId,
        displayId: ids.displayDeviceId,
      );
    });

/// A repository that fetches the static global settings for a display.
class DisplayGlobalSettingsRepository {
  DisplayGlobalSettingsRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _globalSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('global');
  }

  /// Fetches the global settings document.
  Future<DisplayGlobalSettings> getGlobalSettings() async {
    final doc = await _globalSettingsRef.get();

    if (!doc.exists || doc.data() == null) {
      // Should this be a redirect to a login, or an information page?
      // In what scenario are there no global settings? No connection? Hacking?
      throw Exception('Global settings not found for display: $_displayId');
    }
    return DisplayGlobalSettings.fromMap(doc.data() as Map<String, dynamic>);
  }
}

/// A provider that fetches the static global settings for a display.
///
/// This is a `FutureProvider` because this data is expected to be read once
/// on startup and not change. Riverpod will cache the result.
final globalSettingsProvider = FutureProvider<DisplayGlobalSettings>((
  ref,
) async {
  final repository = ref.watch(displayGlobalSettingsRepositoryProvider);
  return repository.getGlobalSettings();
});

/// Provides the actual size available for the image content on the display.
///
/// This is calculated by taking the total screen dimensions from
/// [globalSettingsProvider] and subtracting the known padding/margins.
final imageContentSizeProvider = Provider<Size?>((ref) {
  final settings = ref.watch(globalSettingsProvider).value;
  if (settings == null) return null;

  // These values represent the horizontal and vertical padding/margins
  // around the image content area on the display screen.
  const double horizontalPadding = 12.0 * 2; // e.g., 12px on each side
  const double verticalPadding = 12.0 + 42.0; // e.g., 12px top, 42px bottom

  final contentWidth = settings.width - horizontalPadding;
  final contentHeight = settings.height - verticalPadding;

  return Size(contentWidth, contentHeight);
});
