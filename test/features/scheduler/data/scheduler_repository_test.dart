import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/scheduler/rating_config.dart';
import 'package:hs_coaching_core/scheduler/rating_engine.dart';
import 'package:hs_coaching_core/scheduler/scheduler_config.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/sheet_import.dart';

/// De export van het blad zonder namen, uit de tests van core.
final _fixture = File(
  '../hs_coaching_core/test/scheduler/fixtures/teamscheduler_sheet.json',
).readAsStringSync();

void main() {
  late FakeFirebaseFirestore firestore;
  late SchedulerRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = SchedulerRepository(firestore: firestore, clubId: 'holySquid');
  });

  test('een speler bewaren en teruglezen, met een nieuw id', () async {
    const player = SquadPlayer(
      firstName: 'Test',
      nickname: 'T',
      positions: [PlayerPosition.forward, PlayerPosition.goalie],
      startRatings: {PlayerPosition.forward: 1500, PlayerPosition.goalie: 1200},
    );
    final id = await repository.savePlayer(player);
    expect(id, isNotEmpty);
    final stored = await repository.watchPlayers().first;
    expect(stored, [player.copyWith(id: id)]);

    await repository.savePlayer(stored.single.copyWith(active: false));
    expect((await repository.watchPlayers().first).single.active, isFalse);
  });

  test(
    'wedstrijden van dezelfde dag blijven in volgorde van invoeren',
    () async {
      PracticeGame game(int white) => PracticeGame(
        date: '2026-11-16',
        durationMinutes: 30,
        white: GameSide(
          score: white,
          base: const [
            LineupEntry(playerId: 'a', position: PlayerPosition.forward),
          ],
        ),
        black: const GameSide(
          score: 0,
          subs: [LineupEntry(playerId: 'b', position: PlayerPosition.wing)],
        ),
      );
      await repository.saveGame(
        game(9).copyWith(date: '2026-11-17'),
        nowMillis: 1000,
      );
      final second = await repository.saveGame(game(2), nowMillis: 3000);
      await repository.saveGame(game(1), nowMillis: 2000);
      var games = await repository.watchGames().first;
      expect([for (final g in games) g.white.score], [1, 2, 9]);
      expect(games.first.black.subs.single.playerId, 'b');

      // Een bestaande wedstrijd verbeteren houdt het id.
      await repository.saveGame(
        games[1].copyWith(white: games[1].white.copyWith(score: 5)),
        nowMillis: 9000,
      );
      games = await repository.watchGames().first;
      expect([for (final g in games) g.white.score], [1, 5, 9]);
      expect(games[1].id, second);

      await repository.deleteGame(second);
      expect(await repository.watchGames().first, hasLength(2));
    },
  );

  test('aanpassingen bewaren en verwijderen', () async {
    final id = await repository.saveAdjustment(
      const RatingAdjustment(
        playerId: 'a',
        type: RatingAdjustmentType.linear,
        start: '2026-01-01',
        end: '2026-02-01',
        change: -50,
        reason: 'Injury',
      ),
    );
    expect((await repository.watchAdjustments().first).single.id, id);
    await repository.deleteAdjustment(id);
    expect(await repository.watchAdjustments().first, isEmpty);
  });

  test(
    'instellingen: standaardwaarden zonder document, daarna de bewaarde',
    () async {
      final defaults = await repository.watchSettings().first;
      expect(defaults.rating, const RatingConfig());
      expect(defaults.scheduler, const SchedulerConfig());

      await repository.saveSettings(
        const SchedulerSettings(
          rating: RatingConfig(streakBonus: 5),
          scheduler: SchedulerConfig(gameMinutes: 20),
        ),
      );
      final stored = await repository.watchSettings().first;
      expect(stored.rating.streakBonus, 5);
      expect(stored.rating.rankTiers, hasLength(31));
      expect(stored.scheduler.gameMinutes, 20);
    },
  );

  group('import van het blad', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          schedulerTodayProvider.overrideWithValue('2026-11-15'),
        ],
      );
      addTearDown(container.dispose);
    });

    test(
      'zet alles in Firestore en geeft dezelfde ratings als de engine',
      () async {
        await repository.saveSettings(
          const SchedulerSettings(scheduler: SchedulerConfig(gameMinutes: 20)),
        );
        final import = await container.read(
          Provider((ref) => importSheetExport(ref, _fixture)),
        );
        expect(import.players, hasLength(80));

        expect(await repository.watchPlayers().first, import.players);
        expect(await repository.watchGames().first, hasLength(166));
        expect(await repository.watchAdjustments().first, hasLength(34));
        final settings = await repository.watchSettings().first;
        expect(settings.rating, import.config);
        // De instellingen van de indeling blijven staan.
        expect(settings.scheduler.gameMinutes, 20);

        // Opnieuw importeren maakt geen dubbels.
        await repository.importSheet(import);
        expect(await repository.watchGames().first, hasLength(166));

        container.listen(ratingResultProvider, (_, _) {});
        await container.read(squadPlayersProvider.future);
        await container.read(practiceGamesProvider.future);
        await container.read(ratingAdjustmentsProvider.future);
        await container.read(schedulerSettingsProvider.future);
        final result = container.read(ratingResultProvider).value!;

        expect(container.read(ratingAsOfProvider), '2026-11-16');
        final expected = computeRatings(
          players: import.players,
          games: import.games,
          adjustments: import.adjustments,
          asOf: '2026-11-16',
          config: import.config,
        );
        expect(result.ratings, hasLength(expected.ratings.length));
        for (final entry in expected.ratings.entries) {
          expect(result.ratings[entry.key], closeTo(entry.value, 1e-9));
        }
      },
    );

    test('een ander bestand geeft een fout en schrijft niets', () async {
      await expectLater(
        container.read(Provider((ref) => importSheetExport(ref, '[1, 2]'))),
        throwsFormatException,
      );
      await expectLater(
        container.read(
          Provider(
            (ref) => importSheetExport(ref, jsonEncode({'schemaVersion': 99})),
          ),
        ),
        throwsA(isA<SheetImportException>()),
      );
      expect(await repository.watchPlayers().first, isEmpty);
    });
  });
}
