import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/select_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:uuid/uuid.dart';

const line = LineElement(
  id: 'l',
  color: Colors.white,
  strokeWidth: 2,
  start: Offset(100, 100),
  end: Offset(300, 100),
);

// Canvas op halve grootte van het doelscherm: lokaal = doel / 2
ToolConfig config({String? selectedId}) => ToolConfig(
  color: Colors.white,
  strokeWidth: 2,
  isFilled: false,
  actualSize: const Size(500, 400),
  targetSize: const Size(1000, 800),
  elements: const [line],
  selectedElementId: selectedId,
  uuid: const Uuid(),
);

void main() {
  final tool = SelectTool();

  test('tik selecteert zonder tijdelijk element achter te laten', () {
    final result = tool.onTapUp(
      const Offset(100, 50),
      const DrawingSessionState(),
      config(),
    );
    expect(result.selectedElementId, 'l');
    expect(result.state.temporaryElement, isNull);
  });

  test('eindpunt van een geselecteerde lijn verslepen', () {
    final c = config(selectedId: 'l');
    var result = tool.onPanStart(
      const Offset(150, 50),
      const DrawingSessionState(),
      c,
    );
    expect(result.state.interactionMode, 3);
    expect(result.state.handleIndex, 1);

    result = tool.onPanUpdate(const Offset(200, 150), result.state, c);
    final moved = result.state.temporaryElement! as LineElement;
    expect(moved.start, const Offset(100, 100));
    expect(moved.end, const Offset(400, 300));

    result = tool.onPanEnd(result.state, c);
    expect(result.command, isA<UpdateElementCommand>());
  });

  test('slepen op het midden van de lijn verschuift de hele lijn', () {
    final c = config(selectedId: 'l');
    var result = tool.onPanStart(
      const Offset(100, 50),
      const DrawingSessionState(),
      c,
    );
    expect(result.state.interactionMode, 1);

    result = tool.onPanUpdate(const Offset(110, 60), result.state, c);
    final moved = result.state.temporaryElement! as LineElement;
    expect(moved.start, const Offset(120, 120));
    expect(moved.end, const Offset(320, 120));
  });
}
