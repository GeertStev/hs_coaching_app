import 'package:flutter/material.dart';

/// Visuele nesting-indicator: inspringing + een verticale accentlijn links,
/// kleur bepaald door [level] (0 = root, 1 = binnen een set, 2 = binnen een
/// subset). Alle drie kaartwidgets (Set/Subset/Exercise) gebruiken dezelfde
/// wrapper zodat nesting overal consistent zichtbaar is, ook al leven ze in
/// aparte bestanden.
class IndentedGuide extends StatelessWidget {
  const IndentedGuide({super.key, required this.level, required this.child});

  final int level;
  final Widget child;

  static const _palette = [Colors.indigo, Colors.teal];

  @override
  Widget build(BuildContext context) {
    if (level <= 0) return child;
    final color = _palette[(level - 1).clamp(0, _palette.length - 1)];
    return Padding(
      padding: EdgeInsets.only(left: 12.0 * level),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color.withValues(alpha: 0.6), width: 3),
          ),
        ),
        child: Padding(padding: const EdgeInsets.only(left: 8), child: child),
      ),
    );
  }
}
