import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';
import 'dart:math' as math;

class SelectTool implements StatelessTool {
  static const double _rotationHandleHitRadius = 24.0;
  static const double _dropdownHandleHitSize = 24.0;

  @override
  ToolResult onPanStart(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    SketchElement? selectedElement;

    if (config.selectedElementId != null) {
      try {
        selectedElement = config.elements.firstWhere(
          (e) => e.id == config.selectedElementId,
        );
      } catch (_) {}

      if (selectedElement is IconElement) {
        final rotationHandle = SketchPainter.getRotationHandle(
          selectedElement,
          config.actualSize,
          config.targetSize,
        );
        if ((localPos - rotationHandle).distance <= _rotationHandleHitRadius) {
          return ToolResult(
            state: state.copyWith(
              interactionMode: 2,
              temporaryElement: selectedElement,
              originalElement: selectedElement,
              panStartOffset: localPos,
            ),
          );
        }
      }
    }

    final foundElement = _getElementAt(localPos, config);

    if (foundElement != null) {
      // Zodra we de selectie opslaan voor de interactie, bepalen we
      // pas de start-offset (deze moet later wél vergeleken worden,
      // localPos is hier prima als referentiepunt voor onPanUpdate)
      return ToolResult(
        state: state.copyWith(
          interactionMode: 1, // moving
          temporaryElement: foundElement,
          originalElement: foundElement,
          panStartOffset: localPos,
        ),
        selectedElementId: foundElement.id,
      );
    }
    return ToolResult(state: state.clear(), clearSelection: true);
  }

  @override
  ToolResult onPanUpdate(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    if (state.temporaryElement == null || state.panStartOffset == null) {
      return ToolResult(state: state);
    }

    SketchElement updatedElement = state.temporaryElement!;
    Offset newPanStartOffset = state.panStartOffset!;

    if (state.interactionMode == 1) {
      // Moving
      final localDelta = localPos - state.panStartOffset!;
      final scaleX = config.targetSize.width / config.actualSize.width;
      final scaleY = config.targetSize.height / config.actualSize.height;
      final delta = Offset(localDelta.dx * scaleX, localDelta.dy * scaleY);

      updatedElement = updatedElement.map(
        path: (e) => e.copyWith(
          points: e.points
              .map((p) => p.copyWith(offset: p.offset + delta))
              .toList(),
        ),
        arrow: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
        line: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
        rectangle: (e) =>
            e.copyWith(start: e.start + delta, end: e.end + delta),
        polygon: (e) => e.copyWith(
          points: e.points
              .map((p) => p.copyWith(offset: p.offset + delta))
              .toList(),
        ),
        circle: (e) => e.copyWith(center: e.center + delta),
        icon: (e) => e.copyWith(position: e.position + delta),
      );
      newPanStartOffset = localPos;
    } else if (state.interactionMode == 2 && updatedElement is IconElement) {
      // Rotating
      final icon = updatedElement;
      final scaleX = config.actualSize.width / config.targetSize.width;
      final scaleY = config.actualSize.height / config.targetSize.height;
      final localCenter = Offset(
        icon.position.dx * scaleX,
        icon.position.dy * scaleY,
      );
      final startVector = state.panStartOffset! - localCenter;
      final currentVector = localPos - localCenter;

      double angle = currentVector.direction - startVector.direction;

      // Fix voor het plots omklappen door de direction range (-PI tot PI)
      if (angle > math.pi) angle -= 2 * math.pi;
      if (angle < -math.pi) angle += 2 * math.pi;

      updatedElement = icon.copyWith(rotation: icon.rotation + angle);
      newPanStartOffset = localPos;
    }

    return ToolResult(
      state: DrawingSessionState(
        temporaryElement: updatedElement,
        originalElement: state.originalElement,
        panStartOffset: newPanStartOffset,
        interactionMode: state.interactionMode,
      ),
    );
  }

  @override
  ToolResult onPanEnd(DrawingSessionState state, ToolConfig config) {
    Command? cmd;
    if (state.temporaryElement != null && state.originalElement != null) {
      if (state.temporaryElement != state.originalElement) {
        cmd = UpdateElementCommand(
          state.originalElement!,
          state.temporaryElement!,
        );
      }
    }
    return ToolResult(state: state.clear(), command: cmd);
  }

  @override
  ToolResult onTapUp(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    //final tappedPoint = config.transformAndClamp(localPos);
    SketchElement? selectedElement;

    if (config.selectedElementId != null) {
      try {
        selectedElement = config.elements.firstWhere(
          (e) => e.id == config.selectedElementId,
        );
      } catch (_) {}
    }

    if (selectedElement is IconElement) {
      final dropdownHandle = SketchPainter.getDropdownHandle(
        selectedElement,
        config.actualSize,
        config.targetSize,
      );
      final handleRect = Rect.fromCenter(
        center: dropdownHandle,
        width: _dropdownHandleHitSize,
        height: _dropdownHandleHitSize,
      );
      if (handleRect.contains(localPos)) {
        return ToolResult(
          state: state.copyWith(
            iconMenuRequest: IconMenuRequest(selectedElement, localPos),
          ),
        );
      }
    }

    final foundElement = _getElementAt(localPos, config);

    if (foundElement != null) {
      // Zodra we de selectie opslaan voor de interactie, bepalen we
      // pas de start-offset (deze moet later wél vergeleken worden,
      // localPos is hier prima als referentiepunt voor onPanUpdate)
      return ToolResult(
        state: state.copyWith(
          interactionMode: 1, // moving
          temporaryElement: foundElement,
          originalElement: foundElement,
          panStartOffset: localPos,
        ),
        selectedElementId: foundElement.id,
      );
    }
    return ToolResult(state: state.clear(), clearSelection: true);
  }

  SketchElement? _getElementAt(Offset localPoint, ToolConfig config) {
    // 1. Icoontjes liggen visueel bovenaan, test deze dus eerst (van nieuw naar oud).
    final icons = config.elements.whereType<IconElement>().toList();
    for (final el in icons.reversed) {
      if (SketchPainter.elementHitTest(
        el,
        localPoint,
        config.actualSize,
        config.targetSize,
      )) {
        return el;
      }
    }

    // 2. Test daarna de overige elementen (lijnen, rechthoeken, enz. - van nieuw naar oud)
    final nonIcons = config.elements.where((e) => e is! IconElement).toList();
    for (final el in nonIcons.reversed) {
      if (SketchPainter.elementHitTest(
        el,
        localPoint,
        config.actualSize,
        config.targetSize,
      )) {
        return el;
      }
    }

    return null;
  }
}
