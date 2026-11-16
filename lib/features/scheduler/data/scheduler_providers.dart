import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_repository.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/scheduler/rating_engine.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/sheet_import.dart';

/// De opslag van de Team scheduler van de club. Hangt niet aan een display,
/// dus alleen het `clubId` uit `displayDeviceIdsProvider` wordt gebruikt.
final schedulerRepositoryProvider = Provider<SchedulerRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return SchedulerRepository(firestore: firestore, clubId: ids.clubId);
});

final squadPlayersProvider = StreamProvider<List<SquadPlayer>>(
  (ref) => ref.watch(schedulerRepositoryProvider).watchPlayers(),
);

final practiceGamesProvider = StreamProvider<List<PracticeGame>>(
  (ref) => ref.watch(schedulerRepositoryProvider).watchGames(),
);

final ratingAdjustmentsProvider = StreamProvider<List<RatingAdjustment>>(
  (ref) => ref.watch(schedulerRepositoryProvider).watchAdjustments(),
);

final schedulerSettingsProvider = StreamProvider<SchedulerSettings>(
  (ref) => ref.watch(schedulerRepositoryProvider).watchSettings(),
);

/// De kalenderdag van vandaag als `yyyy-MM-dd`. Ververst zichzelf om
/// middernacht; tests overschrijven deze provider.
final schedulerTodayProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(midnight.difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return isoDate(now);
});

/// `yyyy-MM-dd` van een lokale datum.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// De dag waarop de ratings berekend worden: morgen, net als in het blad.
/// Een aanpassing die vandaag ingaat telt zo al mee.
final ratingAsOfProvider = Provider<String>((ref) {
  final today = DateTime.parse(ref.watch(schedulerTodayProvider));
  return isoDate(DateTime(today.year, today.month, today.day + 1));
});

/// De huidige ratings, speeltijd en doelpunten van alle spelers. Wordt
/// opnieuw berekend zodra een speler, wedstrijd, aanpassing of instelling
/// verandert; er wordt niets van opgeslagen.
final ratingResultProvider = Provider<AsyncValue<RatingResult>>((ref) {
  final players = ref.watch(squadPlayersProvider);
  final games = ref.watch(practiceGamesProvider);
  final adjustments = ref.watch(ratingAdjustmentsProvider);
  final settings = ref.watch(schedulerSettingsProvider);
  final asOf = ref.watch(ratingAsOfProvider);

  for (final value in <AsyncValue<Object?>>[
    players,
    games,
    adjustments,
    settings,
  ]) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.current);
    }
  }
  final playerList = players.value;
  final gameList = games.value;
  final adjustmentList = adjustments.value;
  final config = settings.value?.rating;
  if (playerList == null ||
      gameList == null ||
      adjustmentList == null ||
      config == null) {
    return const AsyncLoading();
  }
  return AsyncData(
    computeRatings(
      players: playerList,
      games: gameList,
      adjustments: adjustmentList,
      asOf: asOf,
      config: config,
    ),
  );
});

/// Leest de JSON-export van het Teamscheduler-blad en zet die in Firestore.
/// Geeft terug wat er is ingelezen. Gooit een [SheetImportException] of een
/// [FormatException] bij een ongeldig bestand.
Future<SheetImport> importSheetExport(Ref ref, String json) async {
  final decoded = jsonDecode(json);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Not a Teamscheduler export');
  }
  final import = parseSheetExport(decoded);
  await ref.read(schedulerRepositoryProvider).importSheet(import);
  return import;
}
