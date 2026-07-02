import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';

/// Provider for the screen settings repository.
final displaySettingsRepositoryProvider = Provider<DisplaySettingsRepository>((
  ref,
) {
  return DisplaySettingsRepository(ref);
});

/// A repository for managing screen-related settings in Firestore.
class DisplaySettingsRepository {
  DisplaySettingsRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);

  DocumentReference _contentSettingsRef(String clubId, String displayId) {
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/content
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('content');
  }

  /// Updates the contentType field in the content settings document.
  Future<void> updateContentType(DisplayContentType contentType) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _contentSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({'contentType': contentType.name});
  }
}
