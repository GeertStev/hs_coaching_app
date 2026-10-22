import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_core/image/display_image.dart';
import 'package:hs_coaching_core/image/display_image_repository.dart';

final displayImageRepositoryProvider = Provider<DisplayImageRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return DisplayImageRepository(
    firestore: firestore,
    storage: storage,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Adds upload/archive/tag-mutating writes on top of core's read-only
/// [DisplayImageRepositoryBase].
///
/// Path: `/clubs/{clubId}/displays/{displayId}/images`
/// This collection contains all historical image documents. A separate document at
/// `/clubs/{clubId}/displays/{displayId}/settings/image` holds the ID of the
/// currently active image in a field named `currentId`.
class DisplayImageRepository extends DisplayImageRepositoryBase
    implements TagMaintenance {
  DisplayImageRepository({
    required super.firestore,
    required FirebaseStorage storage,
    required super.clubId,
    required super.displayId,
  }) : _storage = storage;

  final FirebaseStorage _storage;

  /// Uploads an image file to Firebase Storage and returns the download URL.
  Future<String> _uploadImage(File imageFile) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child(
      'clubs/$clubId/$displayId/images/$fileName',
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
    required String userId,
    String? title,
    String? description,
    List<String> tags = const [],
    bool setAsCurrent = false,
  }) async {
    final downloadUrl = await _uploadImage(imageFile);

    final newImageData = DisplayImage(
      id: '', // Firestore will generate this
      title: title?.isNotEmpty == true ? title : null,
      description: description?.isNotEmpty == true ? description : null,
      url: downloadUrl,
      userId: userId,
      timestamp: DateTime.now(),
      status: DisplayImageStatus.active,
      tags: tags,
    );

    final newImageDocRef = imagesRef.doc();
    final batch = firestore.batch();

    batch.set(newImageDocRef, newImageData);

    if (setAsCurrent) {
      batch.set(currentImageRef, {
        'currentId': newImageDocRef.id,
      }, SetOptions(merge: true));
    }

    if (tags.isNotEmpty) {
      batch.set(currentImageRef, {
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
    final imageDocRef = imagesRef.doc(id);

    final updateData = {
      'title': title?.isNotEmpty == true ? title : null,
      'description': description?.isNotEmpty == true ? description : null,
      'tags': tags,
    };

    final batch = firestore.batch();

    // 1. Update the image document
    batch.update(imageDocRef, updateData);

    // 2. Atomically add any new tags to the global list
    if (tags.isNotEmpty) {
      batch.set(currentImageRef, {
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
    await currentImageRef.set({
      'currentId': imageId,
    }, SetOptions(merge: true));
  }

  /// Archives an image document.
  Future<void> archiveImage(String imageId) async {
    await imagesRef.doc(imageId).update({
      'status': DisplayImageStatus.archived.name,
    });
  }

  /// Unarchives an image document, setting its status back to 'active'.
  Future<void> unarchiveImage(String imageId) async {
    await imagesRef.doc(imageId).update({
      'status': DisplayImageStatus.active.name,
    });
  }

  @override
  Future<void> renameTag(String from, String to) => renameTagInCollection(
    firestore: firestore,
    collectionPath: imagesRef.path,
    from: from,
    to: to,
    tagListDoc: currentImageRef,
    tagListField: 'imageTags',
  );

  @override
  Future<void> deleteTag(String tag) => renameTag(tag, '');
}
