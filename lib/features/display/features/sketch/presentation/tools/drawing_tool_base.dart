import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/tool.dart';

/// A base class for simple drawing tools that create an element between a
/// start and end point (e.g., Line, Arrow, Rectangle).
abstract class DrawingToolBase implements Tool {
  SketchElement? _element;

  /// Creates the initial [SketchElement] when the pan gesture starts.
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    SketchCanvasState state,
  );

  /// Updates the [SketchElement] as the pan gesture continues.
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    SketchCanvasState state,
  );

  @override
  void onPanStart(DragStartDetails details, SketchCanvasState state) {
    final startPoint = state.transformAndClampOffset(details.localPosition);
    _element = createInitialElement(state.uuid.v4(), startPoint, state);
    state.setTemporaryElement(_element);
  }

  @override
  void onPanUpdate(DragUpdateDetails details, SketchCanvasState state) {
    if (_element == null) return;
    final currentPoint = state.transformAndClampOffset(details.localPosition);
    _element = updateElement(_element!, currentPoint, state);
    state.setTemporaryElement(_element);
  }

  @override
  Future<void> onPanEnd(DragEndDetails details, SketchCanvasState state) async {
    if (_element == null) return;
    await state.addCommand(AddElementCommand(_element!));
    state.clearTemporaryElement();
    _element = null;
  }

  @override
  void onTapUp(TapUpDetails details, SketchCanvasState state) {
    // Not used by simple drawing tools
  }
}
