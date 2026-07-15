import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/tool.dart';

// When erasing an icon, there is not always an update, the icon is only removed when redrawing

class EraserTool implements Tool {
  void _eraseAtPoint(Offset localPoint, SketchCanvasState state) {
    //final elements = state.ref.read(sketchElementsStreamProvider).value ?? [];
    final elements =
        state.ref
            .read(sketchElementsStreamProvider(state.widget.sketchId))
            .value ??
        [];
    for (final element in elements) {
      if (SketchPainter.elementHitTest(
        element,
        localPoint,
        state.widget.actualSize,
        state.widget.targetSize,
      )) {
        state.addCommand(RemoveElementCommand(element));
        break; // Remove one at a time
      }
    }
  }

  @override
  void onPanStart(DragStartDetails details, SketchCanvasState state) {
    _eraseAtPoint(details.localPosition, state);
  }

  @override
  void onPanUpdate(DragUpdateDetails details, SketchCanvasState state) {
    _eraseAtPoint(details.localPosition, state);
  }

  @override
  void onPanEnd(DragEndDetails details, SketchCanvasState state) {}

  @override
  void onTapUp(TapUpDetails details, SketchCanvasState state) {}
}
