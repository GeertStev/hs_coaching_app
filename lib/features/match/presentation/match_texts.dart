import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/engine/match_rejection.dart';
import 'package:hs_coaching_core/match/engine/match_roster.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/team/team_model.dart';

/// Teksten van de wedstrijdtafel. Los van de widgets, zodat ze te testen zijn
/// en het PDF-verslag ze later kan hergebruiken.

String teamLabel(TeamColor team) => team == TeamColor.white ? 'White' : 'Black';

String phaseLabel(MatchPhase phase) => switch (phase) {
  MatchPhase.notStarted => 'Not started',
  MatchPhase.p1 => 'Period 1',
  MatchPhase.halfTime => 'Half-time',
  MatchPhase.p2 => 'Period 2',
  MatchPhase.otBreak => 'Break before overtime',
  MatchPhase.ot1 => 'Overtime 1',
  MatchPhase.otInterval => 'Overtime interval',
  MatchPhase.ot2 => 'Overtime 2',
  MatchPhase.sdBreak => 'Break before sudden death',
  MatchPhase.suddenDeath => 'Sudden death',
  MatchPhase.awaitingSignOff => 'Waiting for sign-off',
  MatchPhase.finalized => 'Final',
};

/// `m:ss`, naar boven afgerond zodat een aftelling pas 0:00 toont als ze om is.
String formatClock(Duration duration, {bool countingDown = true}) {
  final millis = duration.inMilliseconds < 0 ? 0 : duration.inMilliseconds;
  final seconds = countingDown ? (millis + 999) ~/ 1000 : millis ~/ 1000;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// De klok die bovenaan de console staat, met wat ze aftelt.
({String label, String time}) mainClock(ClockView clock) {
  final state = clock.state;
  final timeOut = clock.timeOut;
  if (timeOut != null) {
    final remaining = timeOut.remaining;
    final team = timeOut.team;
    return remaining != null && team != null
        ? (label: 'Time-out ${teamLabel(team)}', time: formatClock(remaining))
        : (
            label: "Officials' time-out",
            time: formatClock(timeOut.elapsed, countingDown: false),
          );
  }
  final breakRemaining = clock.breakRemaining;
  if (state.phase.isBreak && breakRemaining != null) {
    return (label: phaseLabel(state.phase), time: formatClock(breakRemaining));
  }
  if (state.phase == MatchPhase.notStarted) {
    final length = state.config?.playLength(MatchPhase.p1);
    return (
      label: phaseLabel(state.phase),
      time: length == null ? '-:--' : formatClock(length),
    );
  }
  final remaining = clock.periodRemaining;
  return (
    label: phaseLabel(state.phase),
    time: remaining != null
        ? formatClock(remaining)
        : formatClock(clock.periodElapsed, countingDown: false),
  );
}

String restartTypeLabel(RestartType type) => switch (type) {
  RestartType.endLineStart => 'End line start',
  RestartType.equalPuck => 'Equal puck',
  RestartType.advantagePuck => 'Advantage puck',
  RestartType.afterPenaltyShot => 'After penalty shot',
  RestartType.afterTimeOut => 'After time-out',
};

/// Waarom de engine een actie weigert, voor de lange druk op een grijze knop.
String rejectionMessage(
  MatchRejection rejection,
) => switch (rejection.problem) {
  GeneralProblem.matchNotCreated => 'The match has not been set up yet.',
  GeneralProblem.matchAlreadyCreated => 'The match is already set up.',
  GeneralProblem.matchFinal => 'The match is final.',
  GeneralProblem.wrongPhase => 'Not possible in this phase of the match.',
  GeneralProblem.capOutOfRange => 'That cap number is not on the roster.',
  GeneralProblem.playerDismissed => 'That player has been dismissed.',
  PlayProblem.alreadyRunning => 'Play is already running.',
  PlayProblem.notRunning => 'Play is already stopped.',
  PlayProblem.periodExpired => 'The period time is up. End the period first.',
  TimeOutProblem.playRunning => 'Stop play before a time-out.',
  TimeOutProblem.alreadyUsedThisHalf =>
    'This team already used its time-out this half.',
  TimeOutProblem.notInRegularPeriod =>
    'Team time-outs are only allowed in period 1 and 2.',
  TimeOutProblem.penaltyShotPending => 'Finish the penalty shot first.',
  PeriodEndProblem.wrongPhase => 'No timed period is being played.',
  PeriodEndProblem.clockNotExpired => 'The period time is not up yet.',
  PeriodEndProblem.penaltyShotPending => 'Finish the penalty shot first.',
  PenaltyShotProblem.alreadyPending => 'A penalty shot is already pending.',
  PenaltyShotProblem.noShotPending => 'There is no penalty shot pending.',
  PenaltyShotProblem.playerInPenaltyBox => 'That player is in the penalty box.',
  PenaltyShotProblem.playerDismissed => 'That player has been dismissed.',
  PenaltyReturnProblem.noExpiredPenalty =>
    'This penalty has not been served yet.',
  VoidProblem.unknownTarget => 'That event no longer exists.',
  VoidProblem.alreadyVoided => 'This event is already undone.',
  VoidProblem.matchCreated => 'The match setup cannot be undone.',
  VoidProblem.voidEvent => 'An undo cannot be undone. Log the event again.',
  SignOffProblem.winnerRequired => 'This match needs a winner.',
  StopReasonProblem.unknownTarget => 'That stop no longer exists.',
  RosterProblem() => 'The roster is not valid.',
  _ => 'This action is not allowed right now.',
};

String _cap(int? cap) => cap == null ? '' : ' #$cap';

/// Eén regel van het eventlog.
String eventLabel(MatchEventData data) => switch (data) {
  MatchCreated(:final teamWhite, :final teamBlack) =>
    'Match set up: $teamWhite - $teamBlack',
  RosterDeclared(:final team, :final players) =>
    'Roster ${teamLabel(team)}: ${players.length} players',
  OfficialsAssigned(:final chief) => 'Officials assigned (chief: $chief)',
  PeriodWarningGiven() => 'Warning before the period',
  PlayStarted(:final restartType) =>
    'Play started (${restartTypeLabel(restartType)})',
  PlayStopped() => 'Play stopped',
  StopReasonSpecified(:final reason) => 'Stop reason: ${reason.name}',
  OfficialsTimeOutStarted() => "Officials' time-out",
  TeamTimeOutRequested(:final team) => 'Time-out ${teamLabel(team)}',
  PeriodEnded(:final phase) => '${phaseLabel(phase)} ended',
  GoalScored(:final team, :final scorerCap, :final kind) =>
    '${kind == GoalKind.field ? 'Goal' : 'Penalty goal'} '
        '${teamLabel(team)}${_cap(scorerCap)}',
  CautionGiven(:final team, :final cap, :final infringementCode) =>
    'Caution ${teamLabel(team)}${_cap(cap)} ($infringementCode)',
  TimePenaltyGiven(
    :final team,
    :final cap,
    :final minutes,
    :final infringementCode,
  ) =>
    '$minutes min penalty ${teamLabel(team)} #$cap ($infringementCode)',
  PlayerDismissed(:final team, :final cap, :final infringementCode) =>
    'Dismissal ${teamLabel(team)} #$cap ($infringementCode)',
  OfficialDismissed(:final team, :final name) =>
    'Official dismissed ${teamLabel(team)}: $name',
  PenaltyShotAwarded(:final againstTeam) =>
    'Penalty shot for ${teamLabel(opponentOf(againstTeam))}',
  PenaltyShotResolved(:final outcome) =>
    outcome == PenaltyShotOutcome.goal
        ? 'Penalty shot: goal'
        : 'Penalty shot: defended',
  PenaltyPlayerReturned(:final team, :final cap) =>
    'Back from penalty: ${teamLabel(team)} #$cap',
  ProtestLogged(:final team) => 'Protest ${teamLabel(team)}',
  EventVoided() => 'Undo',
  MatchEndedBySignOff() => 'Match signed off',
  ResultDecidedByDelegate() => 'Result decided by delegate',
  MatchForfeited(:final team) => 'Forfeit ${teamLabel(team)}',
  MatchAbandoned() => 'Match abandoned',
};

/// Tekst op een strafklok in de strafbalk.
String penaltyLabel(PenaltyRecord penalty) => switch (penalty.status) {
  PenaltyStatus.dismissal => '#${penalty.cap} OUT',
  PenaltyStatus.expiredWaiting => '#${penalty.cap} RELEASE',
  _ => '#${penalty.cap} ${formatClock(penalty.remaining)}',
};
