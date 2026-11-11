// Tests van de wedstrijdregels in firestore.rules tegen de Firestore-emulator.
// Draaien: `npm install` en daarna `npm test` in deze map (heeft Java nodig).
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  runTransaction,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const club = 'clubs/holySquid';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-hs-coaching',
    firestore: {
      rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const member = (uid, role, status = 'active') =>
      setDoc(doc(db, `${club}/members/${uid}`), {
        uid,
        clubId: 'holySquid',
        role,
        status,
      });
    await member('trainer', 'trainer');
    await member('admin', 'clubAdmin');
    await member('speler', 'player');
    await member('wachtend', 'trainer', 'pending');
    for (const matchId of ['m1', 'm2', 'm3']) {
      await setDoc(doc(db, `${club}/matches/${matchId}`), {
        createdAtMillis: 1,
        tournamentId: null,
        fieldId: null,
        lease: null,
        liveFieldId: null,
      });
    }
  });
});

const trainer = () => env.authenticatedContext('trainer').firestore();
const event = (matchId, seq, deviceId) => ({
  id: `e-${matchId}-${seq}`,
  matchId,
  seq,
  serverTimeMillis: 1000 + seq,
  deviceId,
  source: 'screen',
  data: { type: 'playStarted' },
});
const append = (db, matchId, seq, deviceId) =>
  setDoc(doc(db, `${club}/matches/${matchId}/events/${seq}`), event(matchId, seq, deviceId));
const takeLease = (db, matchId, deviceId) =>
  updateDoc(doc(db, `${club}/matches/${matchId}`), {
    lease: { deviceId, sinceMillis: 5 },
  });

// Zelfde stappen als FirestoreMatchWriteRepository.goLive.
const goLive = (db, matchId, fieldId) =>
  runTransaction(db, async (transaction) => {
    const field = await transaction.get(doc(db, `${club}/fields/${fieldId}`));
    const current = field.data()?.liveMatchId ?? null;
    if (current !== null && current !== matchId) throw new Error('field-busy');
    transaction.set(doc(db, `${club}/fields/${fieldId}`), { liveMatchId: matchId }, { merge: true });
    transaction.update(doc(db, `${club}/matches/${matchId}`), { liveFieldId: fieldId });
  });

test('rollen: lezen mag iedereen, schrijven alleen trainer of clubadmin', async () => {
  const anonymous = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(anonymous, `${club}/matches/m1`)));
  await assertSucceeds(getDoc(doc(anonymous, `${club}/matches/m1/events/1`)));
  await assertSucceeds(getDoc(doc(anonymous, `${club}/fields/veld-1`)));

  const newMatch = { createdAtMillis: 2, lease: null, liveFieldId: null };
  await assertFails(setDoc(doc(anonymous, `${club}/matches/nieuw`), newMatch));
  for (const uid of ['speler', 'wachtend', 'vreemde']) {
    const db = env.authenticatedContext(uid).firestore();
    await assertFails(setDoc(doc(db, `${club}/matches/nieuw-${uid}`), newMatch));
    await assertFails(takeLease(db, 'm1', 'tafel-X'));
    await assertFails(setDoc(doc(db, `${club}/fields/veld-1`), { liveMatchId: 'm1' }));
  }
  for (const uid of ['trainer', 'admin']) {
    const db = env.authenticatedContext(uid).firestore();
    await assertSucceeds(setDoc(doc(db, `${club}/matches/nieuw-${uid}`), newMatch));
  }
  await assertFails(deleteDoc(doc(trainer(), `${club}/matches/m1`)));
});

test('events zijn append-only: geen update, geen delete, geen dubbel seq', async () => {
  const db = trainer();
  await takeLease(db, 'm1', 'tafel-A');
  await assertSucceeds(append(db, 'm1', 1, 'tafel-A'));

  // Hetzelfde volgnummer nog eens is een update en dus verboden.
  await assertFails(append(db, 'm1', 1, 'tafel-A'));
  await assertFails(
    updateDoc(doc(db, `${club}/matches/m1/events/1`), { serverTimeMillis: 1 }),
  );
  await assertFails(deleteDoc(doc(db, `${club}/matches/m1/events/1`)));
  const admin = env.authenticatedContext('admin').firestore();
  await assertFails(deleteDoc(doc(admin, `${club}/matches/m1/events/1`)));

  // Document-id en inhoud moeten kloppen.
  await assertFails(
    setDoc(doc(db, `${club}/matches/m1/events/7`), event('m1', 2, 'tafel-A')),
  );
  await assertFails(
    setDoc(doc(db, `${club}/matches/m1/events/2`), event('m2', 2, 'tafel-A')),
  );
  const speler = env.authenticatedContext('speler').firestore();
  await assertFails(append(speler, 'm1', 2, 'tafel-A'));
  await assertSucceeds(append(db, 'm1', 2, 'tafel-A'));
});

test('T15: zonder lease geweigerd, na expliciete overname schrijft alleen het nieuwe toestel', async () => {
  const db = trainer();
  // Nog niemand heeft de lease.
  await assertFails(append(db, 'm1', 1, 'tafel-A'));

  await takeLease(db, 'm1', 'tafel-A');
  await assertSucceeds(append(db, 'm1', 1, 'tafel-A'));
  // Toestel B opent dezelfde wedstrijd: geweigerd.
  await assertFails(append(db, 'm1', 2, 'tafel-B'));

  // Overname door B: A wordt alleen-lezen.
  await takeLease(db, 'm1', 'tafel-B');
  await assertFails(append(db, 'm1', 2, 'tafel-A'));
  await assertSucceeds(append(db, 'm1', 2, 'tafel-B'));
  // A probeert het door B gebruikte nummer te overschrijven: geweigerd.
  await assertFails(append(db, 'm1', 2, 'tafel-A'));

  const second = await getDoc(doc(db, `${club}/matches/m1/events/2`));
  assert.equal(second.data().deviceId, 'tafel-B');
});

test('T18: tweede wedstrijd live zetten op een bezet veld wordt geweigerd', async () => {
  const db = trainer();
  await assertSucceeds(goLive(db, 'm1', 'veld-1'));
  // Via de transactie van de app.
  await assert.rejects(goLive(db, 'm2', 'veld-1'), /field-busy/);
  // En ook een rechtstreekse write die de controle overslaat.
  await assertFails(setDoc(doc(db, `${club}/fields/veld-1`), { liveMatchId: 'm2' }));
  await assertFails(deleteDoc(doc(db, `${club}/fields/veld-1`)));

  // Dezelfde wedstrijd opnieuw mag, en na vrijgeven mag de andere.
  await assertSucceeds(goLive(db, 'm1', 'veld-1'));
  await assertSucceeds(
    setDoc(doc(db, `${club}/fields/veld-1`), { liveMatchId: null }, { merge: true }),
  );
  await assertSucceeds(goLive(db, 'm2', 'veld-1'));
  const field = await getDoc(doc(db, `${club}/fields/veld-1`));
  assert.equal(field.data().liveMatchId, 'm2');
});

test('3 wedstrijden tegelijk op 3 velden, elk met een eigen tafel', async () => {
  const db = trainer();
  const matches = ['m1', 'm2', 'm3'];
  await Promise.all(
    matches.map(async (matchId, index) => {
      await takeLease(db, matchId, `tafel-${index + 1}`);
      await goLive(db, matchId, `veld-${index + 1}`);
    }),
  );
  // Door elkaar schrijven, elk in het eigen log.
  await Promise.all(
    [1, 2, 3].flatMap((seq) =>
      matches.map((matchId, index) =>
        assertSucceeds(append(db, matchId, seq, `tafel-${index + 1}`)),
      ),
    ),
  );
  // Een tafel kan niet in het log van een andere wedstrijd schrijven.
  await assertFails(append(db, 'm2', 4, 'tafel-1'));
  for (const [index, matchId] of matches.entries()) {
    const field = await getDoc(doc(db, `${club}/fields/veld-${index + 1}`));
    assert.equal(field.data().liveMatchId, matchId);
  }
});
