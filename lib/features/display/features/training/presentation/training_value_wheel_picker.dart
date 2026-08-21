import 'package:flutter/material.dart';

/// Genereert de geformatteerde items voor een numeriek veld met een vaste
/// stapgrootte tussen [min] en [max] (beide inclusief).
List<String> numericWheelItems({
  required int min,
  required int max,
  required int step,
  String Function(int value)? format,
}) {
  final fmt = format ?? (v) => '$v';
  return [for (var v = min; v <= max; v += step) fmt(v)];
}

/// Geeft de index van [value] in een numerieke reeks `min..max` stap
/// [step] terug, geklemd binnen bereik — bedoeld om `initialIndex` te
/// bepalen vanuit een bestaande waarde.
int numericWheelIndex({
  required int value,
  required int min,
  required int max,
  required int step,
}) {
  final clamped = value.clamp(min, max);
  return ((clamped - min) / step).round();
}

/// Generieke wiel-kiezer: toont [items] in een `ListWheelScrollView`. Werkt
/// zowel voor numerieke velden (REPS/AFSTAND/INTENSITEIT/WERK/RUST/DELTA —
/// [items] is dan een geformatteerde reeks via [numericWheelItems]) als
/// voor vaste waardenlijsten (STROKE/ZONE) — één kaart-agnostische widget
/// in plaats van aparte numerieke/enum-implementaties, per de wens dat
/// beide soorten velden dezelfde wheel-picker-interactie gebruiken.
class TrainingValueWheelPicker extends StatefulWidget {
  const TrainingValueWheelPicker({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onChanged,
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  @override
  State<TrainingValueWheelPicker> createState() =>
      _TrainingValueWheelPickerState();
}

class _TrainingValueWheelPickerState extends State<TrainingValueWheelPicker> {
  late int _selectedIndex = widget.initialIndex;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 40,
            diameterRatio: 1.6,
            perspective: 0.003,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _selectedIndex = index);
              widget.onChanged(index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final selected = index == _selectedIndex;
                return Center(
                  child: Text(
                    widget.items[index],
                    style: TextStyle(
                      fontSize: selected ? 22 : 16,
                      fontFamily: 'monospace',
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Toont [TrainingValueWheelPicker] in een dialoog en geeft de gekozen
/// index terug (`null` als geannuleerd).
Future<int?> showTrainingWheelPicker(
  BuildContext context, {
  required String title,
  required List<String> items,
  required int initialIndex,
}) {
  var selectedIndex = initialIndex;
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TrainingValueWheelPicker(
        items: items,
        initialIndex: initialIndex,
        onChanged: (index) => selectedIndex = index,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selectedIndex),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
