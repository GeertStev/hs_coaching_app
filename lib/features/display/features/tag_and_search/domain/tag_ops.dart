/// Zuivere, Flutter-vrije bewerkingen op tag-lijsten, gedeeld door alle
/// content-types met tags (sketch, image, text, training-templates).
///
/// Tags worden hoofdletter-ongevoelig vergeleken: "Defense" en "defense" zijn
/// dezelfde tag. De spelling die als eerste gebruikt werd, blijft behouden.
library;

/// Vergelijkingssleutel voor een tag (getrimd, kleine letters).
String tagKey(String tag) => tag.trim().toLowerCase();

/// Geeft de bestaande spelling uit [existing] terug als [input] daar
/// hoofdletter-ongevoelig in voorkomt, anders [input] getrimd. Leeg blijft
/// leeg.
String canonicalTag(String input, Iterable<String> existing) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  final key = tagKey(trimmed);
  for (final tag in existing) {
    if (tagKey(tag) == key) return tag;
  }
  return trimmed;
}

/// Of [tags] de tag [tag] bevat (hoofdletter-ongevoelig).
bool containsTag(Iterable<String> tags, String tag) {
  final key = tagKey(tag);
  return tags.any((t) => tagKey(t) == key);
}

/// Verwijdert dubbels (hoofdletter-ongevoelig) en lege tags; de eerste
/// spelling en de volgorde blijven behouden.
List<String> dedupeTags(Iterable<String> tags) {
  final seen = <String>{};
  final result = <String>[];
  for (final tag in tags) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) continue;
    if (seen.add(tagKey(trimmed))) result.add(trimmed);
  }
  return result;
}

/// Vervangt [from] door [to] in [tags]. Bestaat [to] al in de lijst, dan
/// worden ze samengevoegd (geen dubbel). Een lege [to] verwijdert [from].
List<String> renameTagIn(List<String> tags, String from, String to) {
  final fromKey = tagKey(from);
  final replaced = [for (final tag in tags) tagKey(tag) == fromKey ? to : tag];
  return dedupeTags(replaced);
}

/// Verwijdert [tag] uit [tags] (hoofdletter-ongevoelig).
List<String> removeTagFrom(List<String> tags, String tag) =>
    renameTagIn(tags, tag, '');

/// Telt per tag in hoeveel items hij voorkomt, alfabetisch gesorteerd
/// (hoofdletter-ongevoelig). Varianten in hoofdletters tellen samen onder de
/// eerst geziene spelling.
Map<String, int> countTags(Iterable<List<String>> itemTags) {
  final spelling = <String, String>{};
  final counts = <String, int>{};
  for (final tags in itemTags) {
    for (final tag in dedupeTags(tags)) {
      final key = tagKey(tag);
      spelling.putIfAbsent(key, () => tag);
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }
  final keys = counts.keys.toList()..sort();
  return {for (final key in keys) spelling[key]!: counts[key]!};
}

/// Of een item met [itemTags] alle [selected] tags heeft (EN-filter). Een lege
/// selectie laat alles door.
bool matchesAllTags(Iterable<String> itemTags, Iterable<String> selected) {
  if (selected.isEmpty) return true;
  final keys = itemTags.map(tagKey).toSet();
  return selected.every((tag) => keys.contains(tagKey(tag)));
}

/// Suggesties voor de tag-invoer: alle tags uit [allTags] die nog niet in
/// [current] zitten en [query] bevatten. Een lege [query] geeft ze allemaal,
/// zodat de lijst meteen opent bij het aantikken van het veld.
List<String> tagSuggestions({
  required Iterable<String> allTags,
  required Iterable<String> current,
  required String query,
}) {
  final q = tagKey(query);
  return [
    for (final tag in allTags)
      if (!containsTag(current, tag) && tagKey(tag).contains(q)) tag,
  ];
}
