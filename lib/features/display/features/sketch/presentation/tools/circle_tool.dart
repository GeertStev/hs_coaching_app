import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/drawing_tool_base.dart';

class CircleTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    SketchCanvasState state,
  ) {
    final color = state.ref.read(selectedColorProvider);
    final isFilled = state.ref.read(fillShapeProvider);
    return CircleElement(
      id: id,
      color: color,
      strokeWidth: state.ref.read(strokeWidthProvider),
      center: startPoint,
      radius: 0,
      fillColor: isFilled ? color.withAlpha(125) : null,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    SketchCanvasState state,
  ) {
    final circle = element as CircleElement;
    final radius = (newPoint - circle.center).distance;
    return circle.copyWith(radius: radius);
  }
}
