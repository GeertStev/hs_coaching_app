import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';

/// Een seintje aan de tafel (trillen + geluid). Het officiële signaal geeft
/// de hoofdscheidsrechter zelf; dit is alleen een hint (03 §1, OPEN-9).
enum ConsoleHint {
  /// De rust loopt bijna af: tijd voor de waarschuwing vóór de periode.
  periodStartWarning,

  /// 0:45 van een team time-out is voorbij.
  timeOutWarning,

  /// Een straf is uitgezeten.
  penaltyEnded,

  /// De speeltijd van de periode is om.
  periodExpired,

  /// De rust is om.
  breakEnded,
}

/// Welke hints horen bij de overgang van [previous] naar [next]. Puur: de
/// console roept dit bij elke tik van zijn timer aan.
Set<ConsoleHint> consoleHints(ClockView previous, ClockView next) {
  final hints = <ConsoleHint>{};

  final warningAt = next.state.config?.periodStartWarning;
  final breakBefore = previous.breakRemaining;
  final breakNow = next.breakRemaining;
  if (warningAt != null && breakBefore != null && breakNow != null) {
    if (breakBefore > warningAt &&
        breakNow <= warningAt &&
        breakNow > Duration.zero) {
      hints.add(ConsoleHint.periodStartWarning);
    }
    if (breakBefore > Duration.zero && breakNow == Duration.zero) {
      hints.add(ConsoleHint.breakEnded);
    }
  }

  if (next.timeOut?.warningReached == true &&
      previous.timeOut?.warningReached != true) {
    hints.add(ConsoleHint.timeOutWarning);
  }

  bool ended(PenaltyRecord penalty) =>
      penalty.status == PenaltyStatus.expiredWaiting ||
      penalty.status == PenaltyStatus.served;
  final endedBefore = {
    for (final penalty in previous.penalties)
      if (ended(penalty)) penalty.eventId,
  };
  if (next.penalties.any(
    (penalty) => ended(penalty) && !endedBefore.contains(penalty.eventId),
  )) {
    hints.add(ConsoleHint.penaltyEnded);
  }

  if (next.periodExpired &&
      !previous.periodExpired &&
      next.phase == previous.phase) {
    hints.add(ConsoleHint.periodExpired);
  }
  return hints;
}
