import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_coaching_app/features/display/features/training/domain/training_value_input.dart';

export 'package:hs_coaching_app/features/display/features/training/domain/training_value_input.dart';

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

/// Laat de muis ook slepen in een wiel: Flutter staat slepen in een
/// scrollbare lijst standaard enkel toe voor touch/stylus, waardoor de
/// wielen op web/desktop met de muis niet te draaien waren.
Widget mouseDraggableWheel(BuildContext context, Widget wheel) {
  return ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
      scrollbars: false,
    ),
    child: wheel,
  );
}

/// Zet scrollwiel-beweging om in stappen van precies één item. Een
/// muiswiel-klik levert in één event een grote delta (~100 px), een
/// trackpad veel kleine: die worden opgeteld tot [threshold].
class WheelScrollStepper {
  static const threshold = 40.0;
  double _accumulated = 0;

  /// +1 (volgend item), -1 (vorig) of 0 (nog geen volle stap).
  int add(double dy) {
    _accumulated += dy;
    if (_accumulated.abs() < threshold) return 0;
    final step = _accumulated > 0 ? 1 : -1;
    _accumulated = 0;
    return step;
  }
}

/// Vangt het muiswiel op boven een wiel-item, vóór de [Scrollable] van het
/// wiel zelf (dieper in de hit-test, dus eerst aan de beurt bij de
/// `pointerSignalResolver`) — anders schuift het wiel per pixel i.p.v. per
/// item en klikt het niet vast. [canStep] geeft aan of er in die richting
/// nog een item is; zo niet, dan scrollt de omliggende lijst gewoon verder.
class WheelItemScrollListener extends StatelessWidget {
  const WheelItemScrollListener({
    super.key,
    required this.stepper,
    required this.canStep,
    required this.onStep,
    required this.child,
  });

  final WheelScrollStepper stepper;
  final bool Function(int direction) canStep;
  final ValueChanged<int> onStep;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final dy = event.scrollDelta.dy;
        if (dy == 0 || !canStep(dy > 0 ? 1 : -1)) return;
        GestureBinding.instance.pointerSignalResolver.register(event, (e) {
          final step = stepper.add((e as PointerScrollEvent).scrollDelta.dy);
          if (step != 0) onStep(step);
        });
      },
      child: child,
    );
  }
}

/// Generieke wiel-kiezer: toont [items] in een `ListWheelScrollView`. Werkt
/// zowel voor numerieke velden (REPS/AFSTAND/INTENSITEIT/WERK/RUST/DELTA —
/// [items] is dan een geformatteerde reeks via [numericWheelItems]) als
/// voor vaste waardenlijsten (STROKE/ZONE) — één kaart-agnostische widget
/// in plaats van aparte numerieke/enum-implementaties, per de wens dat
/// beide soorten velden dezelfde wheel-picker-interactie gebruiken.
/// [controller] is van de aanroeper, zodat getypte invoer het wiel kan
/// meedraaien (zie [showTrainingWheelPicker]).
class TrainingValueWheelPicker extends StatefulWidget {
  const TrainingValueWheelPicker({
    super.key,
    required this.items,
    required this.controller,
    required this.onChanged,
  });

  final List<String> items;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;

  @override
  State<TrainingValueWheelPicker> createState() =>
      _TrainingValueWheelPickerState();
}

class _TrainingValueWheelPickerState extends State<TrainingValueWheelPicker> {
  late int _selectedIndex = widget.controller.initialItem;
  final _stepper = WheelScrollStepper();

  void _step(int delta) {
    final target = (_selectedIndex + delta).clamp(0, widget.items.length - 1);
    widget.controller.animateToItem(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
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
          mouseDraggableWheel(
            context,
            ListWheelScrollView.useDelegate(
              controller: widget.controller,
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
                  return WheelItemScrollListener(
                    stepper: _stepper,
                    canStep: (direction) {
                      final target = _selectedIndex + direction;
                      return target >= 0 && target < widget.items.length;
                    },
                    onStep: _step,
                    child: Center(
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
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Toont een dialoog met een invulveld en [TrainingValueWheelPicker] en
/// geeft de gekozen index terug (`null` als geannuleerd). Typen draait het
/// wiel mee; ↑/↓ in het invulveld kiest het vorige/volgende item, Enter
/// bevestigt. [parseInput] zet getypte tekst om naar een index (standaard:
/// exact een van de [items], hoofdletterongevoelig).
Future<int?> showTrainingWheelPicker(
  BuildContext context, {
  required String title,
  required List<String> items,
  required int initialIndex,
  WheelInputParser? parseInput,
  String? inputHint,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _WheelPickerDialog(
      title: title,
      items: items,
      initialIndex: initialIndex,
      parseInput: parseInput ?? listInputParser(items),
      inputHint: inputHint,
    ),
  );
}

class _WheelPickerDialog extends StatefulWidget {
  const _WheelPickerDialog({
    required this.title,
    required this.items,
    required this.initialIndex,
    required this.parseInput,
    this.inputHint,
  });

  final String title;
  final List<String> items;
  final int initialIndex;
  final WheelInputParser parseInput;
  final String? inputHint;

  @override
  State<_WheelPickerDialog> createState() => _WheelPickerDialogState();
}

class _WheelPickerDialogState extends State<_WheelPickerDialog> {
  late int _selectedIndex = widget.initialIndex;
  late final _wheelController = FixedExtentScrollController(
    initialItem: widget.initialIndex,
  );
  late final _textController =
      TextEditingController(text: widget.items[widget.initialIndex])
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.items[widget.initialIndex].length,
        );
  bool _invalid = false;
  // Waar tijdens het meedraaien vanuit getypte tekst, zodat het wiel de
  // tekst die de coach aan het typen is niet overschrijft.
  bool _syncingFromText = false;

  @override
  void dispose() {
    _wheelController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final index = widget.parseInput(text);
    setState(() => _invalid = index == null);
    if (index == null || index == _selectedIndex) return;
    _syncingFromText = true;
    _wheelController.jumpToItem(index);
    _syncingFromText = false;
  }

  void _onWheelChanged(int index) {
    _selectedIndex = index;
    if (_syncingFromText) return;
    final text = widget.items[index];
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: 0, extentOffset: text.length),
    );
    if (_invalid) setState(() => _invalid = false);
  }

  void _step(int delta) {
    final target = (_selectedIndex + delta).clamp(0, widget.items.length - 1);
    _wheelController.jumpToItem(target);
  }

  void _submit() {
    if (_invalid) return;
    Navigator.of(context).pop(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                    _step(-1),
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    _step(1),
              },
              child: TextField(
                controller: _textController,
                autofocus: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.inputHint,
                  errorText: _invalid ? 'Unknown value' : null,
                ),
                onChanged: _onTextChanged,
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TrainingValueWheelPicker(
            items: widget.items,
            controller: _wheelController,
            onChanged: _onWheelChanged,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _invalid ? null : _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
