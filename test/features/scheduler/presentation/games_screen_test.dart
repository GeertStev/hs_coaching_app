import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_app/features/scheduler/presentation/games_screen.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';

const _f = PlayerPosition.forward;

void main() {
  late FakeFirebaseFirestore firestore;
  late SchedulerRepository repository;
  late ProviderContainer container;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = SchedulerRepository(firestore: firestore, clubId: 'holySquid');
    await repository.savePlayer(
      const SquadPlayer(id: 'ann', firstName: 'Ann', startRatings: {_f: 1500}),
    );
    await repository.savePlayer(
      const SquadPlayer(id: 'bob', firstName: 'Bob', startRatings: {_f: 1500}),
    );
    await repository.saveGame(
      const PracticeGame(
        id: 'g1',
        date: '2026-11-10',
        durationMinutes: 30,
        white: GameSide(
          score: 4,
          base: [LineupEntry(playerId: 'ann', position: _f)],
        ),
        black: GameSide(
          score: 1,
          base: [LineupEntry(playerId: 'bob', position: _f)],
        ),
      ),
      nowMillis: 1,
    );
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        schedulerTodayProvider.overrideWithValue('2026-11-16'),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.dark(), home: const GamesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('toont de wedstrijd, past de uitslag aan en verwijdert ze', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('White 4 - 1 Black'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('game-g1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ann'), findsWidgets);

    final before = container.read(ratingResultProvider).value!;
    await tester.tap(find.text('Edit result'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('score-white')), '0');
    await tester.enterText(find.byKey(const ValueKey('score-black')), '6');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('White 0 - 6 Black'), findsOneWidget);
    final games = container.read(practiceGamesProvider).value!;
    expect(games.single.id, 'g1');
    expect(games.single.black.score, 6);
    // De ratings volgen de verbeterde uitslag: Ann zakt nu.
    final after = container.read(ratingResultProvider).value!;
    expect(after.ratingOf('ann', _f), lessThan(before.ratingOf('ann', _f)!));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(container.read(practiceGamesProvider).value, isEmpty);
    expect(find.textContaining('No games'), findsOneWidget);
  });
}
