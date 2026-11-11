import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/match/domain/console_hints.dart';
import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/match_session.dart';

/// Wat de console toont: de berekende klokken en de hints van de laatste tik.
class MatchConsoleView {
  const MatchConsoleView({
    required this.clock,
    required this.holdsLease,
    this.hints = const {},
    this.hintSerial = 0,
  });

  final ClockView clock;
  final bool holdsLease;

  /// Hints die bij de laatste overgang hoorden.
  final Set<ConsoleHint> hints;

  /// Telt op bij elke nieuwe hint, zodat de console er precies één keer op
  /// reageert.
  final int hintSerial;
}

/// Leidt de klokken van één wedstrijd af uit de sessie, zoals de andere
/// `*ScreenController`s: niets wordt opgeslagen of getikt, de timer vraagt
/// alleen opnieuw om de berekende stand.
class MatchConsoleController extends Notifier<MatchConsoleView> {
  MatchConsoleController(this.session);

  final MatchSession session;

  static const _tick = Duration(milliseconds: 200);

  @override
  MatchConsoleView build() {
    final subscription = session.states.listen((_) => _refresh());
    final timer = Timer.periodic(_tick, (_) => _refresh());
    ref.onDispose(() {
      timer.cancel();
      subscription.cancel();
    });
    return MatchConsoleView(
      clock: session.clock,
      holdsLease: session.holdsLease,
    );
  }

  void _refresh() {
    final clock = session.clock;
    final hints = consoleHints(state.clock, clock);
    state = MatchConsoleView(
      clock: clock,
      holdsLease: session.holdsLease,
      hints: hints.isEmpty ? state.hints : hints,
      hintSerial: hints.isEmpty ? state.hintSerial : state.hintSerial + 1,
    );
  }
}

/// Per sessie (en dus per wedstrijd) een eigen controller: er is geen globale
/// "actieve wedstrijd".
final matchConsoleProvider = NotifierProvider.autoDispose
    .family<MatchConsoleController, MatchConsoleView, MatchSession>(
      MatchConsoleController.new,
    );
