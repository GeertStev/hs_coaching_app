import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_background.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

// ToDo Lots of things, check if providers need to be up the tree

class SketchRepository {
  SketchRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);
  FirebaseStorage get _storage => _ref.read(firebaseStorageProvider);

  /// Returns a reference to the 'sketches' collection for a specific display.
  CollectionReference<Sketch> _sketchesRef(String clubId, String displayId) {
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/sketches
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('sketches')
        .withConverter<Sketch>(
          fromFirestore: (snapshot, _) =>
              Sketch.fromJson(snapshot.data()!).copyWith(id: snapshot.id),
          toFirestore: (sketch, _) => sketch.toJson(),
        );
  }

  /// Reference to the document that stores the active sketch ID and tags.
  /// Path: `.../settings/sketch`
  DocumentReference _currentSketchSettingsRef(String clubId, String displayId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('sketch');
  }

  /// Returns a reference to the 'elements' subcollection for a specific sketch.
  CollectionReference<SketchElement> _elementsRef(
    String clubId,
    String displayId,
    String sketchId,
  ) {
    // Path: /clubs/{clubId}/displays/{displayDeviceId}/sketches/{sketchId}/elements
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
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
    final ids = _ref.read(displayDeviceIdsProvider);
    final clubId = ids.clubId; // Assuming clubId is always available
    final displayId =
        ids.displayDeviceId; // Assuming displayId is always available

    return _elementsRef(clubId, displayId, sketchId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<void> addOrUpdateElement(SketchElement element) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final sketchId = _ref.read(currentSketchIdProvider);
    if (sketchId == null) return; // Don't save if no sketch is active
    try {
      await _elementsRef(
        ids.clubId,
        ids.displayDeviceId,
        sketchId,
      ).doc(element.id).set(element);
    } catch (e) {
      // Log the error for debugging
      print('Error adding or updating element ${element.id}: $e');
      rethrow; // Re-throw to propagate the error if necessary
    }
  }

  Future<void> removeElement(String elementId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final sketchId = _ref.read(currentSketchIdProvider);
    if (sketchId == null) return;
    try {
      await _elementsRef(
        ids.clubId,
        ids.displayDeviceId,
        sketchId,
      ).doc(elementId).delete();
    } catch (e) {
      print('Error removing element $elementId: $e');
      rethrow;
    }
  }

  Future<void> clearSketch() async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final sketchId = _ref.read(currentSketchIdProvider);
    if (sketchId == null) return;
    final snapshot = await _elementsRef(
      ids.clubId,
      ids.displayDeviceId,
      sketchId,
    ).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Sketch>> watchAllActiveSketches({String? tag}) {
    final ids = _ref.read(displayDeviceIdsProvider);
    Query<Sketch> query = _sketchesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).where('status', isEqualTo: SketchStatus.active.name);

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Sketch> watchSketch(String sketchId) {
    final ids = _ref.read(displayDeviceIdsProvider);
    return _sketchesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(sketchId).snapshots().map((snapshot) => snapshot.data()!);
  }

  Future<String> createSketch({
    required String title,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  }) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final user = _ref.read(appUserProvider).value;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();

    final newSketch = Sketch(
      id: '', // Firestore will generate this
      title: title,
      description: description,
      lastModified: DateTime.now(),
      userId: user.uid,
      tags: tags,
      status: SketchStatus.active,
      backgroundUrl: backgroundUrl,
    );

    final sketchesRef = _sketchesRef(ids.clubId, ids.displayDeviceId);
    final newSketchDocRef = sketchesRef.doc();

    batch.set(newSketchDocRef, newSketch);

    if (tags.isNotEmpty) {
      batch.set(
        _currentSketchSettingsRef(ids.clubId, ids.displayDeviceId),
        {'sketchTags': FieldValue.arrayUnion(tags)},
        SetOptions(merge: true),
      );
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
    final ids = _ref.read(displayDeviceIdsProvider);
    final sketchDocRef = _sketchesRef(ids.clubId, ids.displayDeviceId).doc(id);

    final batch = _firestore.batch();

    final updateData = {
      'title': title,
      'tags': tags,
      'description': description,
      'lastModified':
          FieldValue.serverTimestamp(), // This is the source of the temporary null
      'backgroundUrl': ?backgroundUrl,
    };
    batch.update(sketchDocRef, updateData);

    if (tags.isNotEmpty) {
      batch.set(
        _currentSketchSettingsRef(ids.clubId, ids.displayDeviceId),
        {'sketchTags': FieldValue.arrayUnion(tags)},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> archiveSketch(String sketchId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    // Instead of deleting, we archive the sketch.
    // The UI can filter based on status.
    await _sketchesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(sketchId).update({'status': SketchStatus.archived.name});

    // Also clear it if it was the current sketch
    final currentSketchDoc = await _currentSketchSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).get();
    if (currentSketchDoc.exists &&
        (currentSketchDoc.data() as Map<String, dynamic>)['currentId'] ==
            sketchId) {
      await clearCurrentSketch();
    }
  }

  /// Unarchives a sketch document, making it active again.
  Future<void> unarchiveSketch(String sketchId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _sketchesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(sketchId).update({'status': SketchStatus.active.name});
  }

  Future<void> hardDeleteSketch(String sketchId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    try {
      // Get a reference to the elements subcollection
      final elementsQuery = _elementsRef(
        ids.clubId,
        ids.displayDeviceId,
        sketchId,
      );
      final elementsSnapshot = await elementsQuery.get();

      // Use a batch write to delete all elements for efficiency
      final batch = _firestore.batch();
      for (final doc in elementsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // After deleting the subcollection, delete the sketch document itself
      await _sketchesRef(
        ids.clubId,
        ids.displayDeviceId,
      ).doc(sketchId).delete();
    } catch (e) {
      print('Error deleting sketch $sketchId: $e');
      rethrow;
    }
  }

  Future<void> updateSketchTimestamp(String sketchId, DisplayDeviceIds ids) {
    return _sketchesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(sketchId).update({'lastModified': FieldValue.serverTimestamp()});
  }

  /// Returns a stream of the current sketch ID document.
  Stream<DocumentSnapshot> watchCurrentSketchIdDoc() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _currentSketchSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).snapshots();
  }

  /// Sets the ID in the 'current' document.
  Future<void> setCurrentSketchId(String? sketchId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _currentSketchSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({'currentId': sketchId}, SetOptions(merge: true));
  }

  /// Clears the currently displayed sketch.
  Future<void> clearCurrentSketch() async {
    await setCurrentSketchId(null);
  }

  /// Uploads a background image and adds it to the list of available backgrounds.
  Future<void> addSketchBackground({
    required File imageFile,
    required String title,
  }) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

    // 1. Upload to Storage
    final storageRef = _storage.ref().child(
      'clubs/${ids.clubId}/${ids.displayDeviceId}/backgrounds/$fileName',
    );
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // 2. Add to Firestore
    final newBackground = SketchBackground(title: title, url: downloadUrl);
    await _currentSketchSettingsRef(ids.clubId, ids.displayDeviceId).set({
      'backgrounds': FieldValue.arrayUnion([newBackground.toMap()]),
    }, SetOptions(merge: true));
  }

  /// Returns a stream of the list of all used sketch tags.
  Stream<List<String>> watchAllSketchTags() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _currentSketchSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['sketchTags'] ?? []);
    });
  }

  /// Returns a stream of the list of all available sketch backgrounds.
  Stream<List<SketchBackground>> watchSketchBackgrounds() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _currentSketchSettingsRef(
      ids.clubId,
      ids.displayDeviceId,
    ).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final backgroundsData = List<Map<String, dynamic>>.from(
        data?['backgrounds'] ?? [],
      );
      return backgroundsData.map(SketchBackground.fromMap).toList();
    });
  }
}
