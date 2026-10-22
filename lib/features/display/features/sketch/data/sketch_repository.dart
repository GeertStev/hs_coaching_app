import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_core/sketch/sketch_background.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_core/sketch/sketch_repository.dart';

/// Adds create/update/archive/background/tag-mutating writes on top of core's
/// read-only [DisplaySketchRepositoryBase].
class DisplaySketchRepository extends DisplaySketchRepositoryBase {
  DisplaySketchRepository({
    required super.firestore,
    required FirebaseStorage storage,
    required super.clubId,
    required super.displayId,
  }) : _storage = storage;

  final FirebaseStorage _storage;

  /// Streamed de realtime elementen van een specifieke sketch.
  Stream<List<SketchElement>> getSketchElements(String sketchId) {
    return watchSketchElements(sketchId);
  }

  /// Voegt een element toe of werkt een bestaand element bij.
  Future<void> addOrUpdateElement(
    String sketchId,
    SketchElement element,
  ) async {
    await elementsRef(sketchId).doc(element.id).set(element);
  }

  /// Verwijdert een specifiek element uit een sketch.
  Future<void> removeElement(String sketchId, String elementId) async {
    await elementsRef(sketchId).doc(elementId).delete();
  }

  /// Verwijdert alle elementen van een sketch.
  Future<void> clearSketch(String sketchId) async {
    final snapshot = await elementsRef(sketchId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Streamed de lijst met alle actieve sketches, optioneel gefilterd op tag.
  Stream<List<Sketch>> watchAllActiveSketches({String? tag}) {
    Query<Sketch> query = sketchesRef.where(
      'status',
      isEqualTo: SketchStatus.active.name,
    );

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Streamed de metadata van één specifieke sketch op basis van zijn ID.
  @override
  Stream<Sketch> watchSketch(String sketchId) {
    return sketchesRef
        .doc(sketchId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  /// Maakt een nieuwe sketch aan en retourneert het gegenereerde ID.
  Future<String> createSketch({
    required String title,
    required String userId,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  }) async {
    final batch = firestore.batch();

    final newSketch = Sketch(
      id: '',
      title: title,
      description: description,
      lastModified: DateTime.now(),
      userId: userId,
      tags: tags,
      status: SketchStatus.active,
      backgroundUrl: backgroundUrl,
    );

    final newSketchDocRef = sketchesRef.doc();

    batch.set(newSketchDocRef, newSketch);

    if (tags.isNotEmpty) {
      batch.set(currentSketchSettingsRef, {
        'sketchTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
    return newSketchDocRef.id;
  }

  /// Werkt de metadata van een bestaande sketch bij.
  Future<void> updateSketch({
    required String id,
    required String title,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  }) async {
    final sketchDocRef = sketchesRef.doc(id);
    final batch = firestore.batch();

    final updateData = {
      'title': title,
      'tags': tags,
      'description': description,
      'lastModified': FieldValue.serverTimestamp(),
      'backgroundUrl': backgroundUrl,
    };
    batch.update(sketchDocRef, updateData);

    if (tags.isNotEmpty) {
      batch.set(currentSketchSettingsRef, {
        'sketchTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Archiveert een sketch.
  Future<void> archiveSketch(String sketchId) async {
    await sketchesRef.doc(sketchId).update({
      'status': SketchStatus.archived.name,
    });

    final currentSketchDoc = await currentSketchSettingsRef.get();
    if (currentSketchDoc.exists &&
        (currentSketchDoc.data() as Map<String, dynamic>?)?['currentId'] ==
            sketchId) {
      await clearCurrentSketch();
    }
  }

  /// Haalt een sketch uit het archief.
  Future<void> unarchiveSketch(String sketchId) async {
    await sketchesRef.doc(sketchId).update({
      'status': SketchStatus.active.name,
    });
  }

  /// Verwijdert een sketch permanent inclusief alle subcollecties.
  Future<void> hardDeleteSketch(String sketchId) async {
    final elementsQuery = elementsRef(sketchId);
    final elementsSnapshot = await elementsQuery.get();

    final batch = firestore.batch();
    for (final doc in elementsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await sketchesRef.doc(sketchId).delete();
  }

  /// Werkt de `lastModified` timestamp van de sketch bij.
  Future<void> updateSketchTimestamp(String sketchId) {
    return sketchesRef.doc(sketchId).update({
      'lastModified': FieldValue.serverTimestamp(),
    });
  }

  /// Zet het ID van de momenteel actieve sketch.
  Future<void> setCurrentSketchId(String? sketchId) async {
    await currentSketchSettingsRef.set({
      'currentId': sketchId,
    }, SetOptions(merge: true));
  }

  /// Wist de huidige actieve sketch-koppeling.
  Future<void> clearCurrentSketch() async {
    await setCurrentSketchId(null);
  }

  /// Voegt een nieuwe achtergrondafbeelding toe.
  Future<void> addSketchBackground({
    required File imageFile,
    required String title,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

    final storageRef = _storage.ref().child(
      'clubs/$clubId/$displayId/backgrounds/$fileName',
    );
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final newBackground = SketchBackground(title: title, url: downloadUrl);
    await currentSketchSettingsRef.set({
      'backgrounds': FieldValue.arrayUnion([newBackground.toJson()]),
    }, SetOptions(merge: true));
  }

  /// Wijzigt direct de achtergrond-URL van een specifieke sketch.
  Future<void> updateSketchBackground(String id, String? backgroundUrl) async {
    await sketchesRef.doc(id).update({
      // Als backgroundUrl null is, schrijf dit expliciet als null weg in Firestore
      'backgroundUrl': backgroundUrl ?? FieldValue.delete(),
      'lastModified': FieldValue.serverTimestamp(),
    });
  }

  /// Streamed alle unieke gebruikte sketch-tags.
  Stream<List<String>> watchAllSketchTags() {
    return currentSketchSettingsRef.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['sketchTags'] ?? []);
    });
  }

  /// Streamed alle beschikbare achtergronden.
  Stream<List<SketchBackground>> watchSketchBackgrounds() {
    return currentSketchSettingsRef.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final backgroundsData = List<Map<String, dynamic>>.from(
        data?['backgrounds'] ?? [],
      );
      return backgroundsData.map(SketchBackground.fromJson).toList();
    });
  }
}
