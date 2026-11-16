@../hs_coaching_core/CLAUDE.md

# hs_coaching_app — control app (Android)

The coach's tablet app: create content (sketches, images, texts, chronos, tabatas, trainings,
teams, game score) and push it live to the pool screen. The only app that writes. Role for the AI:
senior Flutter dev, refactoring toward clean, testable architecture with Riverpod 3, Firebase, Freezed.

Extra stack on top of core: `firebase_auth`, `firebase_messaging`, `perfect_freehand` (sketch),
`image_picker`/`image_cropper`/`file_picker`, `shared_preferences` (theme preference only),
`riverpod_lint` (new analyzer-plugin system: `plugins:` in `analysis_options.yaml`, no `custom_lint`). Providers are hand-written (see core's `CLAUDE.md`); no Riverpod codegen.

## Layout
`lib/features/<feature>/{data,domain,presentation}`, cross-cutting code in `lib/core/`
(`presentation/error_display.dart`, `theme/`). The content types live under
`lib/features/display/features/<type>/`; `display/presentation/` holds the shared content
list/card/edit-dialog scaffolding.

UI styling rules load from `.claude/rules/theming.md` when working on presentation code.

## Firestore (app-only parts)
On top of the shared layout in core's `CLAUDE.md`:
```
clubs/{clubId}                  # Club
  members/{uid}                 # ClubMembership: role (player|trainer|clubAdmin), status (pending|active),
                                #   teamIds, uid+clubId as fields for collection-group queries
  teams/{teamId}  invites/{code}  tabataPresets/{id}  trainingTemplates/{id}
  timerExercises/{id}  timerSets/{id}   # legacy timer library, code removed; data + rules remain
  matches/{matchId}/events/{seq}  fields/{fieldId}   # match module, see core's CLAUDE.md
  players/{id}  practiceGames/{id}  ratingAdjustments/{id}  schedulerConfig/default   # Team scheduler
inviteCodes/{code}              # get-only mirror for the join flow (the code is the secret)
users/{uid}                     # AppUser; profile pictures in Storage at user_pictures/{uid}.jpg
```
- Roles are **per club**. Join by request (`pending`, admin approves) or 8-char invite code
  (direct `active`, validated by rules against `inviteCodes/{code}`).
- Membership lookup is a collection-group query on `members.uid` (index in `firestore.indexes.json`).
- Display subtree is world-readable; writes need trainer/clubAdmin.
- Deploy rules + indexes: `firebase deploy --only firestore --project hs-coaching` (no `--force`;
  the project has auto-created indexes not in the file). A rule committed in `firestore.rules` is
  not live until deployed: check that first when a request is unexpectedly `PERMISSION_DENIED`.

## Patterns to follow
- **Repositories** extend core's `Display<X>Repository` to add writes (see core's `CLAUDE.md`).
- **Realtime mutations → sketch feature** is the reference: `SketchElementsNotifier`
  (`StreamNotifier`) exposes `addOrUpdateOptimistically`/`removeOptimistically` that set
  `state = AsyncData(...)` before the write; `Command` classes (`sketch/domain/command.dart`) take a
  `Ref`, apply the optimistic update, write, roll back on error, and support undo/redo.
- **Mutation controllers**: `AsyncNotifier<void>` + `AsyncValue.guard`, preferably
  `AsyncNotifierProvider.autoDispose` (e.g. `authControllerProvider`, `clubControllerProvider`).
- **Tree-structured content and drag-and-drop → training feature** is the reference: pure, Flutter-free
  tree ops in `training/domain/training_tree.dart` (unit-tested in `test/`), max depth enforced via
  core's `training_validation.dart`; widgets only wire `LongPressDraggable`/`DragTarget`
  (`training_drag_drop.dart`) and call `training_mutations.dart`.
- **Training session control**: `TrainingScreenController` only derives progress
  (`trainingProgressAt`); timed steps advance by elapsed time on both devices. The app writes the
  pointer (`currentStepIndex`) only on Start/Next/Previous/Reset.
- **Errors** (see core's `CLAUDE.md`): `core/presentation/error_display.dart` has `ErrorView`
  (for `.when(error: ...)`, with a retry that invalidates the provider), `showErrorSnackBar`, and
  `listenForMutationErrors` for `AsyncNotifier<void>` controllers. A fire-and-forget `Future` that
  fails (e.g. a Start button) still shows a SnackBar via `installGlobalErrorHandlers` in `main.dart`.
  Feature-specific texts: `authErrorMessage` (`auth/presentation/auth_error_messages.dart`) and
  `clubErrorMessage` (`club/presentation/my_clubs_screen.dart`), both falling back to `userMessage`.

## Match module (`lib/features/match/`)
A module of its own next to home/player/team/screen control, not a content type under `display/`.
- `data/firestore_match_write_repository.dart` extends core's `FirestoreMatchRepository` with the
  writes of `MatchWriteRepository`. `append` is a plain `set` (no transaction) so it queues offline;
  lease and live-field changes are transactions and need a connection.
- `data/match_providers.dart`: `matchRepositoryProvider`, `matchDeviceIdProvider` (uuid kept in
  `shared_preferences`), `matchSessionProvider(matchId)` (a family: never a global active match).
- `presentation/match_console_screen.dart` is the live table console. It takes a `MatchSession` and
  derives everything from it through `matchConsoleProvider(session)` (clock tick + hints, nothing
  stored). Every button goes through `ConsoleButton`: ask `session.check(event)` first, pass the
  `rejectionMessage` as `blockedReason` (grey, reason on long-press). Never enable or disable a
  button with your own phase logic.
- Texts live in `presentation/match_texts.dart`, hints (vibrate/sound) are pure in
  `domain/console_hints.dart`, device effects (wakelock, landscape, haptics) sit behind
  `consoleDeviceProvider` so widget tests can replace them.
- Undo is the event log sheet adding an `EventVoided`; nothing is ever removed.
- `data/practice_match.dart` runs a match on core's `InMemoryMatchRepository` (no Firebase), used by
  the Match tab and by the widget tests. Widget tests must not call `pumpAndSettle` (the console
  ticks) and end by unmounting the console.
- Rules for `matches`, `events` and `fields` are tested against the Firestore emulator:
  `cd test/firestore_rules && npm install && npm test` (needs Java). Run it after touching
  `firestore.rules`; `flutter test` does not cover rules.

## Team scheduler (`lib/features/scheduler/`)
A module of its own like the match module (engine and models: core's `CLAUDE.md`). Built step by
step; so far the data layer and the first screens (ranking, players, adjustments, import).
- `data/scheduler_repository.dart`: `clubs/{clubId}/players`, `practiceGames`, `ratingAdjustments`,
  `schedulerConfig/default` (`{rating, scheduler}`). App-only, so there is no core base class.
  `importSheet` writes a parsed sheet export in batches and is safe to repeat (ids come from the sheet).
- `data/scheduler_providers.dart`: stream providers + `ratingResultProvider`, which recomputes all
  ratings with core's `computeRatings` whenever anything changes. Never store a rating.
  `ratingAsOfProvider` is tomorrow (as in the sheet); tests override `schedulerTodayProvider`.
- `presentation/scheduler_home_tab.dart` is the Team tab: ranking per position, sort, add/edit player
  (`player_edit_screen.dart`, with the player's adjustments) and the sheet import. It only shows
  for trainers/clubAdmins (`canUseSchedulerProvider`). Widget tests override that provider and
  `sheetExportPickerProvider` (the file picker).
- `domain/schedule_draft.dart`: `scheduleDraftProvider` holds the trainer's choices for one practice
  (attendance, fixed position/team, teams with composition and substitutes) in memory only;
  `scheduleResultProvider` runs core's `scheduleTeams` on every change.
  `presentation/team_scheduler_screen.dart` ("Make teams") shows both: attendance next to the teams
  on a wide screen, two tabs on a narrow one. Per pair of teams: "Save result" (`game_result_dialog.dart`)
  stores a `PracticeGame` (first team = white), and for the first pair "Send to pool screen" writes
  core's `teamLineupJson` to `settings/team.lineup` through `TeamController.castLineup` and makes
  Team the live content. The pool screen only shows it when its app source is switched on (see
  `hs_coaching_screen/CLAUDE.md`).
- `presentation/games_screen.dart` ("Games" on the Team tab): the log, newest first, with the rating
  change per player; edit a result or delete a game, ratings recompute by themselves.
- Rules: these four collections are readable and writable by trainers/clubAdmins only (ratings are
  not for players). Emulator tests in `test/firestore_rules/scheduler_rules.test.js`.

## Gotchas
- **Riverpod auto-retry:** a failing stream provider (e.g. missing index → `failed-precondition`)
  is retried by default and Firestore re-emits cache in between, so the UI flickers and the real
  error never shows. Handled globally by `appProviderRetry` + `AppProviderObserver`
  (core's `core/providers/riverpod_config.dart`, registered in `main.dart`). Keep them on the `ProviderScope`.
- Open work is tracked as GitHub issues, not in code comments or this file.
