import 'package:flutter/services.dart';

/// Bewerkingen voor de opmaakknoppen in de teksteditor. De codes zelf
/// (`**`, `_`, `++`, `# `, `## `) worden gelezen door core's
/// `text_markup.dart`.

/// Zet [marker] rond de selectie, of haalt hem weg als de selectie er al
/// door omringd is. Zonder selectie komen twee codes op de cursor, met de
/// cursor ertussen, zodat je meteen opgemaakt kunt typen.
TextEditingValue toggleInlineMarker(TextEditingValue value, String marker) {
  final text = value.text;
  final selection = _validSelection(value);
  final start = selection.start;
  final end = selection.end;
  final m = marker.length;

  final isWrapped =
      start >= m &&
      end + m <= text.length &&
      text.substring(start - m, start) == marker &&
      text.substring(end, end + m) == marker;

  if (isWrapped) {
    final newText =
        text.substring(0, start - m) +
        text.substring(start, end) +
        text.substring(end + m);
    return TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: start - m, extentOffset: end - m),
    );
  }

  final newText =
      text.substring(0, start) +
      marker +
      text.substring(start, end) +
      marker +
      text.substring(end);
  return TextEditingValue(
    text: newText,
    selection: TextSelection(baseOffset: start + m, extentOffset: end + m),
  );
}

/// Maakt van de regel(s) in de selectie een titel van [level] (1 of 2).
/// Is de regel al zo'n titel, dan wordt hij terug gewone tekst.
TextEditingValue toggleHeading(TextEditingValue value, int level) {
  assert(level == 1 || level == 2);
  final prefix = '${'#' * level} ';
  final text = value.text;
  final selection = _validSelection(value);

  final lineStart = selection.start == 0
      ? 0
      : text.lastIndexOf('\n', selection.start - 1) + 1;
  var lineEnd = text.indexOf('\n', selection.end);
  if (lineEnd == -1) lineEnd = text.length;

  final lines = text.substring(lineStart, lineEnd).split('\n');
  // Alle regels al deze titel → weghalen, anders overal deze titel zetten.
  final removeAll = lines.every((line) => _headingLevel(line) == level);

  var startShift = 0;
  var totalShift = 0;
  final newLines = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final current = _headingLevel(line);
    final oldPrefixLength = current == 0 ? 0 : current + 1;
    final body = line.substring(oldPrefixLength);
    final newLine = removeAll ? body : prefix + body;
    final shift = newLine.length - line.length;
    if (i == 0) startShift = shift;
    totalShift += shift;
    newLines.add(newLine);
  }

  final newText =
      text.substring(0, lineStart) +
      newLines.join('\n') +
      text.substring(lineEnd);
  int clamp(int offset) => offset.clamp(lineStart, newText.length);
  return TextEditingValue(
    text: newText,
    selection: TextSelection(
      baseOffset: clamp(selection.start + startShift),
      extentOffset: clamp(selection.end + totalShift),
    ),
  );
}

int _headingLevel(String line) {
  if (line.startsWith('## ')) return 2;
  if (line.startsWith('# ')) return 1;
  return 0;
}

/// Zonder geldige selectie (veld nooit aangeraakt) werken we aan het einde.
TextSelection _validSelection(TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isValid) {
    return TextSelection.collapsed(offset: value.text.length);
  }
  return selection;
}
