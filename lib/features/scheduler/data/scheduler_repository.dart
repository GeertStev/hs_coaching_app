import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_core/scheduler/rating_config.dart';
import 'package:hs_coaching_core/scheduler/scheduler_config.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/sheet_import.dart';

/// De instellingen van de Team scheduler: de getallen van de rating-engine en
/// van de ploegindeling.
class SchedulerSettings {
  const SchedulerSettings({
    this.rating = const RatingConfig(),
    this.scheduler = const SchedulerConfig(),
  });

  final RatingConfig rating;
  final SchedulerConfig scheduler;
}

/// Opslag van de Team scheduler: spelerslijst, wedstrijdlog, handmatige
/// aanpassingen en instellingen van de club.
///
/// ```
/// clubs/{clubId}/
///   players/{playerId}            SquadPlayer
///   practiceGames/{gameId}        PracticeGame
///   ratingAdjustments/{id}        RatingAdjustment
///   schedulerConfig/default       {rating: RatingConfig, scheduler: SchedulerConfig}
/// ```
///
/// Alleen de app gebruikt deze gegevens (trainers en clubadmins); het
/// zwembadscherm krijgt later alleen de gekozen opstelling. Ratings staan
/// nergens opgeslagen: zie `ratingResultProvider`.
class SchedulerRepository {
  SchedulerRepository({
    required FirebaseFirestore firestore,
    required String clubId,
  }) : _club = firestore.collection('clubs').doc(clubId),
       _firestore = firestore;

  final FirebaseFirestore _firestore;
  final DocumentReference<Map<String, dynamic>> _club;

  CollectionReference<Map<String, dynamic>> get _players =>
      _club.collection('players');
  CollectionReference<Map<String, dynamic>> get _games =>
      _club.collection('practiceGames');
  CollectionReference<Map<String, dynamic>> get _adjustments =>
      _club.collection('ratingAdjustments');
  DocumentReference<Map<String, dynamic>> get _config =>
      _club.collection('schedulerConfig').doc('default');

  // ------------------------------------------------------------- lezen

  /// Alle spelers, op document-id. Voor spelers uit het blad is dat de
  /// volgorde van de spelerslijst daar; de ploegindeling gebruikt die
  /// volgorde bij gelijke scores.
  Stream<List<SquadPlayer>> watchPlayers() => _players.snapshots().map(
    (snap) => [
      for (final doc in snap.docs)
        SquadPlayer.fromJson(doc.data()).copyWith(id: doc.id),
    ]..sort((a, b) => a.id.compareTo(b.id)),
  );

  /// Het hele wedstrijdlog, oudste eerst.
  Stream<List<PracticeGame>> watchGames() => _games.snapshots().map(
    (snap) =>
        [
          for (final doc in snap.docs)
            PracticeGame.fromJson(doc.data()).copyWith(id: doc.id),
        ]..sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          return byDate != 0 ? byDate : a.id.compareTo(b.id);
        }),
  );

  Stream<List<RatingAdjustment>> watchAdjustments() =>
      _adjustments.snapshots().map(
        (snap) =>
            [
              for (final doc in snap.docs)
                RatingAdjustment.fromJson(doc.data()).copyWith(id: doc.id),
            ]..sort((a, b) {
              final byStart = a.start.compareTo(b.start);
              return byStart != 0 ? byStart : a.id.compareTo(b.id);
            }),
      );

  /// De instellingen; de standaardwaarden van het blad zolang er niets is
  /// opgeslagen.
  Stream<SchedulerSettings> watchSettings() => _config.snapshots().map((doc) {
    final data = doc.data();
    if (data == null) return const SchedulerSettings();
    final rating = data['rating'];
    final scheduler = data['scheduler'];
    return SchedulerSettings(
      rating: rating is Map<String, dynamic>
          ? RatingConfig.fromJson(rating)
          : const RatingConfig(),
      scheduler: scheduler is Map<String, dynamic>
          ? SchedulerConfig.fromJson(scheduler)
          : const SchedulerConfig(),
    );
  });

  // ---------------------------------------------------------- schrijven

  /// Bewaart een speler. Zonder id wordt een nieuwe speler aangemaakt; het
  /// nieuwe id komt terug.
  Future<String> savePlayer(SquadPlayer player) =>
      _save(_players, player.id, player.toJson());

  /// Bewaart een wedstrijd. Een nieuwe wedstrijd krijgt een id dat met de
  /// datum begint, zodat wedstrijden van dezelfde dag in volgorde van
  /// invoeren blijven staan.
  Future<String> saveGame(PracticeGame game, {required int nowMillis}) {
    final id = game.id.isNotEmpty
        ? game.id
        : '${game.date}-${nowMillis.toString().padLeft(15, '0')}';
    return _save(_games, id, game.toJson());
  }

  Future<void> deleteGame(String gameId) => _games.doc(gameId).delete();

  Future<String> saveAdjustment(RatingAdjustment adjustment) =>
      _save(_adjustments, adjustment.id, adjustment.toJson());

  Future<void> deleteAdjustment(String id) => _adjustments.doc(id).delete();

  Future<void> saveSettings(SchedulerSettings settings) => _config.set({
    'rating': settings.rating.toJson(),
    'scheduler': settings.scheduler.toJson(),
  });

  /// Zet de export van het Teamscheduler-blad in Firestore. Bestaande
  /// documenten met hetzelfde id worden overschreven (opnieuw importeren is
  /// veilig); spelers, wedstrijden en aanpassingen die in de app zijn
  /// toegevoegd blijven staan. De instellingen van de ploegindeling blijven
  /// zoals ze zijn.
  Future<void> importSheet(SheetImport import) async {
    final writes =
        <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[
          for (final player in import.players)
            (_players.doc(player.id), player.toJson()),
          for (final game in import.games) (_games.doc(game.id), game.toJson()),
          for (final adjustment in import.adjustments)
            (_adjustments.doc(adjustment.id), adjustment.toJson()),
        ];
    // Een batch mag hoogstens 500 schrijfacties bevatten.
    for (var start = 0; start < writes.length; start += _batchSize) {
      final batch = _firestore.batch();
      for (final (ref, data) in writes.skip(start).take(_batchSize)) {
        batch.set(ref, data);
      }
      await batch.commit();
    }
    await _config.set({
      'rating': import.config.toJson(),
    }, SetOptions(merge: true));
  }

  static const _batchSize = 400;

  Future<String> _save(
    CollectionReference<Map<String, dynamic>> collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ref = id.isEmpty ? collection.doc() : collection.doc(id);
    await ref.set(data);
    return ref.id;
  }
}
