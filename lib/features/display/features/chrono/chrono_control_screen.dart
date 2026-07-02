import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/domain/display_content_settings.dart';
import 'package:hs_coaching_app/features/display/features/chrono/data/chrono_provider.dart';
import 'package:hs_coaching_app/features/display/features/chrono/domain/chrono.dart';
import 'package:hs_coaching_app/features/display/features/chrono/presentation/chrono_screen_controller.dart';
import 'package:hs_coaching_app/features/display/presentation/content_control_screen.dart';

/// Screen for controlling and displaying the stopwatch (Chrono).
class ChronoControlScreen extends ConsumerWidget {
  const ChronoControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chronoAsync = ref.watch(chronoProvider);

    return ContentControlScreen(
      contentType: DisplayContentType.chrono,
      contentList: Center(
        child: chronoAsync.when(
          // We pass the chrono data to the view, but the view will use a
          // dedicated controller for its UI logic.
          data: (chrono) => _ChronoView(chrono: chrono),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error loading Chrono: $err'),
        ),
      ),
    );
  }
}

/// The view that displays the chrono controls and the elapsed time.
class _ChronoView extends ConsumerWidget {
  const _ChronoView({required this.chrono});
  final Chrono chrono;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the screen controller for live UI updates.
    final elapsed = ref.watch(chronoScreenControllerProvider);
    final chronoRepo = ref.read(chronoRepositoryProvider);
    final status = chrono.status;

    final bool canReset =
        status == ChronoStatus.paused ||
        (status == ChronoStatus.stopped && chrono.accumulatedElapsedMillis > 0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatDuration(elapsed),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset Button
            ElevatedButton(
              onPressed: canReset ? chronoRepo.reset : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 20),

            // Start/Pause/Resume Button
            if (status == ChronoStatus.running)
              ElevatedButton(
                onPressed: () => chronoRepo.pause(chrono),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Pause'),
              )
            else
              ElevatedButton(
                onPressed: () => chronoRepo.start(chrono),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(status == ChronoStatus.paused ? 'Resume' : 'Start'),
              ),
          ],
        ),
      ],
    );
  }
}
