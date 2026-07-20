import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_set.dart';

/// Een opgeslagen standaard set (snelkoppeling) uit de club-bibliotheek.
///
/// Pad: /clubs/{clubId}/tabataPresets/{id}
class TabataPreset {
  const TabataPreset({required this.id, required this.set});

  /// Firestore document-id.
  final String id;
  final TabataSet set;
}
