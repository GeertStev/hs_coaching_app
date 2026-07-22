import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_item.dart';

/// Een opgeslagen sessie (snelkoppeling) uit de club-bibliotheek: de volledige
/// kaartenlijst van een [Tabata], zoals opgebouwd in de editor.
///
/// Pad: /clubs/{clubId}/tabataPresets/{id}
class TabataPreset {
  const TabataPreset({
    required this.id,
    required this.title,
    required this.items,
  });

  /// Firestore document-id.
  final String id;
  final String title;
  final List<TabataItem> items;
}
