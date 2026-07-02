import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/drawing_tool_base.dart';

class LineTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    SketchCanvasState state,
  ) {
    return LineElement(
      id: id,
      color: state.ref.read(selectedColorProvider),
      strokeWidth: state.ref.read(strokeWidthProvider),
      start: startPoint,
      end: startPoint,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    SketchCanvasState state,
  ) {
    return (element as LineElement).copyWith(end: newPoint);
  }
}
