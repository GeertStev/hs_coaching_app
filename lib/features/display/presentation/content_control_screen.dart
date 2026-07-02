import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/presentation/set_content_type_fab.dart';

/// A generic screen widget for managing a list of content (like sketches, images, or texts).
///
/// It provides a consistent layout with a search/tag bar, a content list,
/// and floating action buttons.
class ContentControlScreen extends StatelessWidget {
  const ContentControlScreen({
    super.key,
    required this.contentList,
    required this.contentType,
    this.onAdd,
    this.addIcon,
    this.addTooltip,
  });
  final Widget contentList;
  final VoidCallback? onAdd;
  final IconData? addIcon;
  final String? addTooltip;
  final DisplayContentType contentType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Expanded(child: contentList)]),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onAdd != null && addIcon != null && addTooltip != null) ...[
            FloatingActionButton(
              onPressed: onAdd,
              heroTag: null, // Avoids hero animation conflicts
              tooltip: addTooltip,
              child: Icon(addIcon),
            ),
            const SizedBox(height: 16),
          ],
          SetContentTypeFAB(contentType: contentType),
        ],
      ),
    );
  }
}
