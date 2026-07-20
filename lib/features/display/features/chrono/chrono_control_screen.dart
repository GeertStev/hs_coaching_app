import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';
import 'package:hs_coaching_app/features/display/features/chrono/presentation/chrono_screen_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

// Simpele lokale provider voor de dropdown state
class CountdownNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setDuration(int duration) => state = duration;
}

final countdownProvider = NotifierProvider<CountdownNotifier, int>(
  CountdownNotifier.new,
);

class ChronoControlScreen extends ConsumerWidget {
  const ChronoControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chronoAsync = ref.watch(chronoNotifierProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.chrono,
      contentList: chronoAsync.when(
        data: (chrono) => _ChronoView(chrono: chrono),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading Chrono: $err')),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Tijd Weergave
          Text(
            _formatDuration(elapsed),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: elapsed.isNegative ? Colors.red : null,
            ),
          ),
          const SizedBox(height: 20),

          // Bedieningsknoppen
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Knop (Altijd actief)
              SizedBox(
                width: 100, // Vaste breedte voor uniformiteit
                height: 48,
                child: ElevatedButton(
                  onPressed: () => commands.reset(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),

              // Start / Pause / Resume (De grootste knop in het midden)
              SizedBox(
                width: 150, // Breder dan de zijknoppen
                height: 54, // Iets hoger voor visuele prioriteit
                child: status == ChronoStatus.running
                    ? ElevatedButton(
                        onPressed: () => commands.pause(chrono),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Pause',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => commands.start(
                          chrono,
                          countdownMillis: status == ChronoStatus.paused
                              ? 0
                              : selectedCountdown * 1000,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          status == ChronoStatus.paused ? 'Resume' : 'Start',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Ronde (Lap) Knop (Altijd in de layout, grijs indien inactief)
              SizedBox(
                width: 100, // Exact dezelfde breedte als de Reset knop
                height: 48,
                child: ElevatedButton(
                  // Alleen klikbaar als status running is én we uit de countdown zijn
                  onPressed:
                      (status == ChronoStatus.running && !elapsed.isNegative)
                      ? () => commands.lap(chrono, elapsed.inMilliseconds)
                      : null, // null zet de ElevatedButton automatisch op disabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ronde'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // Countdown Card Instellingen
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up, color: Colors.blueGrey),
                  const SizedBox(width: 16),
                  const Text(
                    'Countdown:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
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

          const SizedBox(height: 20),

          // Rondetijden Lijst
          if (chrono.laps.isNotEmpty) ...[
            const Divider(),
            const Text(
              'Rondetijden',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: chrono.laps.length,
                itemBuilder: (context, index) {
                  final lapTotal = chrono.laps[index];
                  final previousLapTotal = index > 0
                      ? chrono.laps[index - 1]
                      : 0;
                  final lapTime = lapTotal - previousLapTotal;

                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(
                      'Rondetijd: ${_formatDuration(Duration(milliseconds: lapTime))}',
                    ),
                    trailing: Text(
                      'Totaal: ${_formatDuration(Duration(milliseconds: lapTotal))}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
