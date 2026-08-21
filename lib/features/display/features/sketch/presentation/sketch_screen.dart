import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_global_settings_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
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
  Widget build(BuildContext context) {
    final settings = ref.watch(globalSettingsProvider);
    final sketchAsync = ref.watch(sketchProvider(widget.sketchId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Toolbar(sketchId: widget.sketchId),
            ),
            Expanded(
              child: Center(
                child: settings.when(
                  data: (data) {
                    final targetSize = Size(
                      data.contentWidth.toDouble(),
                      data.contentHeight.toDouble(),
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
                              sketchId: widget.sketchId,
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
