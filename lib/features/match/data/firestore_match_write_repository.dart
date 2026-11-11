import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/firestore_match_repository.dart';
import 'package:hs_coaching_core/match/match_meta.dart';
import 'package:hs_coaching_core/match/match_repository.dart';

/// Schrijfkant van de wedstrijdopslag in Firestore. Breidt de alleen-lezen
/// `FirestoreMatchRepository` uit core uit, zoals de andere repositories in
/// deze app.
///
/// De regels worden op twee plekken afgedwongen: hier (voor een duidelijke
/// foutmelding) en in `firestore.rules` (als echte beveiliging):
/// - events zijn append-only: aanmaken mag, wijzigen of verwijderen nooit;
/// - alleen het toestel met de lease mag events schrijven;
/// - per veld is hooguit één wedstrijd live.
class FirestoreMatchWriteRepository extends FirestoreMatchRepository
    implements MatchWriteRepository {
  FirestoreMatchWriteRepository({
    required super.firestore,
    required super.clubId,
  });

  @override
  Future<void> createMatch(
    String matchId, {
    required int createdAtMillis,
    String? tournamentId,
    String? fieldId,
  }) {
    final meta = MatchMeta(
      createdAtMillis: createdAtMillis,
      tournamentId: tournamentId,
      fieldId: fieldId,
    );
    return matchRef(matchId).set(meta.toJson());
  }

  @override
  Future<void> acquireLease(
    String matchId, {
    required String deviceId,
    required int nowMillis,
    bool takeOver = false,
  }) {
    // Een transactie: twee toestellen die tegelijk de lease nemen mogen niet
    // allebei slagen. Dit werkt alleen met verbinding, en dat is de bedoeling:
    // een overname zonder verbinding is niet te controleren.
    return firestore.runTransaction((transaction) async {
      final meta = await _readMeta(transaction, matchId);
      final lease = meta.lease;
      if (lease != null && lease.deviceId == deviceId) return;
      if (lease != null && !takeOver) throw LeaseHeldException(lease.deviceId);
      transaction.update(matchRef(matchId), {
        'lease': MatchLease(
          deviceId: deviceId,
          sinceMillis: nowMillis,
        ).toJson(),
      });
    });
  }

  @override
  Future<void> releaseLease(String matchId, {required String deviceId}) {
    return firestore.runTransaction((transaction) async {
      final meta = await _readMeta(transaction, matchId);
      if (meta.lease?.deviceId != deviceId) return;
      transaction.update(matchRef(matchId), {'lease': null});
    });
  }

  /// Bewust **geen** transactie: een gewone write komt offline in de
  /// wachtrij van de Firestore-SDK en wordt later verstuurd, met het
  /// oorspronkelijke tijdstip van de tik erin. Het document-id is het
  /// volgnummer; `firestore.rules` laat alleen aanmaken toe, dus een tweede
  /// event met hetzelfde nummer wordt door de server geweigerd.
  @override
  Future<void> append(MatchEvent event) {
    return eventsRef(event.matchId).doc('${event.seq}').set(event.toJson());
  }

  @override
  Future<void> goLive(String matchId, {required String fieldId}) {
    return firestore.runTransaction((transaction) async {
      // Eerst alles lezen, dan pas schrijven (eis van Firestore-transacties).
      final meta = await _readMeta(transaction, matchId);
      final current = await _liveMatchId(transaction, fieldId);
      if (current != null && current != matchId) {
        throw FieldBusyException(current);
      }
      final previous = meta.liveFieldId;
      final previousHoldsMatch =
          previous != null &&
          previous != fieldId &&
          await _liveMatchId(transaction, previous) == matchId;

      // Stond de wedstrijd op een ander veld live, dan komt dat veld vrij.
      if (previousHoldsMatch) {
        transaction.set(fieldRef(previous), {
          'liveMatchId': null,
        }, SetOptions(merge: true));
      }
      transaction.set(fieldRef(fieldId), {
        'liveMatchId': matchId,
      }, SetOptions(merge: true));
      transaction.update(matchRef(matchId), {'liveFieldId': fieldId});
    });
  }

  @override
  Future<void> endLive(String matchId) {
    return firestore.runTransaction((transaction) async {
      final meta = await _readMeta(transaction, matchId);
      final fieldId = meta.liveFieldId;
      if (fieldId == null) return;
      final holdsMatch = await _liveMatchId(transaction, fieldId) == matchId;
      if (holdsMatch) {
        transaction.set(fieldRef(fieldId), {
          'liveMatchId': null,
        }, SetOptions(merge: true));
      }
      transaction.update(matchRef(matchId), {'liveFieldId': null});
    });
  }

  Future<MatchMeta> _readMeta(Transaction transaction, String matchId) async {
    final snapshot = await transaction.get(matchRef(matchId));
    final data = snapshot.data();
    if (data == null) throw MatchNotFoundException(matchId);
    return MatchMeta.fromJson(data);
  }

  Future<String?> _liveMatchId(Transaction transaction, String fieldId) async {
    final snapshot = await transaction.get(fieldRef(fieldId));
    return snapshot.data()?['liveMatchId'] as String?;
  }
}
