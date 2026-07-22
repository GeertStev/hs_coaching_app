# HS Coaching App — Project Guide (for AI-assisted development)

Coaching / tactics / sketchboard app for **underwater hockey**. Two Flutter apps share
one Firebase backend:

1. **Control app (this repo, Android)** — coaches create content (sketches, images, texts,
   timers, chronos, teams, game score) and push it live.
2. **Display web app (separate repo)** — reads the same Firestore/Storage and renders on a
   big screen in the swimming pool.

State flows one way: **control app writes → Firestore → display app reads**. Realtime sync is
the core requirement; UI must feel instant (optimistic updates, see below).

> Role for the AI: senior Flutter dev. Upgrade/refactor toward **clean architecture** that is
> **easily testable**, using **Riverpod 3.0, Firebase, Freezed**.

---

## Tech stack

- Flutter, Dart SDK `^3.9.0`
- `flutter_riverpod ^3.0`, `riverpod ^3.0`, `riverpod_annotation ^4.0`, `riverpod_generator ^4.0` (codegen deps present but **not used yet** — all providers are hand-written)
- `firebase_core 4`, `firebase_auth 6`, `cloud_firestore 6`, `firebase_storage 13`, `firebase_messaging 16`
- `freezed ^3.2` + `freezed_annotation ^3.1`, `json_serializable`, `json_annotation`
- `perfect_freehand` (sketch drawing), `flutter_svg 2`, `image_picker`, `image_cropper`, `file_picker`, `uuid`, `intl`
- `custom_lint` + `riverpod_lint` enabled

**Codegen:** run `dart run build_runner build --delete-conflicting-outputs` after touching any
`@freezed` / `fromJson` model. Generated `*.freezed.dart` / `*.g.dart` are committed.

---

## Architecture

Feature-first layout under `lib/features/<feature>/`, each split into
`data/` · `domain/` · `presentation/` (some also `application/` for services). Cross-cutting
code lives in `lib/core/`. `lib/common/` exists but is **empty**.

```
lib/
  main.dart                 # entrypoint; ProviderScope + MaterialApp + AuthGate. Holds a big TODO/prompt block.
  core/
    providers/firebase_providers.dart      # firebaseFirestoreProvider, firebaseStorageProvider
    data/firestore_converters.dart         # TimestampConverter, ServerTimestampConverter (JsonConverters)
    presentation/lazy_indexed_stack.dart
  features/
    auth/          # AuthRepository, authStateChangesProvider, appUserProvider, AuthGate, login/signup
    home/          # HomeScreen: BottomNav (Home | Screen control)
    display/       # THE core feature area
      data/        # displayDeviceIdsProvider (!), display settings repos
      application/ # search_service.dart (SearchNotifier/TagNotifier interfaces)
      presentation/# ContentControlScreen + generic content list/card/edit-dialog scaffolding
      features/    # sub-features, each self-contained data/domain/presentation:
        sketch/    # most complex: command pattern, tools, perfect_freehand, backgrounds
        tabata/    # tree-structured model (grouped exercises) + custom drag-and-drop editor
        image/  text/  chrono/  timer/  game/  team/  tag_and_search/
```

### Firestore data model
Everything is namespaced per display device:
```
clubs/{clubId}                         # Club (name, description)
  members/{uid}                        # ClubMembership: role (player|trainer|clubAdmin),
                                       #   status (pending|active), teamIds, denormalized name/picture,
                                       #   uid+clubId as fields (for collection-group queries)
  teams/{teamId}                       # ClubTeam ("ploegen"; players assigned via membership.teamIds)
  invites/{code}                       # ClubInvite (admin-managed invite codes)
  timerExercises/{id}  timerSets/{id}  # timer library — historically club-level, NOT under
                                       #   displays; read: active members, write: trainer/admin
  displays/{displayId}/
    sketches/{sketchId}/elements/{elementId}
    settings/{sketch|chrono|team|...}  # per-feature control docs (currentId, flags, tags, backgrounds)
inviteCodes/{code}                     # mirror of invites for the join flow: get-only per code
                                       #   (the code is the secret; list is denied by rules)
users/{uid}                            # AppUser (profile, personalInfo, emergencyContacts)
```

### Auth / users / clubs (feature areas `auth/`, `profile/`, `club/`)
- **Roles are per club** (in `ClubMembership`), not global: `player`, `trainer`, `clubAdmin`.
  `AppUser.role` remains as a legacy/global field (default `'user'`).
- Join flows: request membership (creates `members/{uid}` with `status: pending`, admin approves)
  or an **invite code** (8-char code, direct `active` join; validated by security rules via the
  `inviteCode` field against `inviteCodes/{code}`). Users can be member of multiple clubs
  (collection-group query on `members.uid` — needs the **collection-group index on `uid`**,
  defined as a fieldOverride in `firestore.indexes.json`).
- `firestore.rules` + `firestore.indexes.json` at repo root hold rules and indexes, wired up in
  `firebase.json`; deploy both with `firebase deploy --only firestore` (no `--force` — the
  project has extra auto-created indexes not in the file). Display subtree is world-readable for
  the display web app; writes require trainer/clubAdmin.
  There's no `.firebaserc`, so pass `--project hs-coaching` explicitly (or use
  `--only firestore:rules` to deploy just the rules file).
  **Gotcha:** a rule already being correct and committed in `firestore.rules` does not mean
  it's live — the file only takes effect after an explicit deploy. Hit this with the
  `tabataPresets` rule (`isActiveMember(clubId)`, correct in the repo) still returning
  `PERMISSION_DENIED` in the running app; the fix was simply running the deploy above. If a
  rule "looks right" but a request is still denied, check whether it's actually been deployed
  before assuming the rule logic itself is wrong.
- **Riverpod 3 auto-retry gotcha:** a provider whose stream fails (e.g. missing index →
  `failed-precondition`) is retried with backoff by default; Firestore then re-emits cached data
  before each new failure, so the UI flickers loading↔data and the real error (incl. the
  index-creation link) never surfaces. Global fix in `core/providers/riverpod_config.dart`:
  `appProviderRetry` (no retry on permanent Firebase codes, max 5 otherwise) +
  `AppProviderObserver` (logs provider failures to the debug console), both registered on the
  `ProviderScope` in `main.dart`.
- Controllers follow the house style: `AsyncNotifier<void>` + `AsyncValue.guard`
  (`authControllerProvider`, `profileControllerProvider`, `clubControllerProvider`).
  Dutch error mapping in `auth/presentation/auth_error_messages.dart` and
  `clubErrorMessage` in `club/presentation/my_clubs_screen.dart`.
- Profile pictures live in Storage at `user_pictures/{uid}.jpg`.
`clubId`/`displayId` come from **`displayDeviceIdsProvider`** — currently **hardcoded**
`(clubId: 'holySquid', displayDeviceId: 'bilzen')`. Nearly every repository provider depends on it.

### Repository pattern (the established convention)
Repositories are plain classes taking `FirebaseFirestore`/`FirebaseStorage` + `clubId` + `displayId`
via constructor, exposed through a hand-written `Provider` that reads
`firebaseFirestoreProvider` + `displayDeviceIdsProvider`. Example: `sketchRepositoryProvider`,
`chronoRepositoryProvider`, `timerRepositoryProvider`, `teamSettingsRepositoryProvider`.
Only `sketch` has a domain interface (`ISketchRepository`); the others don't.

### Optimistic UI + Command pattern (sketch feature — the reference implementation)
This is the intended pattern for realtime mutations (see `main.dart` prompt block):
- `SketchElementsNotifier` (a `StreamNotifier.family` keyed by `sketchId`) streams elements from
  Firestore and exposes `addOrUpdateOptimistically` / `removeOptimistically` that set
  `state = AsyncData(...)` **before** the network write.
- `Command` classes (`AddElementCommand`, `RemoveElementCommand`, `UpdateElementCommand` in
  `sketch/domain/command.dart`) take a `Ref`, apply the optimistic update, then write to the repo,
  and **roll back** the local state on error. `execute`/`undo` support undo/redo.

### Tabata (grouped exercises) — tree model + custom drag-and-drop (reference example)
The Tabata editor is the codebase's reference example for **tree-structured content** and for
**drag-and-drop**, neither of which existed anywhere else before this feature:
- Domain shape (`tabata/domain/`): `TabataExercise` (leaf card: rounds/work/rest/`stepSeconds`,
  the last generalizing the old beeptest decrement to allow both shrinking (`-`) and growing (`+`)
  work per round) and `TabataGroup` (container: `rounds` + `restBetweenRepeats` for the whole
  group, `children: List<TabataExercise>`, **one level deep only** — no nested groups). Both are
  unified as `TabataItem`, a Freezed **sealed union** (`.exercise(...)` / `.group(...)`) — the
  first union type in this codebase; see its `.g.dart` for the discriminator shape
  (`{'exercise'|'group': {...}, 'runtimeType': 'exercise'|'group'}`). Every item (exercise or
  group) carries its own `restAfter`: rest before the *next sibling* in whatever list it's part
  of (top-level `Tabata.items`, or a group's `children`), ignored when it's the last element of
  that list.
- Duration/progress engine (`tabata.dart`): `Tabata._flatten(items)` walks the whole tree once
  into a linear list of work/rest steps (handling group repeats, inter-child rest, and
  inter-item rest uniformly); `totalDurationMillis`/`progressAt` are simple scans over that flat
  list. Prefer this "flatten to a timeline, then scan" shape over nested loops for any
  future feature with tree-shaped timing — it's what made group-repeat rest solvable without the
  progress model turning into a maze of special cases.
- Reorder/group/ungroup logic lives in `tabata_item_tree.dart` — pure functions
  (`moveItem`, `groupWithTarget`, `removeItem`, `replaceExercise`, ...) operating on
  `List<TabataItem>`, Flutter-free and unit-tested (`test/.../tabata_item_tree_test.dart`).
  The UI (`tabata_control_screen.dart`) only wires `LongPressDraggable`/`DragTarget` around
  cards and insert-gaps and calls into these functions — it never manipulates the tree itself.
  `removeItem` auto-collapses a group down to a plain exercise when it's left with one child,
  and drops it entirely when left with none.
- **No legacy-shape migration, on purpose.** Unlike Sketch's documented `_normalizeLegacyName`
  pattern, `TabataRepository` reads/writes only the current `items` shape — an earlier version
  of this feature added migration for older `sets`/flat document shapes, but there was no real
  legacy data to protect, so it was deliberately removed. Don't add migration shims for a model
  unprompted; only do it when there's actual data in the field that needs it.

### Riverpod 3.0 conventions in force (from `main.dart` prompt)
- No `FamilyNotifier`/`FamilyAsyncNotifier`/`FamilyStreamNotifier` — use base `Notifier`/`AsyncNotifier`/`StreamNotifier` and pass family args through the **constructor**, stored as instance vars; `build()` takes no params.
- Use `.value` on `AsyncValue`, never `.valueOrNull`.
- Prefer `AsyncNotifierProvider.autoDispose` for mutation controllers (e.g. `sketchControllerProvider`).
- Controllers (e.g. `SketchController`) are `AsyncNotifier<void>` and wrap writes in `AsyncValue.guard`.

### Language note
Code comments and some UI strings are in **Dutch**. 
For UI strings, use **English**.
For code comments, use **Dutch**.
No localization layer (`intl` is only used for formatting).

---

## Prioritized problem list

### P0 — Correctness bugs (fix first) — ✅ done
1. ~~**`SketchRepository.archiveSketch` never archives.**~~ Fixed: now sets `SketchStatus.archived.name`
   (`sketch_repository.dart`).
2. ~~**`http` used but not declared**~~ Fixed: added as a direct dependency in `pubspec.yaml`.

### P1 — Testability & architecture (the stated goal)
3. **No tests at all** — no `test/` dir. Repositories are constructor-injected (good), so start with
   unit tests using `fake_cloud_firestore` + provider `overrides`. The sketch command/optimistic
   flow is the highest-value target.
   **Partially started:** `test/features/display/features/tabata/domain/` now covers the
   progress/duration engine and the tree helper (pure Dart, no Firestore needed) — follow this
   as the template for other features' domain logic before tackling the `fake_cloud_firestore`
   repository-layer work, which is still untouched everywhere.
4. **Hardcoded `displayDeviceIdsProvider`** (`holySquid`/`bilzen`). Blocks multi-club/multi-display
   use and any integration test that isn't that exact device. Replace with a real setup/config flow
   (local storage / login-derived) and make it overridable in tests.
5. ~~**Freezed only half-adopted.**~~ **Done.** `Sketch`, `SketchBackground`, `Team`/`Player`,
   `DisplayImage`, `DisplayText`, `GameSettings`, `DisplayContentSettings`, `DisplayGlobalSettings`
   are now all `@freezed`. Notes on how it was done:
   - New shared converters in `core/data/firestore_converters.dart`: `TimestampOrNowConverter`
     (non-null `DateTime`, reads Timestamp-or-now, writes the given value — used by
     `Sketch.lastModified`) and `ServerWriteTimestampConverter` (same read behavior, but `toJson`
     always emits a fresh `FieldValue.serverTimestamp()`, ignoring the model's value — used by
     `DisplayImage`/`DisplayText`'s creation `timestamp`, replicating their original "always
     server-authoritative on write" behavior).
   - `Team.fromJson` (2-arg legacy signature taking the raw Google-Script map + a `TeamColor`)
     was renamed to `Team.fromGoogleScriptResponse(data, teamColor)` so the standard freezed
     `fromJson(Map<String,dynamic>)` could be generated normally; `team_repository.dart` updated.
   - `DisplayGlobalSettings`'s per-field color defaults (blue/green/amber/black) are expressed as
     **named const constructors** on `ColorFromHexConverter` (`.blue()`, `.green()`, ...) — a plain
     constructor-argument converter (`ColorFromHexConverter(Colors.blue)`) is **not supported** by
     json_serializable as a field annotation ("Generators with constructor arguments are not
     supported"). If you add another converter needing a per-field default, use this pattern.
   - **Gotcha:** freezed/json_serializable only auto-detect and generate the `.g.dart` glue when a
     model's `factory X.fromJson(...)` body is the plain one-line
     `factory X.fromJson(Map<String, dynamic> json) => _$XFromJson(json);` form. A custom/multi-statement
     body (e.g. to normalize legacy fields before decoding) silently breaks codegen for that file
     (no error — `.g.dart` just doesn't get generated). `Sketch`'s legacy `name`→`title` migration was
     therefore moved out of the domain model and into `sketch_repository.dart`'s `fromFirestore`
     converter (`_normalizeLegacyName`), keeping `Sketch.fromJson` in the canonical one-line form.
     Prefer this "normalize in the repository, keep the model's fromJson canonical" pattern for any
     future legacy-field shims.
   - `SketchBackground`'s old `==`/`hashCode` compared by `url` only; nothing in the codebase actually
     relied on that (call sites compare `.url` directly), so it now uses freezed's full-field equality.
   - Always run `dart run build_runner build` after touching these files and confirm both
     `*.freezed.dart` and `*.g.dart` were (re)written — if `.g.dart` is missing, suspect the
     `fromJson` canonical-form gotcha above before anything else.
   - **Gotcha: `explicitToJson: true` must be set at *every* nesting level, not just the
     outermost model.** json_serializable only calls `.toJson()` on a nested Freezed
     object/union when the class *containing* that field has `explicitToJson: true`; otherwise
     it embeds the raw Dart object straight into the generated map. This compiles fine and
     `flutter analyze`/unit tests that only check Dart-level round-trips won't catch it — it
     only blows up at the serialization boundary itself, e.g. Firestore's
     `StandardMessageCodec` throwing `Invalid argument: Instance of '_TabataExercise'`. Hit this
     with the Tabata tree model: `Tabata` had the annotation (so `items.map((e) => e.toJson())`
     was correct) but `TabataGroup` (its `children` field) and `TabataItem` (its `exercise`/
     `group` payload) didn't, so *their* generated `toJson()` embedded the raw nested object.
     Fixed by adding `@JsonSerializable(explicitToJson: true)` to every constructor that holds
     another Freezed model or a `List`/union of them, then regenerating. For any model with
     nested Freezed types (especially unions or `List<SomeFreezedType>`), add a regression test
     that actually calls `.toJson()` on it (e.g. `jsonEncode(model.toJson())`) — a test that
     never calls `toJson()` cannot catch this.
6. **Repository abstraction is leaky/uneven.** Only sketch has an interface (`ISketchRepository`).
   `TeamSettingsRepository.watchTeamSettings()` returns a raw `DocumentSnapshot` to the provider layer
   (`team_repository.dart:105`) — domain code shouldn't touch Firestore types. Add thin interfaces or
   map to domain models at the repo boundary.

### P2 — Riverpod modernization & consistency
7. **Riverpod codegen unused.** `riverpod_generator`/`riverpod_annotation` are dependencies but every
   provider is hand-written. Either adopt `@riverpod` codegen consistently (better family ergonomics,
   fewer typos) or drop the unused deps — pick one and apply project-wide.
8. **Duplicated `ServerTimestampConverter`** — defined in `core/data/firestore_converters.dart` **and**
   inline in `chrono.dart`. Consolidate on the `core` converters everywhere.
9. **`teamRepositoryProvider` fetches from a hardcoded Google Apps Script URL** (`team_repository.dart:17`)
   with cache-busting timestamps — brittle and unconfigurable. Move the URL to config; consider migrating
   team data into Firestore like every other feature.

### P3 — Robustness / cleanup
10. **Non-atomic deletes.** `SketchRepository.clearSketch` deletes element docs in a loop instead of a
    `WriteBatch` (unlike `hardDeleteSketch`, which batches). Use batched/atomic deletes throughout.
11. **`archiveSketch` untyped cast** — reads then conditionally clears current via
    `(... as Map<String, dynamic>?)['currentId']`; fragile. Fold into the model + a batch.
12. **`main.dart` cleanup** — carries a large commented-out TODO/AI-prompt block and the app title
    still says "HS Coaching Sketch". Move TODOs to issues.
13. **Minimal error handling** — most `AsyncValue.guard` errors surface only as `Text('Error: $err')`.
    No logging/crash reporting. Consider a shared error presenter + `firebase_crashlytics`.
14. **Empty `lib/common/`** — use it for shared widgets/utilities or remove it.

---

## Working agreements
- After editing any Freezed/JSON model, **regenerate** with build_runner before assuming it compiles.
- Follow the **sketch feature** as the canonical example for new realtime features (repo → StreamNotifier
  with optimistic methods → Command classes with rollback → autoDispose AsyncNotifier controller).
- Follow the **tabata feature** as the canonical example for tree-structured/groupable content and for
  drag-and-drop (pure-Dart tree ops in a dedicated `*_item_tree.dart` file, `LongPressDraggable`/
  `DragTarget` only in the widget layer, "flatten to a timeline" for any tree-shaped timing).
- Keep repositories free of Flutter/Firestore leakage at their public boundary so they stay unit-testable.
- Match existing Dutch comments/strings in a given file; don't introduce a translation layer unprompted.
