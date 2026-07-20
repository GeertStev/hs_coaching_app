import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/text/domain/display_text.dart';

final displayTextRepositoryProvider = Provider<DisplayTextRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return DisplayTextRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Repository for managing display texts in Firestore.
///
/// Path: `/clubs/{clubId}/displays/{displayId}/texts`
/// This collection contains all historical text documents. A separate document at
/// `/clubs/{clubId}/displays/{displayId}/settings/text` holds the ID of the
/// currently active text in a field named `currentId`.
class DisplayTextRepository {
  DisplayTextRepository({
    required FirebaseFirestore firestore,
    required String clubId,
    required String displayId,
  }) : _firestore = firestore,
       _clubId = clubId,
       _displayId = displayId;

  final FirebaseFirestore _firestore;
  final String _clubId;
  final String _displayId;

  /// Reference to the 'texts' collection for a specific display.
  CollectionReference<DisplayText> _textsRef() {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('texts')
        .withConverter<DisplayText>(
          fromFirestore: (snapshot, _) =>
              DisplayText.fromJson(snapshot.data()!).copyWith(id: snapshot.id),
          toFirestore: (text, _) => text.toJson(),
        );
  }

  /// Reference to the document that stores the active text ID.
  /// Path: `.../settings/text`
  DocumentReference _currentTextRef() {
    return _firestore
        .collection('clubs')
        .doc(_clubId)
        .collection('displays')
        .doc(_displayId)
        .collection('settings')
        .doc('text');
  }

  /// Creates a new text document.
  ///
  /// If `setAsCurrent` is true, it also sets this new text as the currently
  /// displayed one.
  /// This preserves history as a new document is created for every submission.
  /// Also updates the global list of tags for this display.
  Future<void> addText({
    required String userId,
    required String text,
    required List<String> tags,
    String? title,
    bool setAsCurrent = false,
  }) async {
    final newText = DisplayText(
      id: '', // Firestore will generate this
      title: title?.isNotEmpty == true ? title : null,
      text: text,
      userId: userId,
      timestamp: DateTime.now(),
      status: DisplayTextStatus.active,
      tags: tags,
    );

    final textsRef = _textsRef();
    final newTextDocRef = textsRef.doc(); // Create a reference with a new ID

    final batch = _firestore.batch();

    // 1. Add the new text document
    batch.set(newTextDocRef, newText);

    // 2. Optionally, update the 'current' document to point to the new text
    if (setAsCurrent) {
      batch.set(_currentTextRef(), {
        'currentId': newTextDocRef.id,
      }, SetOptions(merge: true));
    }

    // 3. Atomically add any new tags to the global list of text tags
    // Should write to the textTags field in the collection /clubs/{clubId}/displays/{displayId}/settings/text
    if (tags.isNotEmpty) {
      batch.set(_currentTextRef(), {
        'textTags': FieldValue.arrayUnion(tags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Updates a text by archiving the original and creating a new one.
  ///
  /// If the original text was the currently displayed one, the new text will
  /// be set as the current one.
  Future<void> updateTextByDuplicating({
    required String userId,
    required String originalTextId,
    required bool isCurrent,
    required String? newTitle,
    required String newText,
    required List<String> newTags,
  }) async {
    final newTextData = DisplayText(
      id: '', // Wordt gegenereerd door Firestore
      title: newTitle?.isNotEmpty == true ? newTitle : null,
      text: newText,
      userId: userId,
      timestamp: DateTime.now(),
      status: DisplayTextStatus.active,
      tags: newTags,
    );

    final textsRef = _textsRef();
    final newTextDocRef = textsRef.doc(); // Create a reference for the new text
    final originalTextDocRef = textsRef.doc(originalTextId);

    final batch = _firestore.batch();

    // 1. Archive the original text document
    batch.update(originalTextDocRef, {
      'status': DisplayTextStatus.archived.name,
    });

    // 2. Add the new text document
    batch.set(newTextDocRef, newTextData);

    // 3. If the original was current, set the new one as current
    if (isCurrent) {
      batch.set(_currentTextRef(), {
        'currentId': newTextDocRef.id,
      }, SetOptions(merge: true));
    }

    // 4. Atomically add any new tags to the global list
    if (newTags.isNotEmpty) {
      batch.set(_currentTextRef(), {
        'textTags': FieldValue.arrayUnion(newTags),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Clears the currently displayed text.
  ///
  /// This is achieved by setting the 'current' text ID to null.
  Future<void> clearCurrentText() async {
    await setCurrentTextId(null);
  }

  /// Sets the ID in the 'current' document.
  Future<void> setCurrentTextId(String? textId) async {
    await _currentTextRef().set({'currentId': textId}, SetOptions(merge: true));
  }

  /// Archives a text document, effectively "deleting" it from the active list.
  Future<void> archiveText(String textId) async {
    await _textsRef().doc(textId).update({
      'status': DisplayTextStatus.archived.name,
    });
  }

  /// Unarchives a text document, making it active again.
  Future<void> unarchiveText(String textId) async {
    await _textsRef().doc(textId).update({
      'status': DisplayTextStatus.active.name,
    });
  }

  /// Returns a stream of the current text ID document.
  Stream<DocumentSnapshot> watchCurrentTextIdDoc() {
    return _currentTextRef().snapshots();
  }

  /// Fetches a specific text document by its ID.
  Stream<DisplayText?> _getTextStreamById(String textId) {
    return _textsRef()
        .doc(textId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Watches the currently active display text.
  ///
  /// Emits null if no text is currently set.
  Stream<DisplayText?> watchCurrentText() {
    return watchCurrentTextIdDoc().asyncMap((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final currentId = data?['currentId'] as String?;
      if (currentId == null) return null;
      return _getTextStreamById(currentId).first;
    });
  }

  /// Returns a stream of all active text documents, ordered by timestamp.
  /// Optionally filters by a specific tag.
  Stream<List<DisplayText>> watchAllActiveTexts({String? tag}) {
    Query<DisplayText> query = _textsRef().where(
      'status',
      isEqualTo: DisplayTextStatus.active.name,
    );

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Returns a stream of the list of all used text tags.
  Stream<List<String>> watchAllTextTags() {
    return _currentTextRef().snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return List<String>.from(data?['textTags'] ?? []);
    });
  }
}
