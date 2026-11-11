import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/presentation/console_button.dart';

/// Hoogste kapnummer (CMAS 3.3.5: 1 tot 15).
const int maxCapNumber = 15;

/// Nummerpad 1 tot 15. Eén tik kiest een kap.
class CapPad extends StatelessWidget {
  const CapPad({super.key, required this.onSelected, this.selected});

  final ValueChanged<int> onSelected;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Wrap(
      spacing: theme.appMetrics.spacingXs,
      runSpacing: theme.appMetrics.spacingXs,
      children: [
        for (var cap = 1; cap <= maxCapNumber; cap++)
          SizedBox(
            width: ConsoleLayout.padKey,
            height: ConsoleLayout.padKey,
            child: FilledButton(
              key: ValueKey('cap-$cap'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: cap == selected
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                foregroundColor: cap == selected
                    ? colors.onPrimary
                    : colors.onSurface,
              ),
              onPressed: () => onSelected(cap),
              child: Text('$cap', style: theme.appTypography.dataPoint),
            ),
          ),
      ],
    );
  }
}

/// Resultaat van [showGoalCapDialog]: een kap, of bewust geen.
class GoalCapChoice {
  const GoalCapChoice(this.cap);
  final int? cap;
}

/// Vraagt het (optionele) kapnummer van de doelpuntenmaker. `null` betekent
/// dat de tafel het doelpunt toch niet wil registreren.
Future<GoalCapChoice?> showGoalCapDialog(
  BuildContext context, {
  required String title,
}) {
  return showDialog<GoalCapChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 5 * ConsoleLayout.padKey + 40,
        child: CapPad(
          onSelected: (cap) => Navigator.of(context).pop(GoalCapChoice(cap)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(const GoalCapChoice(null)),
          child: const Text('No number'),
        ),
      ],
    ),
  );
}
