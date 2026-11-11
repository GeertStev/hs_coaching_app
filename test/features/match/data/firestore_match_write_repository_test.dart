import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/match/data/firestore_match_write_repository.dart';
import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/match_repository.dart';
import 'package:hs_coaching_core/match/match_session.dart';
import 'package:hs_coaching_core/team/team_model.dart';

const _white = TeamColor.white;
const _created = MatchEventData.matchCreated(
  config: MatchConfig(requiresWinner: true),
  teamWhite: 'Wit',
  teamBlack: 'Zwart',
  fieldId: 'veld-1',
);

/// Geeft de streams van de nep-Firestore tijd om hun snapshots af te leveren.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

/// De nieuwste waarde van een stream. De nep-Firestore levert vlak na een
/// write soms eerst nog een oude snapshot af; daarom even meeluisteren en de
/// laatst afgeleverde waarde nemen.
Future<T> _latest<T>(Stream<T> stream) async {
  late T latest;
  var seen = false;
  final subscription = stream.listen((value) {
    latest = value;
    seen = true;
  });
  await _settle();
  await _settle();
  await subscription.cancel();
  if (!seen) throw StateError('Stream leverde geen waarde af');
  return latest;
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreMatchWriteRepository repository;
  var now = 1700000000000;
  var ids = 0;

  MatchSession session(String matchId, String deviceId) => MatchSession(
    matchId: matchId,
    repository: repository,
    deviceId: deviceId,
    nowServerMs: () => now,
    newEventId: () => 'id-${++ids}',
  );

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreMatchWriteRepository(
      firestore: firestore,
      clubId: 'holySquid',
    );
    await repository.createMatch(
      'm1',
      createdAtMillis: now,
      tournamentId: 'bk',
      fieldId: 'veld-1',
    );
  });

  test('02 §6 paden en inhoud van de documenten', () async {
    await repository.acquireLease('m1', deviceId: 'tafel-A', nowMillis: now);
    await repository.append(
      MatchEvent(
        id: 'e1',
        matchId: 'm1',
        seq: 1,
        serverTimeMillis: now,
        deviceId: 'tafel-A',
        data: _created,
      ),
    );

    final match = await firestore.doc('clubs/holySquid/matches/m1').get();
    expect(match.data()!['tournamentId'], 'bk');
    expect(match.data()!['fieldId'], 'veld-1');
    expect(match.data()!['lease'], {'deviceId': 'tafel-A', 'sinceMillis': now});

    // Het document-id is het volgnummer.
    final event = await firestore
        .doc('clubs/holySquid/matches/m1/events/1')
        .get();
    expect(event.data()!['seq'], 1);
    expect(event.data()!['serverTimeMillis'], now);
    final data = event.data()!['data'] as Map<String, dynamic>;
    expect(data['type'], 'matchCreated');
    // Geneste modellen zijn als gewone maps bewaard, duren als milliseconden.
    expect((data['config'] as Map<String, dynamic>)['periodLength'], 900000);

    final events = await _latest(repository.watchEvents('m1'));
    expect(events.single.data, _created);
    final meta = await _latest(repository.watchMeta('m1'));
    expect(meta!.lease!.deviceId, 'tafel-A');
    expect(await _latest(repository.watchMeta('bestaat-niet')), isNull);
  });

  test('02 §6 events komen gesorteerd op seq terug, ook boven de 9', () async {
    await repository.acquireLease('m1', deviceId: 'tafel-A', nowMillis: now);
    for (final seq in [2, 11, 1, 10, 3]) {
      await repository.append(
        MatchEvent(
          id: 'e$seq',
          matchId: 'm1',
          seq: seq,
          serverTimeMillis: now + seq,
          deviceId: 'tafel-A',
          data: const MatchEventData.protestLogged(
            team: _white,
            by: 'Kapitein',
            text: 'x',
          ),
        ),
      );
    }
    final events = await _latest(repository.watchEvents('m1'));
    expect(events.map((event) => event.seq), [1, 2, 3, 10, 11]);
  });

  test(
    '02 §6a T15: tweede toestel geweigerd, expliciete overname lukt',
    () async {
      final tableA = session('m1', 'tafel-A');
      final tableB = session('m1', 'tafel-B');
      await tableA.takeLease();
      await _settle();
      tableA
        ..add(_created)
        ..add(const MatchEventData.playStarted());
      await tableA.pendingWrites;
      await _settle();

      expect(tableB.state.phase, MatchPhase.p1);
      expect(
        () => tableB.add(const MatchEventData.goalScored(team: _white)),
        throwsA(isA<NotLeaseHolderException>()),
      );
      await expectLater(
        tableB.takeLease(),
        throwsA(
          isA<LeaseHeldException>().having(
            (e) => e.holderDeviceId,
            'holderDeviceId',
            'tafel-A',
          ),
        ),
      );

      now += 60000;
      await tableB.takeLease(takeOver: true);
      await _settle();
      expect(tableB.holdsLease, isTrue);
      expect(tableA.holdsLease, isFalse);
      tableB.add(const MatchEventData.goalScored(team: _white, scorerCap: 4));
      await tableB.pendingWrites;
      await _settle();
      expect(
        () => tableA.add(const MatchEventData.playStarted()),
        throwsA(isA<NotLeaseHolderException>()),
      );

      // Unieke, opeenvolgende seq; geen verloren of dubbel event.
      final events = await _latest(repository.watchEvents('m1'));
      expect(events.map((event) => event.seq), [1, 2, 3]);
      expect(events.map((event) => event.deviceId), [
        'tafel-A',
        'tafel-A',
        'tafel-B',
      ]);
      expect(tableA.state.score.white, 1);
      expect(
        tableA.state.goals.single.elapsedInPhase,
        const Duration(minutes: 1),
      );

      await tableA.dispose();
      await tableB.dispose();
    },
  );

  test('02 §6a lease nemen op een onbekende wedstrijd faalt', () async {
    await expectLater(
      repository.acquireLease('weg', deviceId: 'tafel-A', nowMillis: now),
      throwsA(isA<MatchNotFoundException>()),
    );
  });

  test('02 §6a de lease vrijgeven kan alleen door de houder', () async {
    await repository.acquireLease('m1', deviceId: 'tafel-A', nowMillis: now);
    await repository.releaseLease('m1', deviceId: 'tafel-B');
    expect(
      (await _latest(repository.watchMeta('m1')))!.lease!.deviceId,
      'tafel-A',
    );
    await repository.releaseLease('m1', deviceId: 'tafel-A');
    expect((await _latest(repository.watchMeta('m1')))!.lease, isNull);
    await repository.acquireLease('m1', deviceId: 'tafel-B', nowMillis: now);
    expect(
      (await _latest(repository.watchMeta('m1')))!.lease!.deviceId,
      'tafel-B',
    );
  });

  test('04 §3 T18: tweede wedstrijd live zetten op een bezet veld wordt '
      'geweigerd', () async {
    await repository.createMatch('m2', createdAtMillis: now);
    await repository.goLive('m1', fieldId: 'veld-1');
    expect(await _latest(repository.watchLiveMatchId('veld-1')), 'm1');
    expect((await _latest(repository.watchMeta('m1')))!.liveFieldId, 'veld-1');
    final field = await firestore.doc('clubs/holySquid/fields/veld-1').get();
    expect(field.data(), {'liveMatchId': 'm1'});

    await expectLater(
      repository.goLive('m2', fieldId: 'veld-1'),
      throwsA(
        isA<FieldBusyException>().having(
          (e) => e.liveMatchId,
          'liveMatchId',
          'm1',
        ),
      ),
    );
    expect((await _latest(repository.watchMeta('m2')))!.isLive, isFalse);
    expect(await _latest(repository.watchLiveMatchId('veld-1')), 'm1');

    // Dezelfde wedstrijd nog eens, en een ander veld, mogen wel.
    await repository.goLive('m1', fieldId: 'veld-1');
    await repository.goLive('m2', fieldId: 'veld-2');

    await repository.endLive('m1');
    expect(await _latest(repository.watchLiveMatchId('veld-1')), isNull);
    expect((await _latest(repository.watchMeta('m1')))!.isLive, isFalse);
    await repository.goLive('m2', fieldId: 'veld-1');
    expect(await _latest(repository.watchLiveMatchId('veld-1')), 'm2');
    // m2 verhuisde: veld 2 is weer vrij.
    expect(await _latest(repository.watchLiveMatchId('veld-2')), isNull);
    expect(await _latest(repository.watchLiveMatchId('veld-3')), isNull);
  });

  test('02 §6b 3 wedstrijden tegelijk op 3 velden', () async {
    final sessions = <MatchSession>[];
    for (var field = 1; field <= 3; field++) {
      final matchId = 'match-$field';
      await repository.createMatch(
        matchId,
        createdAtMillis: now,
        fieldId: 'veld-$field',
      );
      final table = session(matchId, 'tafel-$field');
      await table.takeLease();
      await repository.goLive(matchId, fieldId: 'veld-$field');
      sessions.add(table);
    }
    await _settle();

    for (final table in sessions) {
      table.add(_created);
    }
    now += 10000;
    sessions[0].add(const MatchEventData.playStarted());
    now += 30000;
    sessions[1].add(const MatchEventData.playStarted());
    now += 60000;
    sessions[0].add(const MatchEventData.goalScored(team: _white));
    sessions[2].add(const MatchEventData.playStarted());
    now += 60000;
    for (final table in sessions) {
      await table.pendingWrites;
    }
    await _settle();

    expect(sessions[0].state.score.white, 1);
    expect(sessions[1].state.score.white, 0);
    expect(sessions[2].state.score.white, 0);
    expect(
      sessions[0].clock.periodRemaining,
      const Duration(minutes: 12, seconds: 30),
    );
    expect(sessions[1].clock.periodRemaining, const Duration(minutes: 13));
    expect(sessions[2].clock.periodRemaining, const Duration(minutes: 14));

    // Een scherm dat alleen leest ziet per wedstrijd hetzelfde als de tafel.
    for (final table in sessions) {
      final viewer = await _latest(repository.watch(table.matchId));
      expect(viewer.score, table.state.score);
      expect(viewer.phase, table.state.phase);
      expect(viewer.lastSeq, table.state.lastSeq);
      final events = await _latest(repository.watchEvents(table.matchId));
      expect(events.every((event) => event.matchId == table.matchId), isTrue);
      await table.dispose();
    }
    expect(await _latest(repository.watchLiveMatchId('veld-3')), 'match-3');
  });
}
