import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';

class PolygonTool implements StatelessTool {
  static const double _closeVertexHitRadius =
      20.0; // Gevoeligheid voor het sluiten van de veelhoek

  @override
  ToolResult onPanStart(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    return ToolResult(state: state); // Geen pan-start acties nodig
  }

  @override
  ToolResult onPanUpdate(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    return ToolResult(state: state); // Geen pan-drag acties nodig
  }

  @override
  ToolResult onPanEnd(DrawingSessionState state, ToolConfig config) {
    return ToolResult(state: state);
  }

  @override
  ToolResult onTapUp(
    Offset localPos,
    DrawingSessionState state,
    ToolConfig config,
  ) {
    final targetPoint = config.transformAndClamp(localPos);
    final temp = state.temporaryElement;

    if (temp == null) {
      // Start een nieuwe veelhoek met het eerste punt
      final newPolygon = PolygonElement(
        id: config.uuid.v4(),
        color: config.color,
        strokeWidth: config.strokeWidth,
        points: [Point(offset: targetPoint, pressure: 1.0)],
        fillColor: config.isFilled ? config.color.withAlpha(125) : null,
      );
      return ToolResult(state: state.copyWith(temporaryElement: newPolygon));
    } else if (temp is PolygonElement) {
      // Bereken de lokale schermpositie van het allereerste punt om hit-testing te doen
      final scaleX = config.actualSize.width / config.targetSize.width;
      final scaleY = config.actualSize.height / config.targetSize.height;
      final firstPointLocal = Offset(
        temp.points.first.offset.dx * scaleX,
        temp.points.first.offset.dy * scaleY,
      );

      final distanceToFirst = (localPos - firstPointLocal).distance;

      // Als de gebruiker dicht bij het eerste punt klikt EN er zijn minimaal 3 punten -> Sluit veelhoek
      if (distanceToFirst <= _closeVertexHitRadius && temp.points.length >= 3) {
        return ToolResult(
          state: state.clear(),
          command: AddElementCommand(
            temp,
          ), // Voeg definitief toe aan de database
        );
      } else {
        // Anders voegen we gewoon een nieuw hoekpunt toe
        final updatedPoints = List<Point>.from(temp.points)
          ..add(Point(offset: targetPoint, pressure: 1.0));

        return ToolResult(
          state: state.copyWith(
            temporaryElement: temp.copyWith(points: updatedPoints),
          ),
        );
      }
    }

    return ToolResult(state: state);
  }
}
