/// Getypte invoer voor de waarde-pills van de Training-editor (muis en
/// toetsenbord): zet tekst als `45`, `1:30`, `400m` of `ab` om naar de
/// index in de wiel-items van dat veld. Puur Dart, los van Flutter.
library;

/// Zet getypte tekst om naar een index in de wiel-items; `null` = ongeldig.
typedef WheelInputParser = int? Function(String text);

/// Geheel getal met optioneel teken en eenheid erachter (`45`, `45x`,
/// `400m`, `80%`, `+10s`, `-5`).
int? parseIntInput(String text) {
  final match = RegExp(
    r'^([+-]?\d+)\s*[a-z%]*$',
  ).firstMatch(text.trim().toLowerCase());
  return match == null ? null : int.parse(match.group(1)!);
}

/// Tijd in seconden: `90` (seconden) of `1:30` (minuten:seconden).
int? parseSecondsInput(String text) {
  final t = text.trim().toLowerCase();
  final minSec = RegExp(r'^(\d+):(\d{1,2})$').firstMatch(t);
  if (minSec != null) {
    final seconds = int.parse(minSec.group(2)!);
    if (seconds >= 60) return null;
    return int.parse(minSec.group(1)!) * 60 + seconds;
  }
  final value = parseIntInput(t);
  return value == null || value < 0 ? null : value;
}

bool _isEmptyInput(String text) {
  final t = text.trim();
  return t.isEmpty || t == '-' || t == '–';
}

/// Parser voor een numeriek veld `min..max` stap [step]. Waarden buiten
/// bereik worden geklemd en tussenliggende waarden afgerond naar de
/// dichtstbijzijnde stap (zelfde regel als `numericWheelIndex`).
/// [nullable]: de items beginnen met "–" (niet ingesteld) op index 0,
/// bereikbaar door een leeg veld of een streepje te typen.
WheelInputParser numericInputParser({
  required int min,
  required int max,
  required int step,
  bool nullable = false,
  int? Function(String text) parseValue = parseIntInput,
}) {
  return (text) {
    if (nullable && _isEmptyInput(text)) return 0;
    final value = parseValue(text);
    if (value == null) return null;
    final index = ((value.clamp(min, max) - min) / step).round();
    return nullable ? index + 1 : index;
  };
}

/// Parser voor een vaste waardenlijst (slag/zone): hoofdletterongevoelig
/// exact op een van de [items]. Begint [items] met "–", dan zet een leeg
/// veld of streepje de waarde terug op niet ingesteld.
WheelInputParser listInputParser(List<String> items) {
  return (text) {
    if (items.isNotEmpty && items.first == '–' && _isEmptyInput(text)) {
      return 0;
    }
    final t = text.trim().toLowerCase();
    final index = items.indexWhere((item) => item.toLowerCase() == t);
    return index < 0 ? null : index;
  };
}
