import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

/// Provider for the content settings repository.
final displayContentSettingsRepositoryProvider =
    Provider<DisplayContentSettingsRepository>((ref) {
      final firestore = ref.watch(firebaseFirestoreProvider);
      final ids = ref.watch(displayDeviceIdsProvider);

      return DisplayContentSettingsRepository(
        firestore: firestore,
        clubId: ids.clubId,
        displayId: ids.displayDeviceId,
      );
    });

/// A repository that listens for changes to the content settings for a display.
class DisplayContentSettingsRepository {
  DisplayContentSettingsRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _contentSettingsRef {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('content');
  }

  /// Returns a stream of the current content settings.
  Stream<DisplayContentSettings> watchContentSettings() {
    return _contentSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // If the document doesn't exist, create a default settings object.
        // This can happen when a new screen is created.
        return const DisplayContentSettings(
          contentType: DisplayContentType.main,
        );
      }
      return DisplayContentSettings.fromMap(
        snapshot.data() as Map<String, dynamic>,
      );
    });
  }
}

/// A provider that fetches the content settings for a display.
///
/// This is a `StreamProvider` to listen for real-time changes to the content type.
final displayContentSettingsProvider = StreamProvider<DisplayContentSettings>((
  ref,
) {
  final repository = ref.watch(displayContentSettingsRepositoryProvider);
  return repository.watchContentSettings();
});
