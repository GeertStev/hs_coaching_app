import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _hasBeenActivated;

  @override
  void initState() {
    super.initState();
    // Houd bij welke tabbladen al een keer zijn geopend
    _hasBeenActivated = List<bool>.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Markeer de nieuwe index als 'geactiveerd' wanneer de index verandert
    if (oldWidget.index != widget.index) {
      _hasBeenActivated[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        // Bouw het echte scherm als het ooit is geselecteerd
        if (_hasBeenActivated[i]) {
          return widget.children[i];
        }
        // Geef een lege, vrijwel kosteloze widget terug als het nog nooit geselecteerd is
        return const SizedBox.shrink();
      }),
    );
  }
}
