import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/tool.dart';

class FreehandTool implements Tool {
  PathElement? _path;

  @override
  void onPanStart(DragStartDetails details, SketchCanvasState state) {
    final startPoint = state.transformAndClampOffset(details.localPosition);
    _path = PathElement(
      id: state.uuid.v4(),
      color: state.ref.read(selectedColorProvider),
      strokeWidth: state.ref.read(strokeWidthProvider),
      points: [Point(offset: startPoint, pressure: 1.0)],
    );
    state.setTemporaryElement(_path);
  }

  @override
  void onPanUpdate(DragUpdateDetails details, SketchCanvasState state) {
    if (_path == null) return;
    final currentPoint = state.transformAndClampOffset(details.localPosition);
    final newPoints = List<Point>.from(_path!.points)
      ..add(Point(offset: currentPoint, pressure: 1.0));
    _path = _path!.copyWith(points: newPoints);
    state.setTemporaryElement(_path);
  }

  @override
  Future<void> onPanEnd(DragEndDetails details, SketchCanvasState state) async {
    if (_path == null) return;
    await state.addCommand(AddElementCommand(_path!));
    state.clearTemporaryElement();
    _path = null;
  }

  @override
  void onTapUp(TapUpDetails details, SketchCanvasState state) {
    // Not used by freehand tool
  }
}
