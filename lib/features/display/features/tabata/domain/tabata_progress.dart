/// De fase waarin de tabata-timer zich bevindt op een bepaald moment.
/// [setRest] is de rust tussen twee kaarten (top-level of tussen kinderen
/// binnen een groep) — zie [TabataItem.restAfter]/[TabataGroup.restAfter].
enum TabataPhase { prepare, work, rest, setRest, finished }

/// Afgeleide, berekende voortgang van een [Tabata] op een gegeven verstreken
/// tijd. Bevat geen Firestore-state; wordt lokaal berekend (zowel in de
/// control app als in de display app) zodat er tijdens het lopen geen
/// netwerk-writes nodig zijn.
class TabataProgress {
  const TabataProgress({
    required this.phase,
    required this.itemIndex,
    required this.totalItems,
    required this.itemTitle,
    required this.round,
    required this.totalRounds,
    required this.groupRepeat,
    required this.totalGroupRepeats,
    required this.phaseRemaining,
    required this.phaseTotal,
    required this.elapsed,
    required this.totalRemaining,
  });

  final TabataPhase phase;

  /// 1-gebaseerd nummer van de huidige top-level kaart in [Tabata.items].
  /// Tijdens [TabataPhase.setRest] wijst dit al naar de volgende kaart, zodat
  /// het scherm toont waarvoor er gerust wordt.
  final int itemIndex;
  final int totalItems;

  /// Titel van de huidige oefening (leeg als de oefening geen titel heeft).
  final String itemTitle;

  /// 1-gebaseerd rondenummer binnen de huidige oefening.
  final int round;
  final int totalRounds;

  /// 1-gebaseerde herhaling van de omvattende groep, of `null` als de huidige
  /// oefening geen deel uitmaakt van een groep.
  final int? groupRepeat;
  final int? totalGroupRepeats;

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
