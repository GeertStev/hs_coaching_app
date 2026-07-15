import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_background.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

class SketchRepository {
  SketchRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _storage = storage,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _clubId;
  final String _displayId;

  /// Returns a reference to the 'sketches' collection for a specific display.
  CollectionReference<Sketch> _sketchesRef() {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('sketches')
        .withConverter<Sketch>(
          fromFirestore: (snapshot, _) =>
              Sketch.fromJson(snapshot.data()!).copyWith(id: snapshot.id),
          toFirestore: (sketch, _) => sketch.toJson(),
        );
  }

  DocumentReference _currentSketchSettingsRef() {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('sketch');
  }

  CollectionReference<SketchElement> _elementsRef(String sketchId) {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('sketches')
        .doc(sketchId)
        .collection('elements')
        .withConverter<SketchElement>(
          fromFirestore: (snapshot, _) =>
              SketchElement.fromJson(snapshot.data()!),
          toFirestore: (element, _) => element.toJson(),
        );
  }

  Stream<List<SketchElement>> getSketchElements(String sketchId) {
    return _elementsRef(sketchId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<void> addOrUpdateElement(
    String sketchId,
    SketchElement element,
  ) async {
    try {
      await _elementsRef(sketchId).doc(element.id).set(element);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeElement(String sketchId, String elementId) async {
    try {
      await _elementsRef(sketchId).doc(elementId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearSketch(String sketchId) async {
    final snapshot = await _elementsRef(sketchId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Sketch>> watchAllActiveSketches({String? tag}) {
    Query<Sketch> query = _sketchesRef().where(
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

  Stream<Sketch> watchSketch(String sketchId) {
    return _sketchesRef()
        .doc(sketchId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  // De userId wordt nu netjes via de UI/Controller/Notifier meegegeven!
  Future<String> createSketch({
    required String title,
    required String userId,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  }) async {
    final batch = _firestore.batch();

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

    final sketchesRef = _sketchesRef();
    final newSketchDocRef = sketchesRef.doc();

    batch.set(newSketchDocRef, newSketch);

    if (tags.isNotEmpty) {
      batch.set(_currentSketchSettingsRef(), {
        'sketchTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
    return newSketchDocRef.id;
  }

  Future<void> updateSketch({
    required String id,
    required String title,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  }) async {
    final sketchDocRef = _sketchesRef().doc(id);
    final batch = _firestore.batch();

    final updateData = {
      'title': title,
      'tags': tags,
      'description': description,
      'lastModified': FieldValue.serverTimestamp(),
      'backgroundUrl': backgroundUrl,
    };
    batch.update(sketchDocRef, updateData);

    if (tags.isNotEmpty) {
      batch.set(_currentSketchSettingsRef(), {
        'sketchTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> archiveSketch(String sketchId) async {
    await _sketchesRef().doc(sketchId).update({
      'status': SketchStatus.archived.name,
    });

    final currentSketchDoc = await _currentSketchSettingsRef().get();
    if (currentSketchDoc.exists &&
        (currentSketchDoc.data() as Map<String, dynamic>)['currentId'] ==
            sketchId) {
      await clearCurrentSketch();
    }
  }

  Future<void> unarchiveSketch(String sketchId) async {
    await _sketchesRef().doc(sketchId).update({
      'status': SketchStatus.active.name,
    });
  }

  Future<void> hardDeleteSketch(String sketchId) async {
    try {
      final elementsQuery = _elementsRef(sketchId);
      final elementsSnapshot = await elementsQuery.get();

      final batch = _firestore.batch();
      for (final doc in elementsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _sketchesRef().doc(sketchId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSketchTimestamp(String sketchId) {
    return _sketchesRef().doc(sketchId).update({
      'lastModified': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> watchCurrentSketchIdDoc() {
    return _currentSketchSettingsRef().snapshots();
  }

  Future<void> setCurrentSketchId(String? sketchId) async {
    await _currentSketchSettingsRef().set({
      'currentId': sketchId,
    }, SetOptions(merge: true));
  }

  Future<void> clearCurrentSketch() async {
    await setCurrentSketchId(null);
  }

  Future<void> addSketchBackground({
    required File imageFile,
    required String title,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

    final storageRef = _storage.ref().child(
      'clubs/$_clubId/$_displayId/backgrounds/$fileName',
    );
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final newBackground = SketchBackground(title: title, url: downloadUrl);
    await _currentSketchSettingsRef().set({
      'backgrounds': FieldValue.arrayUnion([newBackground.toMap()]),
    }, SetOptions(merge: true));
  }

  Stream<List<String>> watchAllSketchTags() {
    return _currentSketchSettingsRef().snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['sketchTags'] ?? []);
    });
  }

  Stream<List<SketchBackground>> watchSketchBackgrounds() {
    return _currentSketchSettingsRef().snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final backgroundsData = List<Map<String, dynamic>>.from(
        data?['backgrounds'] ?? [],
      );
      return backgroundsData.map(SketchBackground.fromMap).toList();
    });
  }
}
