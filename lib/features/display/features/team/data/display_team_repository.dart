// Repository for Firestore
// collection: /clubs/holySquid/displays/bilzen/teams/current
// fields: timestamp (server time of the last cast)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';

final displayTeamRepositoryProvider = Provider<DisplayTeamRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return DisplayTeamRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

class DisplayTeamRepository {
  DisplayTeamRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  DocumentReference get _teamSettingsRef {
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/teams/current
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('team');
  }

  Future<void> triggerTeamUpdate() async {
    await _teamSettingsRef.set({
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
