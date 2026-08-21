import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/presentation/set_content_type_fab.dart';

/// The outer Scaffold shared by every display feature's control screen (sketch,
/// image, text, chrono, tabata, team, game). [body] is feature-specific: a
/// [ContentList] for list-shaped features, or an arbitrary widget for the
/// others (chrono's countdown view, tabata's tree editor, team/game's panels).
/// Always renders a "cast to screen" FAB, and optionally an "add" FAB.
class ContentControlScreen extends StatelessWidget {
  const ContentControlScreen({
    super.key,
    required this.body,
    required this.contentType,
    this.addAction,
  });

  final Widget body;
  final DisplayContentType contentType;

  /// Icon/tooltip/callback for the optional "add new item" FAB, bundled into
  /// one nullable record instead of three separately-nullable params — that
  /// made it possible to supply only two of the three and silently drop the
  /// FAB with no warning.
  final ({IconData icon, String tooltip, VoidCallback onPressed})? addAction;

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    final action = addAction;

    return Scaffold(
      body: body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action != null) ...[
            FloatingActionButton(
              onPressed: action.onPressed,
              heroTag: null, // Avoids hero animation conflicts
              tooltip: action.tooltip,
              child: Icon(action.icon),
            ),
            SizedBox(height: metrics.spacingMd),
          ],
          SetContentTypeFAB(contentType: contentType),
        ],
      ),
    );
  }
}
