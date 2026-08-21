import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';

/// Wraps [child] in the swipe-to-archive + "currently showing" Card shared by
/// every list-shaped display feature (sketch/image/text). Shape, elevation and
/// border come from the global `CardThemeData` (see [AppTheme]) — this widget
/// only overrides `color`/`shape` for the [isCurrent] state, it never hardcodes
/// its own radius or elevation.
class ContentItemCard extends StatelessWidget {
  const ContentItemCard({
    super.key,
    required this.id,
    required this.title,
    required this.isCurrent,
    required this.onDismissed,
    required this.onUndo,
    required this.onTap,
    required this.child,
  });

  final String id;
  final String title;
  final bool isCurrent;
  final VoidCallback onDismissed;
  final VoidCallback onUndo;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = Theme.of(context).appMetrics;
    final cardRadius = BorderRadius.circular(metrics.radiusDefault);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed();
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('"$title" archived.'),
              action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
            ),
          );
      },
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: metrics.spacingLg),
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      child: Card(
        color: isCurrent ? colorScheme.inversePrimary : null,
        // "Currently showing on screen" is Athletic Blue (both DESIGN_dark.md's
        // and DESIGN_light.md's "Elevation & Depth": primary = "Work"/active
        // states), overriding the theme's default subtle border.
        shape: isCurrent
            ? RoundedRectangleBorder(
                borderRadius: cardRadius,
                side: BorderSide(color: colorScheme.primary, width: 2),
              )
            : null,
        child: InkWell(borderRadius: cardRadius, onTap: onTap, child: child),
      ),
    );
  }
}
