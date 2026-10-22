import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/chrono/chrono_laps.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/lane_keys.dart';
import 'package:hs_coaching_app/features/display/features/chrono/presentation/chrono_screen_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';
import 'package:hs_coaching_app/core/presentation/error_display.dart';

// Simpele lokale provider voor de dropdown state
class CountdownNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setDuration(int duration) => state = duration;
}

final countdownProvider = NotifierProvider<CountdownNotifier, int>(
  CountdownNotifier.new,
);

class ChronoControlScreen extends ConsumerStatefulWidget {
  const ChronoControlScreen({super.key});

  @override
  ConsumerState<ChronoControlScreen> createState() =>
      _ChronoControlScreenState();
}

class _ChronoControlScreenState extends ConsumerState<ChronoControlScreen> {
  // Baanknoppen (ESP32 als USB-toetsenbord) werken zolang dit scherm open
  // staat, los van welke widget focus heeft.
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final lane = laneForKey(event.logicalKey);
    if (lane == null) return false;
    ref.read(chronoCommandsProvider).recordLap(lane: lane);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final chronoAsync = ref.watch(chronoNotifierProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.chrono,
      body: chronoAsync.when(
        data: (chrono) => _ChronoView(chrono: chrono),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(chronoNotifierProvider),
        ),
      ),
    );
  }
}

class _ChronoView extends ConsumerWidget {
  const _ChronoView({required this.chrono});
  final Chrono chrono;

  String _formatDuration(Duration d) {
    if (d.isNegative) {
      final secondsLeft = (d.inMilliseconds.abs() / 1000).ceil();
      return '- ${secondsLeft.toString().padLeft(2, '0')}';
    }

    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(chronoScreenControllerProvider);
    final commands = ref.read(chronoCommandsProvider);
    final selectedCountdown = ref.watch(countdownProvider);

    final status = chrono.status;
    final colorScheme = Theme.of(context).colorScheme;
    final typography = Theme.of(context).appTypography;
    final metrics = Theme.of(context).appMetrics;
    final buttonLabelStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontSize: 16);

    return Padding(
      padding: EdgeInsets.all(metrics.spacingMd),
      child: Column(
        children: [
          // Tijd Weergave
          Text(
            _formatDuration(elapsed),
            style: typography.timerDisplay.copyWith(
              color: elapsed.isNegative ? colorScheme.error : null,
            ),
          ),
          SizedBox(height: metrics.spacingLg),

          // Bedieningsknoppen
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Knop (Altijd actief, neutrale kleur)
              SizedBox(
                width: 100, // Vaste breedte voor uniformiteit
                height: 48,
                child: ElevatedButton(
                  onPressed: () => commands.reset(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        metrics.radiusDefault,
                      ),
                    ),
                  ),
                  child: Text('Reset', style: buttonLabelStyle),
                ),
              ),
              SizedBox(width: metrics.spacingMd),

              // Start / Pause / Resume (De grootste knop in het midden)
              SizedBox(
                width: 150, // Breder dan de zijknoppen
                height: 54, // Iets hoger voor visuele prioriteit
                child: status == ChronoStatus.running
                    ? ElevatedButton(
                        onPressed: () => commands.pause(chrono),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              metrics.radiusDefault,
                            ),
                          ),
                        ),
                        child: Text('Pause', style: buttonLabelStyle),
                      )
                    : ElevatedButton(
                        onPressed: () => commands.start(
                          chrono,
                          countdownMillis: status == ChronoStatus.paused
                              ? 0
                              : selectedCountdown * 1000,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              metrics.radiusDefault,
                            ),
                          ),
                        ),
                        child: Text(
                          status == ChronoStatus.paused ? 'Resume' : 'Start',
                          style: buttonLabelStyle,
                        ),
                      ),
              ),
              SizedBox(width: metrics.spacingMd),

              // Ronde (Lap) Knop (Altijd in de layout, neutraal indien inactief)
              SizedBox(
                width: 100, // Exact dezelfde breedte als de Reset knop
                height: 48,
                child: ElevatedButton(
                  // Alleen klikbaar als status running is én we uit de countdown zijn
                  onPressed:
                      (status == ChronoStatus.running && !elapsed.isNegative)
                      ? () => commands.recordLap()
                      : null, // null zet de ElevatedButton automatisch op disabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        metrics.radiusDefault,
                      ),
                    ),
                  ),
                  child: Text('Lap', style: buttonLabelStyle),
                ),
              ),
            ],
          ),

          SizedBox(height: metrics.spacingLg),
          // Countdown Card Instellingen
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: metrics.spacingMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: metrics.spacingMd),
                  Text(
                    'Countdown:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(width: metrics.spacingMd),
                  DropdownButton<int>(
                    value: selectedCountdown,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('0s')),
                      DropdownMenuItem(value: 5, child: Text('5s')),
                      DropdownMenuItem(value: 10, child: Text('10s')),
                      DropdownMenuItem(value: 30, child: Text('30s')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(countdownProvider.notifier).setDuration(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: metrics.spacingSm),
          // Max laps: tussentijden + finale tijd per baan
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: metrics.spacingMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: metrics.spacingMd),
                  Text(
                    'Max laps:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(width: metrics.spacingMd),
                  DropdownButton<int?>(
                    value: chrono.maxLaps,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No limit'),
                      ),
                      for (var i = 1; i <= 10; i++)
                        DropdownMenuItem(value: i, child: Text('$i')),
                    ],
                    onChanged: (val) => commands.setMaxLaps(val),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: metrics.spacingLg),

          // Rondetijden Lijst
          if (chrono.lapTimes.isNotEmpty) ...[
            const Divider(),
            Text('Lap times', style: typography.headlineSm),
            SizedBox(height: metrics.gutter),
            Expanded(
              child: Builder(
                builder: (context) {
                  final rows = chronoLapRows(
                    chrono.lapTimes,
                    maxLaps: chrono.maxLaps,
                  );
                  return ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: row.lane == null
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.secondaryContainer,
                          foregroundColor: row.lane == null
                              ? colorScheme.onSurface
                              : colorScheme.onSecondaryContainer,
                          child: Text('${row.lane ?? row.number}'),
                        ),
                        title: Text(
                          '${chronoLapLabel(row, maxLaps: chrono.maxLaps)}: '
                          '${_formatDuration(Duration(milliseconds: row.splitMillis))}',
                          style: typography.dataPoint,
                        ),
                        trailing: Text(
                          'Total: ${_formatDuration(Duration(milliseconds: row.totalMillis))}',
                          style: typography.dataPoint,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
