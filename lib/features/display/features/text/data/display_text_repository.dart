import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/text/display_text.dart';
import 'package:hs_coaching_core/text/display_text_repository.dart';

final displayTextRepositoryProvider = Provider<DisplayTextRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return DisplayTextRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Adds add/duplicate/archive/tag-mutating writes on top of core's read-only
/// [DisplayTextRepositoryBase].
///
/// Path: `/clubs/{clubId}/displays/{displayId}/texts`
/// This collection contains all historical text documents. A separate document at
/// `/clubs/{clubId}/displays/{displayId}/settings/text` holds the ID of the
/// currently active text in a field named `currentId`.
class DisplayTextRepository extends DisplayTextRepositoryBase {
  DisplayTextRepository({
    required super.firestore,
    required super.clubId,
    required super.displayId,
  });

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

    final newTextDocRef = textsRef.doc(); // Create a reference with a new ID

    final batch = firestore.batch();

    // 1. Add the new text document
    batch.set(newTextDocRef, newText);

    // 2. Optionally, update the 'current' document to point to the new text
    if (setAsCurrent) {
      batch.set(currentTextRef, {
        'currentId': newTextDocRef.id,
      }, SetOptions(merge: true));
    }

    // 3. Atomically add any new tags to the global list of text tags
    // Should write to the textTags field in the collection /clubs/{clubId}/displays/{displayId}/settings/text
    if (tags.isNotEmpty) {
      batch.set(currentTextRef, {
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

    final newTextDocRef = textsRef.doc(); // Create a reference for the new text
    final originalTextDocRef = textsRef.doc(originalTextId);

    final batch = firestore.batch();

    // 1. Archive the original text document
    batch.update(originalTextDocRef, {
      'status': DisplayTextStatus.archived.name,
    });

    // 2. Add the new text document
    batch.set(newTextDocRef, newTextData);

    // 3. If the original was current, set the new one as current
    if (isCurrent) {
      batch.set(currentTextRef, {
        'currentId': newTextDocRef.id,
      }, SetOptions(merge: true));
    }

    // 4. Atomically add any new tags to the global list
    if (newTags.isNotEmpty) {
      batch.set(currentTextRef, {
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
    await currentTextRef.set({'currentId': textId}, SetOptions(merge: true));
  }

  /// Archives a text document, effectively "deleting" it from the active list.
  Future<void> archiveText(String textId) async {
    await textsRef.doc(textId).update({
      'status': DisplayTextStatus.archived.name,
    });
  }

  /// Unarchives a text document, making it active again.
  Future<void> unarchiveText(String textId) async {
    await textsRef.doc(textId).update({
      'status': DisplayTextStatus.active.name,
    });
  }
}
