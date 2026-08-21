import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';

abstract class DrawingToolBase implements StatelessTool {
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  );
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  );

  @override
  ToolResult onPanStart(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    final startPoint = config.transformAndClamp(localPos);
    final element = createInitialElement(config.uuid.v4(), startPoint, config);
    return ToolResult(state: state.copyWith(temporaryElement: element));
  }

  @override
  ToolResult onPanUpdate(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    if (state.temporaryElement == null) return ToolResult(state: state);
    final currentPoint = config.transformAndClamp(localPos);

    // Bij update dwingen we een nieuwe state af door copyWith niet direct op temporaryElement toe te passen
    final updatedElement = updateElement(
      state.temporaryElement!,
      currentPoint,
      config,
    );
    return ToolResult(
      state: DrawingSessionState(
        temporaryElement: updatedElement,
        originalElement: state.originalElement,
        panStartOffset: state.panStartOffset,
        interactionMode: state.interactionMode,
        iconMenuRequest: state.iconMenuRequest,
      ),
    );
  }

  @override
  ToolResult onPanEnd(DrawingSessionState state, ToolConfig config) {
    if (state.temporaryElement == null) return ToolResult(state: state.clear());
    return ToolResult(
      state: state.clear(),
      command: AddElementCommand(state.temporaryElement!),
    );
  }

  @override
  ToolResult onTapUp(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    return ToolResult(state: state);
  }
}

class FreehandTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  ) {
    return PathElement(
      id: id,
      color: config.color,
      strokeWidth: config.strokeWidth,
      points: [Point(offset: startPoint, pressure: 1.0)],
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  ) {
    final path = element as PathElement;
    final newPoints = List<Point>.from(path.points)
      ..add(Point(offset: newPoint, pressure: 1.0));
    return path.copyWith(points: newPoints);
  }
}

class LineTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  ) {
    return LineElement(
      id: id,
      color: config.color,
      strokeWidth: config.strokeWidth,
      start: startPoint,
      end: startPoint,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  ) {
    return (element as LineElement).copyWith(end: newPoint);
  }
}

class ArrowTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  ) {
    return ArrowElement(
      id: id,
      color: config.color,
      strokeWidth: config.strokeWidth,
      start: startPoint,
      end: startPoint,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  ) {
    return (element as ArrowElement).copyWith(end: newPoint);
  }
}

class RectangleTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  ) {
    return RectangleElement(
      id: id,
      color: config.color,
      strokeWidth: config.strokeWidth,
      start: startPoint,
      end: startPoint,
      fillColor: config.isFilled ? config.color.withAlpha(125) : null,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  ) {
    return (element as RectangleElement).copyWith(end: newPoint);
  }
}

class CircleTool extends DrawingToolBase {
  @override
  SketchElement createInitialElement(
    String id,
    Offset startPoint,
    ToolConfig config,
  ) {
    return CircleElement(
      id: id,
      color: config.color,
      strokeWidth: config.strokeWidth,
      center: startPoint,
      radius: 0,
      fillColor: config.isFilled ? config.color.withAlpha(125) : null,
    );
  }

  @override
  SketchElement updateElement(
    SketchElement element,
    Offset newPoint,
    ToolConfig config,
  ) {
    final circle = element as CircleElement;
    final radius = (newPoint - circle.center).distance;
    return circle.copyWith(radius: radius);
  }
}
