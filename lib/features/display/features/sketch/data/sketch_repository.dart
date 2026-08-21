import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/i_sketch_repository.dart';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_core/sketch/sketch_background.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_core/sketch/sketch_repository.dart';

/// Adds create/update/archive/background/tag-mutating writes on top of core's
/// read-only [DisplaySketchRepositoryBase].
class DisplaySketchRepository extends DisplaySketchRepositoryBase
    implements ISketchRepository {
  DisplaySketchRepository({
    required super.firestore,
    required FirebaseStorage storage,
    required super.clubId,
    required super.displayId,
  }) : _storage = storage;

  final FirebaseStorage _storage;

  @override
  Stream<List<SketchElement>> getSketchElements(String sketchId) {
    return watchSketchElements(sketchId);
  }

  @override
  Future<void> addOrUpdateElement(
    String sketchId,
    SketchElement element,
  ) async {
    await elementsRef(sketchId).doc(element.id).set(element);
  }

  @override
  Future<void> removeElement(String sketchId, String elementId) async {
    await elementsRef(sketchId).doc(elementId).delete();
  }

  @override
  Future<void> clearSketch(String sketchId) async {
    final snapshot = await elementsRef(sketchId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
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

  @override
  Stream<Sketch> watchSketch(String sketchId) {
    return sketchesRef
        .doc(sketchId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<void> unarchiveSketch(String sketchId) async {
    await sketchesRef.doc(sketchId).update({
      'status': SketchStatus.active.name,
    });
  }

  @override
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

  @override
  Future<void> updateSketchTimestamp(String sketchId) {
    return sketchesRef.doc(sketchId).update({
      'lastModified': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<String?> watchCurrentSketchId() {
    return currentSketchSettingsRef.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['currentId'] as String?;
    });
  }

  @override
  Future<void> setCurrentSketchId(String? sketchId) async {
    await currentSketchSettingsRef.set({
      'currentId': sketchId,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> clearCurrentSketch() async {
    await setCurrentSketchId(null);
  }

  @override
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

  @override
  Future<void> updateSketchBackground(String id, String? backgroundUrl) async {
    await sketchesRef.doc(id).update({
      // Als backgroundUrl null is, schrijf dit expliciet als null weg in Firestore
      'backgroundUrl': backgroundUrl ?? FieldValue.delete(),
      'lastModified': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<String>> watchAllSketchTags() {
    return currentSketchSettingsRef.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['sketchTags'] ?? []);
    });
  }

  @override
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
