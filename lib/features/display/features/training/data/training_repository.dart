import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_core/training/display_training_repository.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_validation.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_template.dart';
import 'package:hs_coaching_core/core/errors/user_message.dart';

/// Gegooid door [TrainingRepository.saveTraining] wanneer de boom de
/// max-diepte-3-invariant schendt — een verdedigingslinie op het
/// schrijfpad, want `canInsert`/`subtreeHeight`-checks in de UI kunnen niet
/// het enige zijn dat dit afdwingt (zie `training-model-v2-unified-group.md`
/// §11). Zou bij correcte UI-code nooit mogen vuren; als het toch gebeurt,
/// wijst dat op een bug in een sleep-/groepeerpad, niet op een verwachte
/// afwijzing zoals [TrainingInvalidMoveException] in `training_tree.dart`.
class TrainingShapeException implements UserFacingException {
  TrainingShapeException(this.message);
  @override
  final String message;

  @override
  String toString() => 'TrainingShapeException: $message';
}

/// Voegt schrijven toe aan core's read-only [DisplayTrainingRepository]
/// base. Eén huidige training per display, in-place bewerkt (zelfde vorm
/// als Tabata/Chrono's singleton-config) — geen aparte kaart-collectie, dus
/// elke boom-mutatie (via `training_tree.dart`'s zuivere functies) schrijft
/// de volledige boom (`children`) in één keer terug, net als Tabata's
/// `saveConfig`; de runtime-velden schrijft alleen de live-sessie.
class TrainingRepository extends DisplayTrainingRepository
    implements TagMaintenance {
  TrainingRepository({
    required super.firestore,
    required super.clubId,
    required super.displayId,
  });

  Future<void> saveTraining(Training training) async {
    if (!isValidTrainingTree(training)) {
      throw TrainingShapeException(
        'This training exceeds the maximum depth of 3 and cannot be '
        'saved.',
      );
    }
    // Alleen `children`: de runtime-velden (status, pointer, klok) zijn van
    // de live-tab. Een volledige `.set()` zou een (mogelijk verouderde)
    // lokale kopie daarvan terugschrijven en zo een lopende sessie
    // terugzetten. `merge: true` i.p.v. `.update()` zodat de eerste save ook
    // werkt als het document nog niet bestaat; een lijst wordt bij merge in
    // zijn geheel vervangen.
    await trainingSettingsRef.set({
      'children': training.toJson()['children'],
    }, SetOptions(merge: true));
  }

  // ------------------------------------------------------- Live-sessie
  // Gerichte `.update()`-writes op alleen de runtime-velden — nooit
  // `children` aanraken, zodat de editor-tab (`saveTraining`, hierboven) en
  // de live-tab niet in elkaars vaarwater schrijven. [nowServerMillis] moet
  // al gecorrigeerd zijn voor het klokverschil van dit apparaat, zie
  // `serverNowMillis`/`serverTimeOffsetProvider` — zelfde patroon als
  // `TabataRepository`.

  /// Hervat het aftellen van de huidige stap (bv. na een pauze). Verplaatst
  /// de pointer niet — gebruik [moveTo] om de sessie voor het eerst te
  /// starten (naar de eerste stap) of naar een andere stap te springen.
  Future<void> start(
    Training currentTraining, {
    required int nowServerMillis,
  }) async {
    await trainingSettingsRef.update({
      'status': TrainingStatus.running.name,
      'authoritativeStartTimeMillis': nowServerMillis,
    });
  }

  Future<void> pause(
    Training currentTraining, {
    required int nowServerMillis,
  }) async {
    if (currentTraining.status != TrainingStatus.running) return;

    final newlyElapsed =
        nowServerMillis - currentTraining.authoritativeStartTimeMillis;
    final totalAccumulated =
        currentTraining.accumulatedElapsedMillis +
        (newlyElapsed > 0 ? newlyElapsed : 0);

    await trainingSettingsRef.update({
      'status': TrainingStatus.paused.name,
      'accumulatedElapsedMillis': totalAccumulated,
    });
  }

  /// Verzet het anker (`Training.currentStepIndex`) naar [stepIndex] en
  /// herstart de klok vanaf daar (`accumulatedElapsedMillis` terug naar 0,
  /// altijd — zie `training.dart`'s doc comment: previous herstart de klok,
  /// en dezelfde methode bedient start/next/previous). [stepIndex] `null`
  /// betekent voorbij de laatste stap (einde van de sessie): dan wordt
  /// alleen `status: finished` geschreven.
  ///
  /// Blijft `paused` als de sessie al gepauzeerd was (de coach kan zo door
  /// de tijdlijn stappen zonder de klok per ongeluk te laten lopen); wordt
  /// in elk ander geval (`idle`/`running`/`finished`) `running` — zowel het
  /// eerste keer starten als handmatig terugkeren uit een afgelopen sessie
  /// hervat de sessie actief.
  Future<void> moveTo(
    Training currentTraining,
    int? stepIndex, {
    required int nowServerMillis,
  }) async {
    if (stepIndex == null) {
      await trainingSettingsRef.update({
        'status': TrainingStatus.finished.name,
      });
      return;
    }

    final resumedStatus = currentTraining.status == TrainingStatus.paused
        ? TrainingStatus.paused
        : TrainingStatus.running;

    await trainingSettingsRef.update({
      'status': resumedStatus.name,
      'authoritativeStartTimeMillis': nowServerMillis,
      'accumulatedElapsedMillis': 0,
      'currentStepIndex': stepIndex,
    });
  }

  /// Zet de sessie terug naar niet-gestart; de boom (`children`) blijft
  /// behouden.
  Future<void> reset() async {
    await trainingSettingsRef.update({
      'status': TrainingStatus.idle.name,
      'authoritativeStartTimeMillis': 0,
      'accumulatedElapsedMillis': 0,
      'currentStepIndex': -1,
    });
  }

  // --------------------------------------------------------- Templates
  // Eén gedeelde collectie voor alle drie de kaartniveaus (niet drie
  // aparte), zodat de LIST-tab (gegroepeerd per niveau, alfabetisch
  // gesorteerd) met één `orderBy('title')`-query kan werken.

  CollectionReference<Map<String, dynamic>> get _templatesRef {
    return firestore
        .collection('clubs')
        .doc(clubId)
        .collection('trainingTemplates');
  }

  Stream<List<TrainingTemplate>> watchTemplates() {
    return _templatesRef
        .orderBy('title')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return TrainingTemplate(
              id: doc.id,
              title: data['title'] as String? ?? '',
              kind: TrainingTemplateKind.values.firstWhere(
                (kind) => kind.name == data['kind'],
                orElse: () => TrainingTemplateKind.exercise,
              ),
              payload: (data['payload'] as Map<String, dynamic>?) ?? const {},
              height: (data['height'] as num?)?.toInt() ?? 1,
              tags: List<String>.from(data['tags'] as List? ?? const []),
            );
          }).toList(),
        );
  }

  Future<void> saveTemplate(
    String title,
    TrainingTemplateKind kind,
    Map<String, dynamic> payload,
    int height, {
    List<String> tags = const [],
  }) async {
    await _templatesRef.add({
      'title': title,
      'kind': kind.name,
      'payload': payload,
      'height': height,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Past titel en tags van een bewaarde template aan; de inhoud blijft.
  Future<void> updateTemplate(
    String templateId, {
    required String title,
    required List<String> tags,
  }) async {
    await _templatesRef.doc(templateId).update({'title': title, 'tags': tags});
  }

  @override
  Future<void> renameTag(String from, String to) => renameTagInCollection(
    firestore: firestore,
    collectionPath: _templatesRef.path,
    from: from,
    to: to,
  );

  @override
  Future<void> deleteTag(String tag) => renameTag(tag, '');

  Future<void> deleteTemplate(String templateId) async {
    await _templatesRef.doc(templateId).delete();
  }
}
