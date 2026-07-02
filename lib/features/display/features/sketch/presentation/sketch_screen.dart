import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/data/display_global_settings_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/toolbar.dart';

class SketchScreen extends ConsumerStatefulWidget {
  const SketchScreen({super.key, required this.sketchId});

  final String sketchId;

  @override
  ConsumerState<SketchScreen> createState() => _SketchScreenState();
}

class _SketchScreenState extends ConsumerState<SketchScreen> {
  @override
  void initState() {
    super.initState();
    // Set the current sketch ID when the screen is initialized.
    // We use a post-frame callback to ensure the provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentSketchIdProvider.notifier).selectSketch(widget.sketchId);
      // Update the timestamp when the sketch is opened for editing.
      final ids = ref.read(displayDeviceIdsProvider);
      ref
          .read(sketchRepositoryProvider)
          .updateSketchTimestamp(widget.sketchId, ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(globalSettingsProvider);
    final sketchAsync = ref.watch(sketchProvider(widget.sketchId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Toolbar()),
            Expanded(
              child: Center(
                child: settings.when(
                  data: (data) {
                    final targetSize = Size(
                      data.width.toDouble(),
                      data.height.toDouble(),
                    );
                    return AspectRatio(
                      aspectRatio: targetSize.aspectRatio,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final actualSize = Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          return sketchAsync.when(
                            data: (sketch) => SketchCanvas(
                              targetSize: targetSize,
                              actualSize: actualSize,
                              backgroundUrl: sketch.backgroundUrl,
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) =>
                                Center(child: Text('Error: $error')),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
