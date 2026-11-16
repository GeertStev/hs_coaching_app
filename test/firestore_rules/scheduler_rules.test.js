// Tests van de regels van de Team scheduler in firestore.rules tegen de
// Firestore-emulator. Draaien: `npm install` en daarna `npm test` in deze map.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
} from 'firebase/firestore';

const club = 'clubs/holySquid';
// Elke collectie van de Team scheduler met een voorbeelddocument.
const documents = {
  'players/001': { firstName: 'Test', active: true, startRatings: { F: 1500 } },
  'practiceGames/2026-11-16-1': {
    date: '2026-11-16',
    durationMinutes: 30,
    white: { score: 3, base: [], subs: [] },
    black: { score: 2, base: [], subs: [] },
  },
  'ratingAdjustments/a1': {
    playerId: '001',
    type: 'instant',
    start: '2026-11-16',
    end: '2026-11-16',
    change: 50,
  },
  'schedulerConfig/default': { rating: { eloScale: 400 } },
};
let env;

before(async () => {
  // Een eigen project-id: de testbestanden draaien tegelijk en mogen elkaars
  // gegevens niet wissen.
  env = await initializeTestEnvironment({
    projectId: 'demo-hs-coaching-scheduler',
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
    // Een trainer van een andere club.
    await setDoc(doc(db, 'clubs/andere/members/vreemd'), {
      uid: 'vreemd',
      clubId: 'andere',
      role: 'trainer',
      status: 'active',
    });
    for (const [path, data] of Object.entries(documents)) {
      await setDoc(doc(db, `${club}/${path}`), data);
    }
  });
});

for (const [path, data] of Object.entries(documents)) {
  const name = path.split('/')[0];

  for (const uid of ['trainer', 'admin']) {
    test(`${name}: ${uid} mag lezen, lijsten, schrijven en verwijderen`, async () => {
      const db = env.authenticatedContext(uid).firestore();
      await assertSucceeds(getDoc(doc(db, `${club}/${path}`)));
      await assertSucceeds(getDocs(collection(db, `${club}/${name}`)));
      await assertSucceeds(setDoc(doc(db, `${club}/${name}/nieuw`), data));
      await assertSucceeds(setDoc(doc(db, `${club}/${path}`), data));
      await assertSucceeds(deleteDoc(doc(db, `${club}/${path}`)));
    });
  }

  for (const uid of ['speler', 'wachtend', 'vreemd']) {
    test(`${name}: ${uid} mag niets`, async () => {
      const db = env.authenticatedContext(uid).firestore();
      await assertFails(getDoc(doc(db, `${club}/${path}`)));
      await assertFails(getDocs(collection(db, `${club}/${name}`)));
      await assertFails(setDoc(doc(db, `${club}/${name}/nieuw`), data));
      await assertFails(deleteDoc(doc(db, `${club}/${path}`)));
    });
  }

  test(`${name}: zonder login mag niets`, async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, `${club}/${path}`)));
    await assertFails(getDocs(collection(db, `${club}/${name}`)));
    await assertFails(setDoc(doc(db, `${club}/${path}`), data));
  });
}
