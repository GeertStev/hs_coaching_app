import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_navigation.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_app/features/display/features/training/data/training_repository.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return TrainingRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

class TrainingNotifier extends StreamNotifier<Training> {
  @override
  Stream<Training> build() {
    final repository = ref.watch(trainingRepositoryProvider);
    return repository.watchTraining();
  }

  void setOptimistic(Training training) {
    state = AsyncData(training);
  }
}

final trainingNotifierProvider =
    StreamNotifierProvider<TrainingNotifier, Training>(TrainingNotifier.new);

/// Opgeslagen Set/Subset/Oefening-kaarten uit de club-bibliotheek.
final trainingTemplatesProvider = StreamProvider<List<TrainingTemplate>>((ref) {
  return ref.watch(trainingRepositoryProvider).watchTemplates();
});

/// Commands met optimistische updates + rollback via invalidate, naar het
/// voorbeeld van `TabataCommands`.
class TrainingCommands {
  TrainingCommands(this.ref);
  final Ref ref;

  /// Eén-niveau undo-snapshot — alleen gezet door [saveWithUndo], nooit
  /// door het gewone [save]. Bewust geen stack: het ontwerpdocument (§9)
  /// vraagt om "de snapshot" herstellen (enkelvoud), niet meerdere stappen
  /// terug kunnen.
  Training? _undoSnapshot;

  /// Schrijft de volledige boom na een mutatie via `training_tree.dart`'s
  /// zuivere functies. Voor hernoemen/verwijderen/toevoegen/repeatCount/
  /// template-invoegen — geen undo-snackbar nodig voor deze acties (zie
  /// [saveWithUndo] voor verplaats-/groepeerbewerkingen).
  Future<void> save(Training training) async {
    final repository = ref.read(trainingRepositoryProvider);
    final notifier = ref.read(trainingNotifierProvider.notifier);

    notifier.setOptimistic(training);

    try {
      await repository.saveTraining(training);
    } catch (e) {
      ref.invalidate(trainingNotifierProvider);
      rethrow;
    }
  }

  /// Zelfde als [save], maar onthoudt [previous] zodat [undo] die kan
  /// herstellen. Alleen voor `moveNode`/`groupWithTarget`-gedreven
  /// mutaties (verplaatsen/groeperen) — dat zijn de bewerkingen die de
  /// coach per ongeluk kan uitvoeren tijdens het slepen, en waarvoor het
  /// ontwerpdocument (§9) een undo-snackbar vraagt.
  Future<void> saveWithUndo({
    required Training previous,
    required Training next,
  }) async {
    _undoSnapshot = previous;
    try {
      await save(next);
    } catch (e) {
      _undoSnapshot = null;
      rethrow;
    }
  }

  /// Herstelt de laatste [saveWithUndo]-snapshot, indien aanwezig. Is zelf
  /// een gewone [save] — ongedaan maken registreert geen nieuw undo-punt.
  Future<void> undo() async {
    final snapshot = _undoSnapshot;
    if (snapshot == null) return;
    _undoSnapshot = null;
    await save(snapshot);
  }

  // ------------------------------------------------------- Live-sessie
  // Naar het voorbeeld van [TabataCommands]: optimistische update + rollback
  // via invalidate. Next/previous rekenen eerst de actuele positie uit
  // (`trainingProgressAt`: anker + verstreken tijd, zie `training.dart`'s doc
  // comment) en verzetten dan het anker (`currentStepIndex`).

  int get _nowServerMillis {
    final offsetMillis = ref.read(serverTimeOffsetProvider).value ?? 0;
    return serverNowMillis(offsetMillis);
  }

  /// Hervat het aftellen van de huidige stap (na een pauze). Gebruik
  /// [moveToFirstStep] om de sessie voor het eerst te starten — [start]
  /// verplaatst de pointer zelf niet.
  Future<void> start(Training currentTraining) async {
    final repository = ref.read(trainingRepositoryProvider);
    final notifier = ref.read(trainingNotifierProvider.notifier);

    final eventTime = _nowServerMillis;
    notifier.setOptimistic(
      currentTraining.copyWith(
        status: TrainingStatus.running,
        authoritativeStartTimeMillis: eventTime,
      ),
    );

    try {
      await repository.start(currentTraining, nowServerMillis: eventTime);
    } catch (e) {
      ref.invalidate(trainingNotifierProvider);
      rethrow;
    }
  }

  Future<void> pause(Training currentTraining) async {
    final repository = ref.read(trainingRepositoryProvider);
    final notifier = ref.read(trainingNotifierProvider.notifier);

    final nowServerMillis = _nowServerMillis;
    final newlyElapsed =
        nowServerMillis - currentTraining.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentTraining.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    notifier.setOptimistic(
      currentTraining.copyWith(
        status: TrainingStatus.paused,
        accumulatedElapsedMillis: totalAccumulated,
      ),
    );

    try {
      await repository.pause(currentTraining, nowServerMillis: nowServerMillis);
    } catch (e) {
      ref.invalidate(trainingNotifierProvider);
      rethrow;
    }
  }

  /// Start de sessie voor het eerst (of herbegint na een reset): springt
  /// naar de eerste stap van de platgeslagen tijdlijn.
  Future<void> moveToFirstStep(Training currentTraining) async {
    final steps = flattenTraining(currentTraining);
    await _moveTo(currentTraining, steps.isEmpty ? null : 0);
  }

  /// Eén stap vooruit — ook tijdens een getimede stap, om die vroegtijdig
  /// af te breken, en de enige manier om voorbij een ongetimede stap te
  /// komen.
  Future<void> next(Training currentTraining) async {
    final progress = _progressNow(currentTraining);
    final target = nextStepIndex(progress);
    await _moveTo(
      currentTraining,
      target < progress.totalSteps ? target : null,
    );
  }

  /// Eén stap terug — herstart altijd de klok van de stap waar je op
  /// terugkomt (zie `training.dart`'s doc comment). Doet niets als er geen
  /// vorige stap is (sessie nog niet gestart).
  Future<void> previous(Training currentTraining) async {
    final target = previousStepIndex(_progressNow(currentTraining));
    if (target == null) return;
    await _moveTo(currentTraining, target);
  }

  TrainingSessionProgress _progressNow(Training training) {
    return trainingProgressAt(
      training,
      flattenTraining(training),
      nowServerMillis: _nowServerMillis,
    );
  }

  /// Zet de sessie terug naar niet-gestart; de boom blijft behouden.
  Future<void> resetSession(Training currentTraining) async {
    final repository = ref.read(trainingRepositoryProvider);
    final notifier = ref.read(trainingNotifierProvider.notifier);

    notifier.setOptimistic(
      currentTraining.copyWith(
        status: TrainingStatus.idle,
        authoritativeStartTimeMillis: 0,
        accumulatedElapsedMillis: 0,
        currentStepIndex: -1,
      ),
    );

    try {
      await repository.reset();
    } catch (e) {
      ref.invalidate(trainingNotifierProvider);
      rethrow;
    }
  }

  Future<void> _moveTo(Training currentTraining, int? stepIndex) async {
    final repository = ref.read(trainingRepositoryProvider);
    final notifier = ref.read(trainingNotifierProvider.notifier);

    final eventTime = _nowServerMillis;
    if (stepIndex == null) {
      notifier.setOptimistic(
        currentTraining.copyWith(status: TrainingStatus.finished),
      );
    } else {
      final resumedStatus = currentTraining.status == TrainingStatus.paused
          ? TrainingStatus.paused
          : TrainingStatus.running;
      notifier.setOptimistic(
        currentTraining.copyWith(
          status: resumedStatus,
          authoritativeStartTimeMillis: eventTime,
          accumulatedElapsedMillis: 0,
          currentStepIndex: stepIndex,
        ),
      );
    }

    try {
      await repository.moveTo(
        currentTraining,
        stepIndex,
        nowServerMillis: eventTime,
      );
    } catch (e) {
      ref.invalidate(trainingNotifierProvider);
      rethrow;
    }
  }

  // ------------------------------------------------------- Templates
  // Geen optimistische update nodig: de templates-stream is geen onderdeel
  // van de huidige training.

  Future<void> saveTemplate(
    String title,
    TrainingTemplateKind kind,
    Map<String, dynamic> payload,
    int height,
  ) {
    return ref
        .read(trainingRepositoryProvider)
        .saveTemplate(title, kind, payload, height);
  }

  Future<void> deleteTemplate(String templateId) {
    return ref.read(trainingRepositoryProvider).deleteTemplate(templateId);
  }
}

final trainingCommandsProvider = Provider((ref) => TrainingCommands(ref));
