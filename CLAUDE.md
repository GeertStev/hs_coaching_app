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
- `shared_preferences` — only consumer so far is the persisted light/dark/system theme preference
  (`core/theme/theme_mode_controller.dart`), see "Theming" below
- `custom_lint` + `riverpod_lint` enabled
- Fonts (`Anybody`, `Hanken Grotesk`, `JetBrains Mono`) are bundled as local assets under
  `assets/google_fonts/` and declared in `pubspec.yaml`'s `fonts:` block — **not** the
  `google_fonts` package, which fetches over the network at runtime by default. See "Theming"
  below.

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
    providers/riverpod_config.dart         # appProviderRetry, AppProviderObserver
    providers/shared_preferences_provider.dart # sharedPreferencesProvider, overridden in main()
    presentation/lazy_indexed_stack.dart
    theme/                                 # AppColors{Dark,Light}/AppTypography/AppMetrics/AppTheme/
                                            # ThemeModeController — see "Theming" below
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

### Theming (`lib/core/theme/`)
Design system source of truth: `DESIGN_dark.md` (the original file, renamed) and `DESIGN_light.md`
(added later) — both "Kinetic Performance System" / "Kinetic Performance: Aquatic Edition", same
type scale and spacing/radius grid, different color tokens. `AppTheme.dark()`/`AppTheme.light()`
each assemble everything below into a `ThemeData`; `MainApp` in `main.dart` passes both to
`MaterialApp` (`theme`/`darkTheme`) and picks between them via `themeMode`, driven by
`theme_mode_controller.dart`'s persisted user preference (see "Theme selection" below) — **not**
`ThemeMode.system` alone, since the user asked for an explicit in-app toggle.

- **`app_colors.dart`** — every color token from both design files as a `const Color`, in two
  classes (`AppColorsDark`, `AppColorsLight`), each assembled into its own `const colorScheme`.
  `background`/`on-background`/`surface-variant` are deliberately **not** ported from either file:
  they're byte-identical to `surface`/`on-surface`/`surface-container-highest`, and the matching
  `ColorScheme` fields have been deprecated since Flutter 3.18.
- **`app_typography.dart`** — `AppTypography`, a `ThemeExtension` holding the 9 named text styles
  shared by both design files' `typography` block (`timerDisplay`, `headlineLg/Md/Sm`,
  `headlineLgMobile`, `bodyLg/Md`, `labelCaps`, `dataPoint`). A `ThemeExtension` rather than
  stuffing these into `TextTheme`, because the names don't correspond to Material's slots — there's
  no `TextTheme.timerDisplay`. The scale itself (font/size/weight/lineHeight/letterSpacing) doesn't
  differ between the two design files — only the text *color* does — so `AppTypography.kinetic()`
  takes `onSurface` as its one parameter instead of being duplicated per theme.
- **`app_metrics.dart`** — `AppMetrics`, a `ThemeExtension` for the shared `spacing`
  (`xs`/`sm`/`md`/`lg`/`xl`/`unit`/`containerMargin`/`gutter`/`cardPadding`) and `rounded`
  (`radiusSm`/`radiusDefault`/`radiusMd`/`radiusLg`/`radiusXl`/`radiusFull`) scales — identical
  between light and dark, so still a single `AppMetrics.kinetic()`. Same `ThemeExtension` treatment
  as typography, so both use the same `Theme.of(context)` access pattern instead of scattered
  top-level constants.
- **`app_theme.dart`** — `AppTheme.dark()`/`AppTheme.light()` each build a `ThemeData`:
  - `colorScheme: AppColorsDark.colorScheme` / `AppColorsLight.colorScheme`.
  - `textTheme` starts from `Typography.material2021(colorScheme: colorScheme).white` (dark) or
    `.black` (light) `.apply(fontFamily: 'Hanken Grotesk')` (so every default Material slot picks
    up the right typeface even where the design file has no opinion), then `.copyWith(...)`
    overrides the 5 tokens that *do* have a natural Material home: `headlineLarge/Medium/Small` ←
    `headlineLg/Md/Sm`, `bodyLarge/Medium` ← `bodyLg/Md`.
  - `cardTheme` / `inputDecorationTheme` / `chipTheme` — see "Global component theming" below; the
    two themes genuinely diverge here, not just by color-token substitution.
  - `extensions: [AppTypography.kinetic(onSurface: ...), AppMetrics.kinetic()]`.

**Theme selection:** `theme_mode_controller.dart`'s `ThemeModeController` (`Notifier<ThemeMode>`)
persists the user's light/dark/system choice via `shared_preferences_provider.dart`'s
`sharedPreferencesProvider`, overridden in `main()` with the instance from
`SharedPreferences.getInstance()` resolved *before* `runApp` (same pattern as
`Firebase.initializeApp`) so `build()` can stay synchronous like every other Riverpod 3 Notifier
here, no `AsyncNotifier` needed. `MainApp` watches `themeModeControllerProvider` and feeds it
straight to `MaterialApp.themeMode`. The toggle itself is a `SegmentedButton<ThemeMode>` in
`ProfileScreen`'s "Weergave" section (`profile_screen.dart`'s `_buildAppearanceSection`).

**Access pattern — which token, from where:**
- The 5 tokens with a Material slot (`headlineLg/Md/Sm`, `bodyLg/Md`): just use
  `Theme.of(context).textTheme.headlineLarge` etc. — the cascade already resolves to the current
  theme's value, no need to reach for the extension.
- The 4 orphan tokens with no Material slot (`timerDisplay`, `dataPoint`, `labelCaps`,
  `headlineLgMobile`): `Theme.of(context).appTypography.timerDisplay`.
- Spacing/radius: always `Theme.of(context).appMetrics.spacingMd` / `.radiusDefault` etc. — never
  a bare number, even one that happens to match a token's value. This is what caught real 4px-grid
  violations already in the codebase before theming touched them (a stray `10.0` padding, a
  `runSpacing: -2.0` hack) — neither was on the grid either design file mandates.
- **Gotcha:** the extension getters are named `appTypography`/`appMetrics`, not
  `typography`/`metrics`. `ThemeData` already has its own `typography` field (Flutter's
  font-scaling class, unrelated to ours); an extension getter with that same name compiles fine
  but is silently shadowed by the built-in field, so the mistake only surfaces at the *call site*
  (`'bodyLg' isn't defined for type 'Typography'`), not where the extension is declared. Don't
  rename these back to the shorter form.

**Global component theming:** shape/elevation/border for a *widget kind* belongs in
`AppTheme.dark()`/`.light()`, never hardcoded per-instance — a widget should only override the
theme for a genuinely per-instance state (e.g. `ContentItemCard`'s `isCurrent` border color, which
uses `colorScheme.primary` in both themes — the "currently showing" highlight is Athletic Blue per
both design files' "Elevation & Depth" sections, not a token that should vary by theme).
- `cardTheme`: dark's "Elevation & Depth" calls for `radiusDefault` corners, a 1px 10%-white inner
  border, a soft shadow, `Clip.antiAlias`. Light's calls for something visually different, not just
  a color swap of the same tokens: "active containers (like cards) use **white** surfaces to pop
  against the off-white background" — i.e. light's *lightest* container reads as "raised" (the
  opposite tonal direction from dark, where the *darkest* container did) — so light's `cardTheme`
  sets an explicit `color: colorScheme.surfaceContainerLowest` and a subtle `outlineVariant` border
  instead of dark's translucent-white inner border. `colorScheme.surfaceTint` is deliberately left
  alone in both (not zeroed) — both design files give an explicit `surface-tint` token, so M3's
  tint-on-elevation behavior is intentional, not an artifact to suppress.
- `inputDecorationTheme`: dark's "Input Fields" wants a fill "darker than the card background" and
  a 2px **Energy Yellow** (`secondary`) focus underline. Light's wants the same "recessed" fill
  concept but a 2px **Athletic Blue** (`primary`) focus underline instead — a genuine per-theme
  difference in the design, not an oversight. The recessed-fill token also can't be copy-pasted by
  name: dark's fill is `colorScheme.surfaceContainerLowest`, which in the *dark* palette is darker
  than `surface` (M3's tonal roles run the other way in dark mode) — but in the *light* palette
  `surfaceContainerLowest` is `#FFFFFF`, i.e. the brightest tone, the one `cardTheme` above uses for
  the "raised card" look. Using it again for light's input fill would make inputs indistinguishable
  from cards. Light's `inputDecorationTheme` instead fills with `colorScheme.surfaceContainerHighest`
  (the darkest grey in the light container scale) to actually read as recessed. **When porting any
  future per-theme tonal choice, check whether the token's *semantic role* (not just its name)
  still points the same direction in both palettes before reusing it as-is** — this bit both the
  input fill and (per `content_item_card.dart`'s fix above) a hardcoded `colorScheme.secondary`
  border that used to read as Energy Yellow in dark but would've been a dull brown in light,
  since `secondary` (not `secondaryContainer`) is the vivid-yellow-bearing token only in dark's
  palette. Don't set a local `border:`/`fillColor:` on a `TextFormField`/`TextField` unless it
  genuinely needs to differ from every other field in the app — it silently overrides this theme.
- `chipTheme`: `StadiumBorder()` (fully pill-shaped) in both themes, covers `Chip`/`FilterChip`/
  `InputChip` alike — no difference described in either design file's "Shapes" section.

**Fonts:** only the specific static weights the type scale actually calls for are bundled — Anybody
600/700/800, Hanken Grotesk 400/500, JetBrains Mono 600/700. **Don't request a weight outside that
set** (e.g. Hanken Grotesk 700) — Flutter will silently synthesize a faux-bold from the nearest
available weight instead of erroring, which degrades typeface fidelity without any warning.

**No green in the palette:** both design files' colors are deliberately narrow — Athletic Blue
(`primary`) for active/"Work"/positive states, Energy Yellow (`secondary`/`secondaryContainer`) for
rest/countdown/warning states, plus neutrals and `error`. There is no green. Established convention
when a status needs a "success" color (verified, approved, usable): reuse `colorScheme.primary`,
not a raw `Colors.green` — keeps every color in the app traceable to the token sheet instead of
introducing an unspec'd hue. Same idea for "neutral/disabled" (`colorScheme.onSurfaceVariant`, not
`Colors.grey`) and "destructive" (`colorScheme.error`, not `Colors.red`).

Rolled out so far: all of `display/presentation/` (the shared list/card/tile/FAB/dialog widgets),
the `tag_and_search/` feature, and `auth/`/`club/`/`profile/`. Apply the same tokens and patterns
to any new screen — reach for `AppColorsDark`/`AppColorsLight`/`Theme.of(context).appTypography`/
`.appMetrics` rather than `Colors.*`, a bare `TextStyle(...)`, or a magic-number
`SizedBox`/`EdgeInsets`.

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
- Use `lib/core/theme/` (`AppColors`/`AppTypography`/`AppMetrics`/`AppTheme`) for all styling on
  any new or touched widget — see "Theming" above. Never hardcode a `Colors.*`, a bare
  `TextStyle(...)`, a magic-number `SizedBox`/`EdgeInsets`, or a per-instance `Card`/`Chip`/
  `TextField` shape/border that the global theme should already provide.
- Follow the **sketch feature** as the canonical example for new realtime features (repo → StreamNotifier
  with optimistic methods → Command classes with rollback → autoDispose AsyncNotifier controller).
- Follow the **tabata feature** as the canonical example for tree-structured/groupable content and for
  drag-and-drop (pure-Dart tree ops in a dedicated `*_item_tree.dart` file, `LongPressDraggable`/
  `DragTarget` only in the widget layer, "flatten to a timeline" for any tree-shaped timing).
- Keep repositories free of Flutter/Firestore leakage at their public boundary so they stay unit-testable.
- Match existing Dutch comments/strings in a given file; don't introduce a translation layer unprompted.
