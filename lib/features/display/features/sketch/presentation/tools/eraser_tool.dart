import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';

class EraserTool implements StatelessTool {
  Command? _eraseAtPoint(Offset localPoint, ToolConfig config) {
    // 1. Gum het bovenste icoontje weg als er een klik op is
    final icons = config.elements.whereType<IconElement>().toList();
    for (final el in icons.reversed) {
      if (SketchPainter.elementHitTest(
        el,
        localPoint,
        config.actualSize,
        config.targetSize,
      )) {
        return RemoveElementCommand(el);
      }
    }

    // 2. Gum daarna pas achterliggende vormen weg (van nieuw/boven naar oud/onder)
    final nonIcons = config.elements.where((e) => e is! IconElement).toList();
    for (final el in nonIcons.reversed) {
      if (SketchPainter.elementHitTest(
        el,
        localPoint,
        config.actualSize,
        config.targetSize,
      )) {
        return RemoveElementCommand(el);
      }
    }
    return null;
  }

  @override
  ToolResult onPanStart(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    return ToolResult(state: state, command: _eraseAtPoint(localPos, config));
  }

  @override
  ToolResult onPanUpdate(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    return ToolResult(state: state, command: _eraseAtPoint(localPos, config));
  }

  @override
  ToolResult onPanEnd(DrawingSessionState state, ToolConfig config) =>
      ToolResult(state: state);

  @override
  ToolResult onTapUp(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) => ToolResult(state: state);
}
