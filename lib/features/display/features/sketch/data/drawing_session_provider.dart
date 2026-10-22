import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/element_editing.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
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
      final isNewSelection =
          result.selectedElementId != ref.read(selectedElementIdProvider);
      ref
          .read(selectedElementIdProvider.notifier)
          .select(result.selectedElementId);
      if (isNewSelection) _syncToolbarWithSelection(sketchId);
    }
  }

  SketchElement? _selectedElement(String sketchId) {
    final id = ref.read(selectedElementIdProvider);
    if (id == null) return null;
    final elements = ref.read(sketchElementsStreamProvider(sketchId)).value;
    for (final element in elements ?? const <SketchElement>[]) {
      if (element.id == id) return element;
    }
    return null;
  }

  /// Toont kleur, dikte en vulling van het geselecteerde element in de toolbar.
  void _syncToolbarWithSelection(String sketchId) {
    final selected = _selectedElement(sketchId);
    final (Color, int, Color?)? style = switch (selected) {
      PathElement(:final color, :final strokeWidth) => (
        color,
        strokeWidth,
        null,
      ),
      ArrowElement(:final color, :final strokeWidth) => (
        color,
        strokeWidth,
        null,
      ),
      LineElement(:final color, :final strokeWidth) => (
        color,
        strokeWidth,
        null,
      ),
      RectangleElement(:final color, :final strokeWidth, :final fillColor) ||
      PolygonElement(:final color, :final strokeWidth, :final fillColor) ||
      CircleElement(
        :final color,
        :final strokeWidth,
        :final fillColor,
      ) => (color, strokeWidth, fillColor),
      IconElement() || null => null,
    };
    if (style == null) return;
    final (color, strokeWidth, fillColor) = style;

    // Alleen waarden die de toolbar kent, anders faalt de dropdown
    for (final option in sketchColors) {
      if (option.toARGB32() == color.toARGB32()) {
        ref.read(selectedColorProvider.notifier).setColor(option);
      }
    }
    if (sketchStrokeWidths.contains(strokeWidth)) {
      ref.read(strokeWidthProvider.notifier).setStrokeWidth(strokeWidth);
    }
    if (isFillable(selected!)) {
      ref.read(fillShapeProvider.notifier).set(fillColor != null);
    }
  }

  /// Past kleur, dikte of vulling toe op het geselecteerde element (met undo).
  /// Doet niets als er niets geselecteerd is.
  void restyleSelection(
    String sketchId, {
    Color? color,
    int? strokeWidth,
    bool? filled,
  }) {
    final selected = _selectedElement(sketchId);
    if (selected == null) return;
    final updated = applyStyle(
      selected,
      color: color,
      strokeWidth: strokeWidth,
      filled: filled,
    );
    if (updated == selected) return;
    ref
        .read(commandHistoryProvider(sketchId).notifier)
        .execute(UpdateElementCommand(selected, updated));
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
