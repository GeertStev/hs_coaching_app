import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_core/scheduler/scheduler_config.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/team_scheduler.dart';

/// Eén ploeg in de indeling die de trainer aan het maken is.
class DraftTeam {
  const DraftTeam({
    required this.name,
    required this.composition,
    this.substitutes = const {},
  });

  final String name;

  /// Naam van de opstelling (`TeamComposition.name`).
  final String composition;

  /// Aantal wissels per positie.
  final Map<PlayerPosition, int> substitutes;

  DraftTeam copyWith({
    String? name,
    String? composition,
    Map<PlayerPosition, int>? substitutes,
  }) => DraftTeam(
    name: name ?? this.name,
    composition: composition ?? this.composition,
    substitutes: substitutes ?? this.substitutes,
  );
}

/// De keuzes van de trainer voor één training: wie er is, wie vast staat en
/// welke ploegen er gevuld worden. Alleen in het geheugen van de app.
class ScheduleDraft {
  const ScheduleDraft({
    this.attendees = const {},
    this.teams = const [],
    this.prioritizeExperience = false,
    this.prioritizeInexperience = false,
  });

  /// Aanwezige spelers per `playerId`.
  final Map<String, Attendee> attendees;
  final List<DraftTeam> teams;
  final bool prioritizeExperience;
  final bool prioritizeInexperience;

  ScheduleDraft copyWith({
    Map<String, Attendee>? attendees,
    List<DraftTeam>? teams,
    bool? prioritizeExperience,
    bool? prioritizeInexperience,
  }) => ScheduleDraft(
    attendees: attendees ?? this.attendees,
    teams: teams ?? this.teams,
    prioritizeExperience: prioritizeExperience ?? this.prioritizeExperience,
    prioritizeInexperience:
        prioritizeInexperience ?? this.prioritizeInexperience,
  );
}

/// Opstelling waarmee een nieuwe ploeg begint.
const _preferredComposition = '2-3-1';

/// Beheert de indeling in opbouw. Blijft bestaan zolang de app open is,
/// zodat de trainer tussendoor naar een ander scherm kan.
class ScheduleDraftController extends Notifier<ScheduleDraft> {
  @override
  ScheduleDraft build() => ScheduleDraft(
    teams: [
      for (final name in defaultTeamNames.take(2))
        DraftTeam(name: name, composition: _preferredComposition),
    ],
  );

  void setAttending(String playerId, bool attending) {
    final attendees = {...state.attendees};
    if (attending) {
      attendees.putIfAbsent(playerId, () => Attendee(playerId: playerId));
    } else {
      attendees.remove(playerId);
    }
    state = state.copyWith(attendees: attendees);
  }

  void clearAttendance() => state = state.copyWith(attendees: const {});

  void setFixedPosition(String playerId, PlayerPosition? position) =>
      _updateAttendee(
        playerId,
        (a) => Attendee(
          playerId: playerId,
          fixedPosition: position,
          fixedTeam: a.fixedTeam,
        ),
      );

  void setFixedTeam(String playerId, String? team) => _updateAttendee(
    playerId,
    (a) => Attendee(
      playerId: playerId,
      fixedPosition: a.fixedPosition,
      fixedTeam: team,
    ),
  );

  void _updateAttendee(String playerId, Attendee Function(Attendee) update) {
    final current = state.attendees[playerId];
    if (current == null) return;
    state = state.copyWith(
      attendees: {...state.attendees, playerId: update(current)},
    );
  }

  /// Voegt een ploeg toe met de eerste nog vrije naam uit [names].
  void addTeam(List<String> names) {
    final used = {for (final team in state.teams) team.name};
    final name = names.firstWhere(
      (name) => !used.contains(name),
      orElse: () => 'Team ${state.teams.length + 1}',
    );
    state = state.copyWith(
      teams: [
        ...state.teams,
        DraftTeam(
          name: name,
          composition: state.teams.isEmpty
              ? _preferredComposition
              : state.teams.last.composition,
        ),
      ],
    );
  }

  void removeTeam(int index) {
    final removed = state.teams[index].name;
    state = state.copyWith(
      teams: [...state.teams]..removeAt(index),
      // Wie vast in die ploeg stond, is weer vrij.
      attendees: {
        for (final entry in state.attendees.entries)
          entry.key: entry.value.fixedTeam == removed
              ? Attendee(
                  playerId: entry.key,
                  fixedPosition: entry.value.fixedPosition,
                )
              : entry.value,
      },
    );
  }

  void setTeamName(int index, String name) {
    final old = state.teams[index].name;
    if (name == old || state.teams.any((team) => team.name == name)) return;
    state = state.copyWith(
      teams: [...state.teams]
        ..[index] = state.teams[index].copyWith(name: name),
      attendees: {
        for (final entry in state.attendees.entries)
          entry.key: entry.value.fixedTeam == old
              ? Attendee(
                  playerId: entry.key,
                  fixedPosition: entry.value.fixedPosition,
                  fixedTeam: name,
                )
              : entry.value,
      },
    );
  }

  void setComposition(int index, String composition) => _updateTeam(
    index,
    // Wissels horen bij de plaatsen van de oude opstelling.
    (team) => team.copyWith(composition: composition, substitutes: const {}),
  );

  void setSubstitutes(int index, PlayerPosition position, int count) =>
      _updateTeam(
        index,
        (team) =>
            team.copyWith(substitutes: {...team.substitutes, position: count}),
      );

  void _updateTeam(int index, DraftTeam Function(DraftTeam) update) {
    state = state.copyWith(
      teams: [...state.teams]..[index] = update(state.teams[index]),
    );
  }

  void setPrioritizeExperience(bool value) =>
      state = state.copyWith(prioritizeExperience: value);

  void setPrioritizeInexperience(bool value) =>
      state = state.copyWith(prioritizeInexperience: value);
}

final scheduleDraftProvider =
    NotifierProvider<ScheduleDraftController, ScheduleDraft>(
      ScheduleDraftController.new,
    );

/// De opstelling met naam [name], of `null` als die niet (meer) bestaat.
TeamComposition? compositionNamed(SchedulerConfig config, String name) {
  for (final composition in config.compositions) {
    if (composition.name == name) return composition;
  }
  return null;
}

/// De ploegindeling voor de huidige keuzes, of `null` zolang de gegevens nog
/// laden of er niemand aanwezig is. Wordt bij elke wijziging opnieuw berekend.
final scheduleResultProvider = Provider<ScheduleResult?>((ref) {
  final draft = ref.watch(scheduleDraftProvider);
  final players = ref.watch(squadPlayersProvider).value;
  final ratings = ref.watch(ratingResultProvider).value;
  final settings = ref.watch(schedulerSettingsProvider).value;
  if (players == null || ratings == null || settings == null) return null;
  if (draft.attendees.isEmpty || draft.teams.isEmpty) return null;

  return scheduleTeams(
    teams: [
      for (final team in draft.teams)
        TeamSetup(
          name: team.name,
          slots:
              compositionNamed(settings.scheduler, team.composition)?.slots ??
              const [],
          substitutes: team.substitutes,
        ),
    ],
    // In de volgorde van de spelerslijst: bij gelijke score wint de eerste.
    attendees: [for (final player in players) ?draft.attendees[player.id]],
    players: players,
    ratingOf: ratings.ratingOf,
    stats: ratings.stats,
    prioritizeExperience: draft.prioritizeExperience,
    prioritizeInexperience: draft.prioritizeInexperience,
    config: settings.scheduler,
    ratingConfig: settings.rating,
  );
});
