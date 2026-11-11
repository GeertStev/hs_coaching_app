import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/match/presentation/console_button.dart';
import 'package:hs_coaching_app/features/match/presentation/match_console_controller.dart';
import 'package:hs_coaching_app/features/match/presentation/match_texts.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/match_session.dart';

/// Het eventlog, nieuwste bovenaan, met een undo per regel. Undo wist niets:
/// het voegt een `EventVoided` toe (events zijn append-only).
class EventLogSheet extends ConsumerWidget {
  const EventLogSheet({super.key, required this.session, required this.onUndo});

  final MatchSession session;
  final void Function(MatchEvent event) onUndo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = theme.appMetrics;
    // Herbouwt bij elke wijziging van de wedstrijd.
    final view = ref.watch(matchConsoleProvider(session));
    final state = session.state;
    final events = session.events.reversed.toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(metrics.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event log', style: theme.textTheme.headlineSmall),
            SizedBox(height: metrics.spacingSm),
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final voided = state.voidedEventIds.contains(event.id);
                  final rejected = state.rejectedEvents[event.id];
                  final undo = MatchEventData.eventVoided(targetId: event.id);
                  final rejection = session.check(undo);
                  final blocked = !view.holdsLease
                      ? 'Another device controls this match.'
                      : rejection == null
                      ? null
                      : rejectionMessage(rejection);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: metrics.spacingXs),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ConsoleLayout.logSeqWidth,
                          child: Text(
                            '${event.seq}',
                            style: theme.appTypography.dataPoint,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            [
                              eventLabel(event.data),
                              if (event.source == EventSource.remote)
                                '(remote)',
                              if (voided) '(undone)',
                              if (rejected != null) '(rejected)',
                            ].join(' '),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: voided
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: voided || rejected != null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ConsoleLayout.undoWidth,
                          child: ConsoleButton(
                            key: ValueKey('undo-${event.seq}'),
                            label: 'Undo',
                            icon: Icons.undo,
                            height: ConsoleLayout.smallButtonHeight,
                            blockedReason: blocked,
                            onPressed: () => onUndo(event),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
