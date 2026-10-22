@../hs_coaching_core/CLAUDE.md

# hs_coaching_app — control app (Android)

The coach's tablet app: create content (sketches, images, texts, chronos, tabatas, trainings,
teams, game score) and push it live to the pool screen. The only app that writes. Role for the AI:
senior Flutter dev, refactoring toward clean, testable architecture with Riverpod 3, Firebase, Freezed.

Extra stack on top of core: `firebase_auth`, `firebase_messaging`, `perfect_freehand` (sketch),
`image_picker`/`image_cropper`/`file_picker`, `shared_preferences` (theme preference only),
`custom_lint` + `riverpod_lint`. Providers are hand-written (see core's `CLAUDE.md`); no Riverpod codegen.

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

## Gotchas
- **Riverpod auto-retry:** a failing stream provider (e.g. missing index → `failed-precondition`)
  is retried by default and Firestore re-emits cache in between, so the UI flickers and the real
  error never shows. Handled globally by `appProviderRetry` + `AppProviderObserver`
  (core's `core/providers/riverpod_config.dart`, registered in `main.dart`). Keep them on the `ProviderScope`.
- Open work is tracked as GitHub issues, not in code comments or this file.
