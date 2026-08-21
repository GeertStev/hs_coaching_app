/// Een opgeslagen sessie (snelkoppeling) uit de club-bibliotheek: de platte
/// configuratie van een [Tabata], zoals ingesteld in de editor.
///
/// Pad: /clubs/{clubId}/tabataPresets/{id}
class TabataPreset {
  const TabataPreset({
    required this.id,
    required this.title,
    required this.workSeconds,
    required this.restSeconds,
    required this.stepSeconds,
    required this.rounds,
    required this.sets,
    required this.restBetweenSets,
  });

  /// Firestore document-id.
  final String id;
  final String title;
  final int workSeconds;
  final int restSeconds;
  final int stepSeconds;
  final int rounds;
  final int sets;
  final int restBetweenSets;
}
