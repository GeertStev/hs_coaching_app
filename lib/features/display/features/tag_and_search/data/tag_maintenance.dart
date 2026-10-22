import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

/// Hernoemen/verwijderen van een tag over alle items van één content-type.
/// Geïmplementeerd door de repositories van sketch, image, text en
/// training-templates, zodat de gedeelde tag-UI ze op dezelfde manier kan
/// aanroepen.
abstract interface class TagMaintenance {
  /// Hernoemt [from] naar [to] in elk item. Bestaat [to] al op een item, dan
  /// worden de twee tags samengevoegd.
  Future<void> renameTag(String from, String to);

  /// Verwijdert [tag] uit elk item.
  Future<void> deleteTag(String tag);
}

/// Firestore-batches mogen maximaal 500 writes bevatten.
const _maxBatchWrites = 450;

/// Past [renameTagIn] toe op het `tags`-veld van elk document in
/// [collectionPath] dat [from] bevat (hoofdletter-ongevoelig, ook
/// gearchiveerde documenten). Een lege [to] verwijdert de tag.
///
/// Haalt de hele collectie op en filtert lokaal: `arrayContains` is
/// hoofdletter-gevoelig en zou varianten als "defense"/"Defense" missen. De
/// collecties zijn klein (tientallen tot enkele honderden documenten).
///
/// Optioneel wordt ook de oude globale tag-lijst ([tagListDoc] →
/// [tagListField], bv. `settings/text` → `textTags`) bijgewerkt, zodat die
/// consistent blijft met de items.
Future<void> renameTagInCollection({
  required FirebaseFirestore firestore,
  required String collectionPath,
  required String from,
  required String to,
  DocumentReference? tagListDoc,
  String? tagListField,
}) async {
  final snapshot = await firestore.collection(collectionPath).get();
  final updates = <DocumentReference, List<String>>{};
  for (final doc in snapshot.docs) {
    final tags = List<String>.from(doc.data()['tags'] as List? ?? const []);
    if (containsTag(tags, from)) {
      updates[doc.reference] = renameTagIn(tags, from, to);
    }
  }

  var batch = firestore.batch();
  var writes = 0;
  for (final entry in updates.entries) {
    batch.update(entry.key, {'tags': entry.value});
    if (++writes == _maxBatchWrites) {
      await batch.commit();
      batch = firestore.batch();
      writes = 0;
    }
  }

  if (tagListDoc != null && tagListField != null) {
    final data = (await tagListDoc.get()).data() as Map<String, dynamic>?;
    final list = List<String>.from(data?[tagListField] as List? ?? const []);
    batch.set(tagListDoc, {
      tagListField: renameTagIn(list, from, to),
    }, SetOptions(merge: true));
  }

  await batch.commit();
}
