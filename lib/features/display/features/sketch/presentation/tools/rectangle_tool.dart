import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/drawing_tool_base.dart';

class RectangleTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    SketchCanvasState state,
  ) {
    final color = state.ref.read(selectedColorProvider);
    final isFilled = state.ref.read(fillShapeProvider);
    return RectangleElement(
      id: id,
      color: color,
      strokeWidth: state.ref.read(strokeWidthProvider),
      start: startPoint,
      end: startPoint,
      fillColor: isFilled ? color.withAlpha(125) : null,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    SketchCanvasState state,
  ) {
    return (element as RectangleElement).copyWith(end: newPoint);
  }
}
