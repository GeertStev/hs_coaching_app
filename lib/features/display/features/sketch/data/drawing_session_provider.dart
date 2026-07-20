import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/polygon_tool.dart';
import 'package:uuid/uuid.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_ui_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_service_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/shape_tools.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/eraser_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/select_tool.dart';

final drawingSessionProvider =
    NotifierProvider<DrawingSessionNotifier, DrawingSessionState>(
      DrawingSessionNotifier.new,
    );

class DrawingSessionNotifier extends Notifier<DrawingSessionState> {
  final Uuid _uuid = const Uuid();
  late final Map<DrawingTool, StatelessTool> _tools;

  @override
  DrawingSessionState build() {
    _tools = {
      DrawingTool.freehand: FreehandTool(),
      DrawingTool.arrow: ArrowTool(),
      DrawingTool.line: LineTool(),
      DrawingTool.rectangle: RectangleTool(),
      DrawingTool.polygon: PolygonTool(),
      DrawingTool.circle: CircleTool(),
      DrawingTool.eraser: EraserTool(),
      DrawingTool.select: SelectTool(),
    };
    return const DrawingSessionState();
  }

  ToolConfig _buildConfig(String sketchId, Size actualSize, Size targetSize) {
    return ToolConfig(
      color: ref.read(selectedColorProvider),
      strokeWidth: ref.read(strokeWidthProvider),
      isFilled: ref.read(fillShapeProvider),
      actualSize: actualSize,
      targetSize: targetSize,
      elements: ref.read(sketchElementsStreamProvider(sketchId)).value ?? [],
      selectedElementId: ref.read(selectedElementIdProvider),
      uuid: _uuid,
    );
  }

  void _processResult(ToolResult result, String sketchId) {
    state = result.state;

    if (result.command != null) {
      ref
          .read(commandHistoryProvider(sketchId).notifier)
          .execute(result.command!);
    }

    if (result.clearSelection) {
      ref.read(selectedElementIdProvider.notifier).deselect();
    } else if (result.selectedElementId != null) {
      ref
          .read(selectedElementIdProvider.notifier)
          .select(result.selectedElementId);
    }
  }

  void onPanStart(
    String sketchId,
    Offset localPos,
    Size actualSize,
    Size targetSize,
  ) {
    final tool = _tools[ref.read(activeToolProvider)]!;
    final config = _buildConfig(sketchId, actualSize, targetSize);
    _processResult(tool.onPanStart(localPos, state, config), sketchId);
  }

  void onPanUpdate(
    String sketchId,
    Offset localPos,
    Size actualSize,
    Size targetSize,
  ) {
    final tool = _tools[ref.read(activeToolProvider)]!;
    final config = _buildConfig(sketchId, actualSize, targetSize);
    _processResult(tool.onPanUpdate(localPos, state, config), sketchId);
  }

  void onPanEnd(String sketchId, Size actualSize, Size targetSize) {
    final tool = _tools[ref.read(activeToolProvider)]!;
    final config = _buildConfig(sketchId, actualSize, targetSize);
    _processResult(tool.onPanEnd(state, config), sketchId);
  }

  void onTapUp(
    String sketchId,
    Offset localPos,
    Size actualSize,
    Size targetSize,
  ) {
    final tool = _tools[ref.read(activeToolProvider)]!;
    final config = _buildConfig(sketchId, actualSize, targetSize);
    _processResult(tool.onTapUp(localPos, state, config), sketchId);
  }

  void clearIconMenuRequest() {
    state = const DrawingSessionState();
  }

  void finishCurrentToolSession(String sketchId) {
    final temp = state.temporaryElement;
    // Sluit en bewaar de polygon als deze 3 of meer hoekpunten heeft
    if (temp is PolygonElement && temp.points.length >= 3) {
      ref
          .read(commandHistoryProvider(sketchId).notifier)
          //Klopt dit?
          .execute(AddElementCommand(temp));
    }
    state = const DrawingSessionState();
  }
}
