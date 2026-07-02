import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/image/domain/display_image.dart';

final displayImageRepositoryProvider = Provider<DisplayImageRepository>((ref) {
  return DisplayImageRepository(ref);
});

/// Repository for managing display images in Firestore.
///
/// Path: `/clubs/{clubId}/displays/{displayId}/images`
/// This collection contains all historical image documents. A separate document at
/// `/clubs/{clubId}/displays/{displayId}/settings/image` holds the ID of the
/// currently active image in a field named `currentId`.
class DisplayImageRepository {
  DisplayImageRepository(this._ref);

  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);
  FirebaseStorage get _storage => _ref.read(firebaseStorageProvider);

  /// Reference to the 'images' collection for a specific display.
  CollectionReference<DisplayImage> _imagesRef(
    String clubId,
    String displayId,
  ) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('images')
        .withConverter<DisplayImage>(
          fromFirestore: (snapshot, _) =>
              DisplayImage.fromMap(snapshot.data()!).copyWith(id: snapshot.id),
          toFirestore: (image, _) => image.toMap(),
        );
  }

  /// Reference to the document that stores the active image ID.
  /// Path: `.../settings/image`
  DocumentReference _currentImageRef(String clubId, String displayId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('image');
  }

  /// Uploads an image file to Firebase Storage and returns the download URL.
  Future<String> _uploadImage(File imageFile) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child(
      'clubs/${ids.clubId}/${ids.displayDeviceId}/images/$fileName',
    );

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    return snapshot.ref.getDownloadURL();
  }

  /// Creates a new image document.
  ///
  /// If `setAsCurrent` is true, it also sets this new image as the currently
  /// displayed one.
  Future<void> addImage({
    required File imageFile,
    String? title,
    String? description,
    List<String> tags = const [],
    bool setAsCurrent = false,
  }) async {
    final downloadUrl = await _uploadImage(imageFile);

    final ids = _ref.read(displayDeviceIdsProvider);
    final user = await _ref.read(appUserProvider.future);

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final newImageData = DisplayImage(
      id: '', // Firestore will generate this
      title: title?.isNotEmpty == true ? title : null,
      description: description?.isNotEmpty == true ? description : null,
      url: downloadUrl,
      userId: user.uid,
      timestamp: DateTime.now(),
      status: DisplayImageStatus.active,
      tags: tags,
    );

    final imagesRef = _imagesRef(ids.clubId, ids.displayDeviceId);
    final newImageDocRef = imagesRef.doc();

    final batch = _firestore.batch();

    batch.set(newImageDocRef, newImageData);

    if (setAsCurrent) {
      batch.set(_currentImageRef(ids.clubId, ids.displayDeviceId), {
        'currentId': newImageDocRef.id,
      }, SetOptions(merge: true));
    }

    if (tags.isNotEmpty) {
      batch.set(_currentImageRef(ids.clubId, ids.displayDeviceId), {
        'imageTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Updates an image's metadata in place.
  Future<void> updateImage({
    required String id,
    String? title,
    String? description,
    List<String> tags = const [],
  }) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    final imageDocRef = _imagesRef(ids.clubId, ids.displayDeviceId).doc(id);

    final updateData = {
      'title': title?.isNotEmpty == true ? title : null,
      'description': description?.isNotEmpty == true ? description : null,
      'tags': tags,
    };

    final batch = _firestore.batch();

    // 1. Update the image document
    batch.update(imageDocRef, updateData);

    // 2. Atomically add any new tags to the global list
    if (tags.isNotEmpty) {
      batch.set(_currentImageRef(ids.clubId, ids.displayDeviceId), {
        'imageTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Clears the currently displayed image.
  Future<void> clearCurrentImage() async {
    await setCurrentImageId(null);
  }

  /// Sets the ID in the 'current' document.
  Future<void> setCurrentImageId(String? imageId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _currentImageRef(
      ids.clubId,
      ids.displayDeviceId,
    ).set({'currentId': imageId}, SetOptions(merge: true));
  }

  /// Archives an image document.
  Future<void> archiveImage(String imageId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _imagesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(imageId).update({'status': DisplayImageStatus.archived.name});
  }

  /// Unarchives an image document, setting its status back to 'active'.
  Future<void> unarchiveImage(String imageId) async {
    final ids = _ref.read(displayDeviceIdsProvider);
    await _imagesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(imageId).update({'status': DisplayImageStatus.active.name});
  }

  /// Returns a stream of the current image ID document.
  Stream<DocumentSnapshot> watchCurrentImageIdDoc() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _currentImageRef(ids.clubId, ids.displayDeviceId).snapshots();
  }

  /// Fetches a specific image document by its ID.
  Stream<DisplayImage?> _getImageStreamById(String imageId) {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _imagesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).doc(imageId).snapshots().map((snapshot) => snapshot.data());
  }

  /// Watches the currently active display image.
  Stream<DisplayImage?> watchCurrentImage() {
    return watchCurrentImageIdDoc().asyncMap((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final currentId = data?['currentId'] as String?;
      if (currentId == null) return null;
      return _getImageStreamById(currentId).first;
    });
  }

  /// Returns a stream of all active image documents, ordered by timestamp.
  Stream<List<DisplayImage>> watchAllActiveImages({String? tag}) {
    final ids = _ref.watch(displayDeviceIdsProvider);
    Query<DisplayImage> query = _imagesRef(
      ids.clubId,
      ids.displayDeviceId,
    ).where('status', isEqualTo: DisplayImageStatus.active.name);

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Returns a stream of the list of all used image tags.
  Stream<List<String>> watchAllImageTags() {
    final ids = _ref.watch(displayDeviceIdsProvider);
    return _currentImageRef(ids.clubId, ids.displayDeviceId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['imageTags'] ?? []);
    });
  }
}
