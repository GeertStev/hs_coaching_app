import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/element_editing.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';
import 'dart:math' as math;

class SelectTool implements StatelessTool {
  static const double _rotationHandleHitRadius = 24.0;
  static const double _dropdownHandleHitSize = 24.0;
  static const double _editHandleHitRadius = 24.0;

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

      if (selectedElement is RectangleElement) {
        final rotationHandle = SketchPainter.getRectangleRotationHandle(
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

      // Handles (eindpunten, hoekpunten, cirkelrand) gaan vóór het verschuiven van de vorm
      if (selectedElement != null) {
        final handleIndex = _getHandleAt(selectedElement, localPos, config);
        if (handleIndex != null) {
          return ToolResult(
            state: state.copyWith(
              interactionMode: 3,
              temporaryElement: selectedElement,
              originalElement: selectedElement,
              panStartOffset: localPos,
              handleIndex: handleIndex,
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
      final delta =
          config.toTarget(localPos) - config.toTarget(state.panStartOffset!);
      updatedElement = translateElement(updatedElement, delta);
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
    } else if (state.interactionMode == 2 &&
        state.originalElement is RectangleElement) {
      // Rechthoek roteren: altijd vanaf het origineel, zodat vastklikken op 45° werkt.
      // panStartOffset blijft het beginpunt van het slepen.
      updatedElement = rotateRectangle(
        state.originalElement! as RectangleElement,
        config.toTarget(state.panStartOffset!),
        config.toTarget(localPos),
      );
    } else if (state.interactionMode == 3 && state.handleIndex != null) {
      updatedElement = moveHandle(
        updatedElement,
        state.handleIndex!,
        config.transformAndClamp(localPos),
      );
    }

    return ToolResult(
      state: DrawingSessionState(
        temporaryElement: updatedElement,
        originalElement: state.originalElement,
        panStartOffset: newPanStartOffset,
        interactionMode: state.interactionMode,
        handleIndex: state.handleIndex,
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

    // Een tik op een handle van het geselecteerde element houdt de selectie
    if (selectedElement != null &&
        _getHandleAt(selectedElement, localPos, config) != null) {
      return ToolResult(state: state.clear());
    }

    // Een tik selecteert alleen; er blijft geen tijdelijk element achter in de sessie
    // (anders tekent de painter een verouderde kopie en blijven tekenhulpen zichtbaar).
    final foundElement = _getElementAt(localPos, config);
    if (foundElement != null) {
      return ToolResult(
        state: state.clear(),
        selectedElementId: foundElement.id,
      );
    }
    return ToolResult(state: state.clear(), clearSelection: true);
  }

  /// Geeft de index (in editHandles) van de handle onder [localPoint], of null.
  int? _getHandleAt(
    SketchElement element,
    Offset localPoint,
    ToolConfig config,
  ) {
    final handles = editHandles(element);
    int? closest;
    var closestDistance = _editHandleHitRadius;
    for (var i = 0; i < handles.length; i++) {
      final distance = (config.toLocal(handles[i]) - localPoint).distance;
      if (distance <= closestDistance) {
        closest = i;
        closestDistance = distance;
      }
    }
    return closest;
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
