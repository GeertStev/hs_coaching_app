// Repository for Firestore
// collection: /clubs/holySquid/displays/bilzen/teams/current
// fields: update (bool)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';

final displayTeamRepositoryProvider = Provider<DisplayTeamRepository>((ref) {
  return DisplayTeamRepository(ref);
});

class DisplayTeamRepository {
  DisplayTeamRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);

  DocumentReference _teamSettingsRef(String clubId, String displayId) {
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/teams/current
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('team');
  }

  Future<void> triggerTeamUpdate() async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _teamSettingsRef(ids.clubId, ids.displayDeviceId).set({
      'update': true,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
