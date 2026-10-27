import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_value_wheel_picker.dart';

/// Rechtstreeks draaibare waarde-pill, zelfde stijl als Tabata's `_Pill`
/// (gekleurde vulling + rand + tekst) maar zelf een compacte
/// [ListWheelScrollView]: verticaal binnen de pill slepen/vegen (touch én
/// muis) wijzigt [items]`[index]` rechtstreeks, met snap-physics per stap
/// ([FixedExtentScrollPhysics]). De pillbreedte wordt vastgeklikt op de
/// breedste tekst in [items] zodat ze niet meebeweegt tijdens het scrollen.
///
/// Voor muis en toetsenbord: het muiswiel draait per item, tikken/klikken
/// opent [showTrainingWheelPicker] om de waarde te typen ([parseInput]),
/// met de focus op de pill kiezen ↑/↓ het vorige/volgende item en opent
/// Enter/spatie het invulveld. [onLongPress] (rij verwijderen) zit ook
/// onder rechtsklik.
class TrainingValuePill extends StatefulWidget {
  const TrainingValuePill({
    super.key,
    required this.title,
    required this.items,
    required this.initialIndex,
    required this.color,
    required this.onChanged,
    this.parseInput,
    this.inputHint,
    this.onLongPress,
    this.label,
  });

  /// Titel van het invuldialoog (bv. "Distance").
  final String title;
  final List<String> items;
  final int initialIndex;
  final Color color;
  final ValueChanged<int> onChanged;
  final WheelInputParser? parseInput;
  final String? inputHint;
  final VoidCallback? onLongPress;

  /// Klein bijschrift boven de pill (bv. "Work"), zodat de drie
  /// tijd-pills (werk/rust/delta) niet te verwarren zijn.
  final String? label;

  @override
  State<TrainingValuePill> createState() => _TrainingValuePillState();
}

const _kValuePillTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'monospace',
);

class _TrainingValuePillState extends State<TrainingValuePill> {
  static const _itemExtent = 34.0;
  // Eén gedeelde breedte voor alle pills (werk/rust/delta, de 5
  // parameter-velden en de herhaling op de kaarten) i.p.v. elke pill zijn eigen items meten — staat
  // strakker op één lijn, en scheelt de meet-stap per instantie. Eén keer
  // berekend (static) op basis van de breedst mogelijke waarden die
  // ergens voorkomen ("2000m", "15:00" — beide 5 tekens); alle andere
  // velden (max 4 tekens, of "–" voor niet ingesteld) blijven daarbinnen.
  static final double _width = _computeWidth();

  static double _computeWidth() {
    var max = 0.0;
    for (final text in const ['2000m', '15:00']) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _kValuePillTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width > max) max = painter.width;
    }
    return max + 20;
  }

  // Muiswiel/pijltjes: wachten met vastleggen tot er even niet meer
  // gedraaid wordt, zodat tien snelle wielklikken één rebuild + één write
  // geven i.p.v. tien (zelfde reden als de ScrollEndNotification hieronder).
  static const _commitDelay = Duration(milliseconds: 400);

  late int _selectedIndex = widget.initialIndex;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialIndex);
  final _focusNode = FocusNode();
  final _stepper = WheelScrollStepper();
  bool _focused = false;
  Timer? _commitTimer;
  // Waar tijdens een programmatische jumpToItem: die stuurt ook een
  // ScrollEndNotification, die mag niet meteen vastleggen.
  bool _jumping = false;

  @override
  void didUpdateWidget(TrainingValuePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Volg externe wijzigingen (bv. undo) zonder een lopend sleepgebaar te
    // breken — enkel overnemen als de waarde niet al lokaal geselecteerd is.
    if (widget.initialIndex != _selectedIndex &&
        widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = widget.initialIndex;
      _jumpTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _commitTimer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    _jumping = true;
    _controller.jumpToItem(index);
    _jumping = false;
  }

  bool _canStep(int direction) {
    final target = _selectedIndex + direction;
    return target >= 0 && target < widget.items.length;
  }

  void _step(int delta) {
    final target = (_selectedIndex + delta).clamp(0, widget.items.length - 1);
    if (target == _selectedIndex) return;
    _jumpTo(target);
    _selectedIndex = target;
    _commitTimer?.cancel();
    _commitTimer = Timer(_commitDelay, () => widget.onChanged(_selectedIndex));
  }

  Future<void> _openInput() async {
    final index = await showTrainingWheelPicker(
      context,
      title: widget.title,
      items: widget.items,
      initialIndex: _selectedIndex,
      parseInput: widget.parseInput,
      inputHint: widget.inputHint,
    );
    if (index == null || !mounted) return;
    _commitTimer?.cancel();
    if (index != _selectedIndex) _jumpTo(index);
    widget.onChanged(index);
  }

  Future<void> _showContextMenu(Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit value')),
        if (widget.onLongPress != null)
          const PopupMenuItem(value: 'remove', child: Text('Remove row')),
      ],
    );
    if (!mounted) return;
    switch (action) {
      case 'edit':
        _openInput();
      case 'remove':
        widget.onLongPress?.call();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _focusNode.unfocus();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _step(-1);
    } else if (event is KeyDownEvent &&
        (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space)) {
      _openInput();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    // Klikken geeft de pill geen focus (enkel Tab doet dat); klikken naast
    // de pill of Escape laat de focus weer los.
    final pill = TapRegion(
      onTapOutside: (_) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: widget.color.withValues(alpha: _focused ? 0.24 : 0.12),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: _width,
              height: _itemExtent,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.color,
                  width: _focused ? 2.5 : 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.5),
                child: GestureDetector(
                  onTap: _openInput,
                  onLongPress: widget.onLongPress,
                  onSecondaryTapUp: (details) =>
                      _showContextMenu(details.globalPosition),
                  // ScrollEndNotification i.p.v. rechtstreeks in
                  // onSelectedItemChanged: dat laatste vuurt bij élke
                  // tussenliggende index tijdens een sleep/fling-gebaar.
                  // widget.onChanged loopt via copyWith helemaal terug naar de
                  // root van de trainingsboom, wat een rebuild van de hele
                  // kaartenlijst triggert — bij een fling door bv. 20 items
                  // dus 20 volle rebuilds. Lokaal (setState) blijft de tekst
                  // wel live meebewegen tijdens het slepen; enkel het
                  // "vastklikken" van de waarde wacht tot het wiel tot rust
                  // komt.
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (notification) {
                      if (!_jumping) {
                        _commitTimer?.cancel();
                        widget.onChanged(_selectedIndex);
                      }
                      return false;
                    },
                    child: mouseDraggableWheel(
                      context,
                      ListWheelScrollView.useDelegate(
                        controller: _controller,
                        itemExtent: _itemExtent,
                        diameterRatio: 1.8,
                        perspective: 0.003,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) =>
                            setState(() => _selectedIndex = index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: widget.items.length,
                          builder: (context, index) => WheelItemScrollListener(
                            stepper: _stepper,
                            canStep: _canStep,
                            onStep: _step,
                            child: Center(
                              child: Text(
                                widget.items[index],
                                style: _kValuePillTextStyle.copyWith(
                                  color: widget.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final label = widget.label;
    if (label == null) return pill;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: widget.color),
        ),
        const SizedBox(height: 2),
        pill,
      ],
    );
  }
}

const _kRepeatCountMin = 1, _kRepeatCountMax = 20, _kRepeatCountStep = 1;

/// Herhaal-icoon + draaibare "Nx"-pill in de kop van een Set/Subset- of
/// oefeningkaart (`TrainingGroup.repeatCount` /
/// `TrainingExercise.repeatCount`), zelfde bediening als de waarde-pills.
class TrainingRepeatCountPill extends StatelessWidget {
  const TrainingRepeatCountPill({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.repeat, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        TrainingValuePill(
          title: 'Repeat count',
          items: numericWheelItems(
            min: _kRepeatCountMin,
            max: _kRepeatCountMax,
            step: _kRepeatCountStep,
            format: (v) => '${v}x',
          ),
          initialIndex: numericWheelIndex(
            value: value,
            min: _kRepeatCountMin,
            max: _kRepeatCountMax,
            step: _kRepeatCountStep,
          ),
          parseInput: numericInputParser(
            min: _kRepeatCountMin,
            max: _kRepeatCountMax,
            step: _kRepeatCountStep,
          ),
          inputHint: 'e.g. 4',
          color: scheme.primary,
          onChanged: (index) =>
              onChanged(_kRepeatCountMin + index * _kRepeatCountStep),
        ),
      ],
    );
  }
}
