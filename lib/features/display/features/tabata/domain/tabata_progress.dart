/// De fase waarin de tabata-timer zich bevindt op een bepaald moment.
/// [setRest] is de rust tussen twee sets.
enum TabataPhase { prepare, work, rest, setRest, finished }

/// Afgeleide, berekende voortgang van een [Tabata] op een gegeven verstreken
/// tijd. Bevat geen Firestore-state; wordt lokaal berekend (zowel in de
/// control app als in de display app) zodat er tijdens het lopen geen
/// netwerk-writes nodig zijn.
class TabataProgress {
  const TabataProgress({
    required this.phase,
    required this.setIndex,
    required this.totalSets,
    required this.setTitle,
    required this.round,
    required this.totalRounds,
    required this.phaseRemaining,
    required this.phaseTotal,
    required this.elapsed,
    required this.totalRemaining,
  });

  final TabataPhase phase;

  /// 1-gebaseerd setnummer. Tijdens [TabataPhase.setRest] wijst dit al naar
  /// de volgende set, zodat het scherm toont waarvoor er gerust wordt.
  final int setIndex;
  final int totalSets;

  /// Titel van de huidige set (leeg als de set geen titel heeft).
  final String setTitle;

  /// 1-gebaseerd rondenummer binnen de huidige set.
  final int round;
  final int totalRounds;

  /// Resterende tijd binnen de huidige fase.
  final Duration phaseRemaining;

  /// Totale duur van de huidige fase (voor de progress-ring).
  final Duration phaseTotal;

  /// Totaal verstreken tijd sinds de start van de voorbereiding.
  final Duration elapsed;

  /// Resterende tijd tot het einde van de laatste werkronde.
  final Duration totalRemaining;

  /// Fractie 0..1 van de huidige fase die nog resteert (voor de ring).
  double get phaseRemainingFraction => phaseTotal.inMilliseconds <= 0
      ? 0
      : (phaseRemaining.inMilliseconds / phaseTotal.inMilliseconds).clamp(0, 1);
}
