import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';

/// Bevat alle instellingen en context die een tool nodig heeft om een actie uit te voeren.
class ToolConfig {
  final Color color;
  final int strokeWidth;
  final bool isFilled;
  final Size actualSize;
  final Size targetSize;
  final List<SketchElement> elements;
  final String? selectedElementId;
  final Uuid uuid;

  const ToolConfig({
    required this.color,
    required this.strokeWidth,
    required this.isFilled,
    required this.actualSize,
    required this.targetSize,
    required this.elements,
    this.selectedElementId,
    required this.uuid,
  });

  /// Vertaalt een lokale canvas-coördinaat naar doelscherm-coördinaten, zonder begrenzing.
  Offset toTarget(Offset localOffset) {
    if (actualSize.isEmpty || targetSize.isEmpty) return localOffset;
    return Offset(
      localOffset.dx * targetSize.width / actualSize.width,
      localOffset.dy * targetSize.height / actualSize.height,
    );
  }

  /// Vertaalt een doelscherm-coördinaat naar de lokale canvas-coördinaat.
  Offset toLocal(Offset targetOffset) {
    if (actualSize.isEmpty || targetSize.isEmpty) return targetOffset;
    return Offset(
      targetOffset.dx * actualSize.width / targetSize.width,
      targetOffset.dy * actualSize.height / targetSize.height,
    );
  }

  /// Vertaalt een lokale canvas-coördinaat naar de doelscherm-coördinaten.
  Offset transformAndClamp(Offset localOffset) {
    if (actualSize.isEmpty || targetSize.isEmpty) return localOffset;
    final scaleX = targetSize.width / actualSize.width;
    final scaleY = targetSize.height / actualSize.height;
    return Offset(
      (localOffset.dx * scaleX).clamp(0.0, targetSize.width),
      (localOffset.dy * scaleY).clamp(0.0, targetSize.height),
    );
  }
}

class IconMenuRequest {
  final IconElement element;
  final Offset localPosition;
  const IconMenuRequest(this.element, this.localPosition);
}

/// De interne state van een lopende teken- of sleepactie.
class DrawingSessionState {
  final SketchElement? temporaryElement;
  final SketchElement? originalElement;
  final Offset? panStartOffset;
  final int
  interactionMode; // 0: none, 1: moving, 2: rotating, 3: handle verslepen
  final IconMenuRequest? iconMenuRequest;
  // Index in editHandles() van de handle die versleept wordt (interactionMode 3)
  final int? handleIndex;

  const DrawingSessionState({
    this.temporaryElement,
    this.originalElement,
    this.panStartOffset,
    this.interactionMode = 0,
    this.iconMenuRequest,
    this.handleIndex,
  });

  DrawingSessionState copyWith({
    SketchElement? temporaryElement,
    SketchElement? originalElement,
    Offset? panStartOffset,
    int? interactionMode,
    IconMenuRequest? iconMenuRequest,
    int? handleIndex,
  }) {
    return DrawingSessionState(
      temporaryElement: temporaryElement ?? this.temporaryElement,
      originalElement: originalElement ?? this.originalElement,
      panStartOffset: panStartOffset ?? this.panStartOffset,
      interactionMode: interactionMode ?? this.interactionMode,
      iconMenuRequest: iconMenuRequest ?? this.iconMenuRequest,
      handleIndex: handleIndex ?? this.handleIndex,
    );
  }

  DrawingSessionState clear() => const DrawingSessionState();
}

/// Het resultaat van een tool-actie: update de sessie-state, voer een commando uit, of pas de selectie aan.
class ToolResult {
  final DrawingSessionState state;
  final Command? command;
  final String? selectedElementId;
  final bool clearSelection;

  const ToolResult({
    required this.state,
    this.command,
    this.selectedElementId,
    this.clearSelection = false,
  });
}

/// De puur functionele interface voor alle canvas tools.
abstract class StatelessTool {
  ToolResult onPanStart(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  );
  ToolResult onPanUpdate(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  );
  ToolResult onPanEnd(DrawingSessionState state, ToolConfig config);
  ToolResult onTapUp(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  );
}
