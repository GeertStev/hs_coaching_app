import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';

/// Vaste maten van de console (03 §1: klokknoppen minstens 64 dp).
abstract final class ConsoleLayout {
  static const double buttonHeight = 64;
  static const double clockButtonHeight = 88;
  static const double padKey = 64;
  static const double smallButtonHeight = 48;
  static const double logSeqWidth = 40;
  static const double undoWidth = 112;
  static const double dialogWidth = 760;
  static const double sideColumnWidth = 220;

  /// Hoogstens dit deel van de schermbreedte per teamkolom.
  static const double sideColumnShare = 0.27;
}

enum ConsoleButtonTone { neutral, primary, danger }

/// Knop van de wedstrijdtafel. Is de actie niet toegelaten ([blockedReason]
/// gezet), dan is de knop grijs en toont een lange druk de reden.
class ConsoleButton extends StatelessWidget {
  const ConsoleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.blockedReason,
    this.tone = ConsoleButtonTone.neutral,
    this.height = ConsoleLayout.buttonHeight,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final String? blockedReason;
  final ConsoleButtonTone tone;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final blocked = blockedReason != null;
    final (background, foreground) = switch (tone) {
      ConsoleButtonTone.primary => (colors.primary, colors.onPrimary),
      ConsoleButtonTone.danger => (colors.error, colors.onError),
      ConsoleButtonTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurface,
      ),
    };

    final button = SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: blocked ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: EdgeInsets.symmetric(horizontal: theme.appMetrics.spacingSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              SizedBox(width: theme.appMetrics.spacingXs),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.appTypography.labelCaps,
              ),
            ),
          ],
        ),
      ),
    );
    if (!blocked) return button;

    // Een uitgeschakelde knop vangt zelf geen gebaren; de lange druk komt
    // daarom hier binnen.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(blockedReason!)));
      },
      child: button,
    );
  }
}
