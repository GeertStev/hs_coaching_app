import 'package:flutter/material.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/data/practice_match.dart';
import 'package:hs_coaching_app/features/match/presentation/match_console_screen.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/match/engine/match_config.dart';

/// Startpunt van de wedstrijdmodule. Voorlopig alleen een oefenwedstrijd om
/// de tafel uit te proberen; echte wedstrijden volgen met het
/// voorbereidingsscherm.
class MatchHomeTab extends StatelessWidget {
  const MatchHomeTab({super.key});

  Future<void> _practice(BuildContext context, MatchConfig config) async {
    try {
      final session = await startPracticeMatch(
        config: config,
        nowMillis: () => DateTime.now().millisecondsSinceEpoch,
      );
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MatchConsoleScreen(session: session),
          ),
        );
      }
      await session.dispose();
    } on Object catch (error, stack) {
      reportError(error, stack, context: 'oefenwedstrijd starten');
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: EdgeInsets.all(metrics.containerMargin),
          child: Padding(
            padding: EdgeInsets.all(metrics.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRACTICE MATCH',
                  style: theme.appTypography.labelCaps.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: metrics.spacingXs),
                Text(
                  'Try the match table. Nothing is saved and nothing is '
                  'shown on the pool screen.',
                  style: theme.textTheme.bodyLarge,
                ),
                SizedBox(height: metrics.spacingMd),
                FilledButton(
                  onPressed: () => _practice(context, practiceQuickConfig),
                  child: const Text('Quick practice (2 x 2 min)'),
                ),
                SizedBox(height: metrics.spacingSm),
                OutlinedButton(
                  onPressed: () => _practice(context, const MatchConfig()),
                  child: const Text('CMAS standard (2 x 15 min)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
