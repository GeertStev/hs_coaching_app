import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_app/features/scheduler/domain/schedule_draft.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/team_scheduler_screen.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/team/team_lineup.dart';

const _f = PlayerPosition.forward;
const _g = PlayerPosition.goalie;

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final repository = SchedulerRepository(
      firestore: firestore,
      clubId: 'holySquid',
    );
    // Veertien spelers p01..p14 die overal kunnen spelen.
    for (var i = 1; i <= 14; i++) {
      final id = 'p${i.toString().padLeft(2, '0')}';
      await repository.savePlayer(
        SquadPlayer(
          id: id,
          firstName: 'Player $i',
          nickname: id,
          positions: PlayerPosition.values,
          startRatings: {
            _f: 1400 + 30 * i,
            PlayerPosition.center: 1450 + 20 * i,
            PlayerPosition.wing: 1500 + 10 * i,
            _g: 1300 + 25 * i,
          },
        ),
      );
    }
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        schedulerTodayProvider.overrideWithValue('2026-11-16'),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const TeamSchedulerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ScheduleDraftController controller() =>
      container.read(scheduleDraftProvider.notifier);

  testWidgets('twaalf aanwezigen vullen White en Black met 2-3-1', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Make teams (0 present)'), findsOneWidget);
    expect(container.read(scheduleResultProvider), isNull);

    for (var i = 1; i <= 12; i++) {
      await tester.tap(
        find.byKey(ValueKey('attend-p${i.toString().padLeft(2, '0')}')),
      );
    }
    await tester.pumpAndSettle();

    expect(find.text('Make teams (12 present)'), findsOneWidget);
    final result = container.read(scheduleResultProvider)!;
    expect(result.unassigned, isEmpty);
    expect([for (final t in result.teams) t.name], ['White', 'Black']);
    for (final team in result.teams) {
      expect(team.base, hasLength(6));
    }
    expect(find.textContaining('% Black'), findsOneWidget);
    expect(find.textContaining('No place for'), findsNothing);

    // Een dertiende speler heeft geen plaats tot er een wissel bij komt.
    await tester.tap(find.byKey(const ValueKey('attend-p13')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No place for'), findsOneWidget);

    await tester.tap(find.byTooltip('More substitutes').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('No place for'), findsNothing);
    expect(find.textContaining('sub: '), findsOneWidget);
    expect(
      container.read(scheduleResultProvider)!.teams.first.subs,
      hasLength(1),
    );

    await tester.tap(find.text('Clear attendance'));
    await tester.pumpAndSettle();
    expect(find.text('Make teams (0 present)'), findsOneWidget);
  });

  testWidgets('vaste positie en vaste ploeg via de keuzelijsten', (
    tester,
  ) async {
    for (var i = 1; i <= 12; i++) {
      controller().setAttending('p${i.toString().padLeft(2, '0')}', true);
    }
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('position-p01')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goalie').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('team-p01')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Black').last);
    await tester.pumpAndSettle();

    final result = container.read(scheduleResultProvider)!;
    expect(
      result.teams[1].base,
      contains(const LineupEntry(playerId: 'p01', position: _g)),
    );
    expect(result.unassigned, isEmpty);
  });

  testWidgets('Send to pool screen schrijft de opstelling en zet Team actief', (
    tester,
  ) async {
    for (var i = 1; i <= 13; i++) {
      controller().setAttending('p${i.toString().padLeft(2, '0')}', true);
    }
    controller().setSubstitutes(0, _f, 1);
    await pumpScreen(tester);

    await tester.tap(find.text('Send to pool screen'));
    await tester.pumpAndSettle();
    expect(find.text('Lineup sent to the pool screen.'), findsOneWidget);

    final display = firestore
        .collection('clubs')
        .doc('holySquid')
        .collection('displays')
        .doc('bilzen')
        .collection('settings');
    final team = (await display.doc('team').get()).data()!;
    final teams = teamsFromLineup(team)!;
    expect(teams, hasLength(2));
    final result = container.read(scheduleResultProvider)!;
    // Basisspelers eerst, dan de wissel, met de roepnaam zoals in het blad.
    expect(
      [for (final p in teams.first.front) p.name],
      [
        for (final e in [
          ...result.teams.first.base,
          ...result.teams.first.subs,
        ])
          if (e.position == _f) e.playerId,
      ],
    );
    expect(teams.first.front, hasLength(3));
    expect((await display.doc('content').get()).data()!['contentType'], 'team');
  });

  testWidgets(
    'Save result bewaart een oefenwedstrijd en herrekent de ratings',
    (tester) async {
      for (var i = 1; i <= 12; i++) {
        controller().setAttending('p${i.toString().padLeft(2, '0')}', true);
      }
      await pumpScreen(tester);
      final before = container.read(ratingResultProvider).value!;
      final schedule = container.read(scheduleResultProvider)!;

      await tester.tap(find.text('Save result'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('score-white')), '5');
      await tester.enterText(find.byKey(const ValueKey('score-black')), '2');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Result saved. Ratings are updated.'), findsOneWidget);

      final games = container.read(practiceGamesProvider).value!;
      expect(games, hasLength(1));
      final game = games.single;
      expect(game.date, '2026-11-16');
      expect(game.durationMinutes, 30);
      expect(game.white.score, 5);
      expect(game.black.score, 2);
      expect(game.white.composition, '2-3-1');
      expect(game.white.base, schedule.teams[0].base);
      expect(game.black.base, schedule.teams[1].base);

      // Een winnaar van wit stijgt op zijn positie.
      final winner = schedule.teams[0].base.first;
      final after = container.read(ratingResultProvider).value!;
      expect(
        after.ratingOf(winner.playerId, winner.position),
        greaterThan(before.ratingOf(winner.playerId, winner.position)!),
      );
    },
  );

  test('ploegen toevoegen, hernoemen en verwijderen', () {
    final draft = controller();
    draft.setAttending('p01', true);
    draft.setFixedTeam('p01', 'Black');
    draft.addTeam(const ['White', 'Black', 'Lila']);
    expect(
      [for (final t in container.read(scheduleDraftProvider).teams) t.name],
      ['White', 'Black', 'Lila'],
    );
    expect(
      container.read(scheduleDraftProvider).teams.last.composition,
      '2-3-1',
    );

    // Hernoemen neemt de vaste ploeg mee; een bestaande naam wordt geweigerd.
    draft.setTeamName(1, 'Guest');
    draft.setTeamName(2, 'White');
    var state = container.read(scheduleDraftProvider);
    expect([for (final t in state.teams) t.name], ['White', 'Guest', 'Lila']);
    expect(state.attendees['p01']!.fixedTeam, 'Guest');

    // Een andere opstelling wist de wissels.
    draft.setSubstitutes(0, _f, 2);
    draft.setComposition(0, '2-2');
    state = container.read(scheduleDraftProvider);
    expect(state.teams[0].composition, '2-2');
    expect(state.teams[0].substitutes, isEmpty);

    draft.removeTeam(1);
    state = container.read(scheduleDraftProvider);
    expect([for (final t in state.teams) t.name], ['White', 'Lila']);
    expect(state.attendees['p01']!.fixedTeam, isNull);

    // Zonder vrije naam krijgt de ploeg een nummer.
    draft.addTeam(const ['White', 'Lila']);
    expect(container.read(scheduleDraftProvider).teams.last.name, 'Team 3');
  });
}
