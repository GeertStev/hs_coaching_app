import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_canvas.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/tool.dart';

enum _InteractionMode { none, moving, rotating }

class SelectTool implements Tool {
  // You can adjust the tappable area of the handles here.
  static const double _rotationHandleHitRadius = 12.0;
  static const double _dropdownHandleHitSize = 24.0;

  SketchElement? _selectedElement;
  SketchElement? _originalElementState; // For undo/redo of transformations
  Offset? _panStartOffset;
  _InteractionMode _interactionMode = _InteractionMode.none;

  @override
  void onPanStart(DragStartDetails details, SketchCanvasState state) {
    _selectedElement = null; // Reset on new pan
    _interactionMode = _InteractionMode.none;

    //final elements = state.ref.read(sketchElementsStreamProvider).value ?? [];
    final elements =
        state.ref
            .read(sketchElementsStreamProvider(state.widget.sketchId))
            .value ??
        [];
    final selectedId = state.ref.read(selectedElementIdProvider);

    // Check for interaction with an already selected element's handles
    if (selectedId != null) {
      SketchElement? selectedElement;
      try {
        selectedElement = elements.firstWhere((e) => e.id == selectedId);
      } catch (_) {
        // Element not found
      }
      if (selectedElement != null && selectedElement is IconElement) {
        final rotationHandle = SketchPainter.getRotationHandle(
          selectedElement,
          state.widget.actualSize,
          state.widget.targetSize,
        );
        if ((details.localPosition - rotationHandle).distance <=
            _rotationHandleHitRadius) {
          _interactionMode = _InteractionMode.rotating;
          _selectedElement = selectedElement;
          _originalElementState =
              selectedElement; // Store initial state for undo/redo
          _panStartOffset =
              details.localPosition; // Use local point for rotation
          state.setTemporaryElement(_selectedElement);
          return; // Start rotating
        }
      }
    }
    // If not interacting with a handle, treat it as a move
    final startPoint = state.transformAndClampOffset(details.localPosition);
    if (_selectElementAt(startPoint, state)) {
      _interactionMode = _InteractionMode.moving;
      _originalElementState = _selectedElement; // Store initial state
      _panStartOffset = details.localPosition;
      state.setTemporaryElement(_selectedElement);
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details, SketchCanvasState state) {
    if (_selectedElement == null || _panStartOffset == null) return;

    if (_interactionMode == _InteractionMode.moving) {
      // The delta must be scaled to the target coordinate space
      final localDelta = details.localPosition - _panStartOffset!;
      final scaleX =
          state.widget.targetSize.width / state.widget.actualSize.width;
      final scaleY =
          state.widget.targetSize.height / state.widget.actualSize.height;
      final delta = Offset(localDelta.dx * scaleX, localDelta.dy * scaleY);

      _selectedElement = _selectedElement!.map(
        path: (e) => e.copyWith(
          points: e.points
              .map((p) => p.copyWith(offset: p.offset + delta))
              .toList(),
        ),
        arrow: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
        line: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
        rectangle: (e) =>
            e.copyWith(start: e.start + delta, end: e.end + delta),
        circle: (e) => e.copyWith(center: e.center + delta),
        icon: (e) => e.copyWith(position: e.position + delta),
      );
      state.setTemporaryElement(_selectedElement);
      // Update the start offset for the next delta calculation
      _panStartOffset = details.localPosition;
    } else if (_interactionMode == _InteractionMode.rotating &&
        _selectedElement is IconElement) {
      final icon = _selectedElement as IconElement;

      // Rotation calculations should happen in the local (widget) coordinate space
      final scaleX =
          state.widget.actualSize.width / state.widget.targetSize.width;
      final scaleY =
          state.widget.actualSize.height / state.widget.targetSize.height;
      final localCenter = Offset(
        icon.position.dx * scaleX,
        icon.position.dy * scaleY,
      );

      final startVector = _panStartOffset! - localCenter;
      final currentVector = details.localPosition - localCenter;
      final angle = currentVector.direction - startVector.direction;

      _selectedElement = icon.copyWith(rotation: icon.rotation + angle);
      state.setTemporaryElement(_selectedElement);
      _panStartOffset = details.localPosition;
    }
  }

  @override
  Future<void> onPanEnd(DragEndDetails details, SketchCanvasState state) async {
    if (_selectedElement != null && _originalElementState != null) {
      // Only create an update command if the element has actually changed.
      if (_selectedElement != _originalElementState) {
        await state.addCommand(
          UpdateElementCommand(_originalElementState!, _selectedElement!),
        );
        // By setting the temporary element to the final state, we prevent a flicker.
        // The painter will use this version until the stream from the repository updates.
        // When the stream updates, this temporary element will be identical to the
        // one in the main list, so the transition is seamless.
        state.setTemporaryElement(_selectedElement);
      } else {
        // If no change, just clear the temporary element.
        state.clearTemporaryElement();
      }
    } else {
      state.clearTemporaryElement();
    }
    _originalElementState = null;
    _selectedElement = null;
    _panStartOffset = null;
    _interactionMode = _InteractionMode.none;
  }

  @override
  void onTapUp(TapUpDetails details, SketchCanvasState state) {
    final tappedPoint = state.transformAndClampOffset(details.localPosition);
    final selectedId = state.ref.read(selectedElementIdProvider);

    if (selectedId == null) {
      _selectElementAt(tappedPoint, state);
      return;
    }
    //final elements = state.ref.read(sketchElementsStreamProvider).value ?? [];
    final elements =
        state.ref
            .read(sketchElementsStreamProvider(state.widget.sketchId))
            .value ??
        [];
    SketchElement? selectedElement;
    try {
      selectedElement = elements.firstWhere((e) => e.id == selectedId);
    } catch (_) {
      // Element not found
    }

    if (selectedElement == null) {
      _selectElementAt(tappedPoint, state);
      return;
    }

    if (selectedElement is IconElement) {
      final dropdownHandlePosition = SketchPainter.getDropdownHandle(
        selectedElement,
        state.widget.actualSize,
        state.widget.targetSize,
      );
      final handleRect = Rect.fromCenter(
        center: dropdownHandlePosition,
        width: _dropdownHandleHitSize,
        height: _dropdownHandleHitSize,
      );

      if (handleRect.contains(details.localPosition)) {
        _showIconChangeMenu(
          state.context,
          details.globalPosition,
          selectedElement,
          state,
        );
        return; // Handled tap on dropdown
      }
    }

    _selectElementAt(tappedPoint, state);
  }

  bool _selectElementAt(Offset position, SketchCanvasState state) {
    final selectedElementIdNotifier = state.ref.read(
      selectedElementIdProvider.notifier,
    );
    //final elements = state.ref.read(sketchElementsStreamProvider).value ?? [];
    final elements =
        state.ref
            .read(sketchElementsStreamProvider(state.widget.sketchId))
            .value ??
        [];

    for (final element in elements.reversed) {
      final rect = SketchPainter.getBoundingBox(
        element,
        state.widget.actualSize, // Use actual size from widget
        state.widget.targetSize, // Use target size from widget
      );
      if (rect.contains(position)) {
        selectedElementIdNotifier.select(element.id);
        _selectedElement = element;
        return true;
      }
    }

    selectedElementIdNotifier.deselect();
    return false;
  }

  void _showIconChangeMenu(
    BuildContext context,
    Offset globalPosition,
    IconElement element,
    SketchCanvasState state,
  ) async {
    final newIconId = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: availableIcons.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Center(child: Icon(entry.value)),
        );
      }).toList(),
    );
    if (newIconId != null && newIconId != element.iconId) {
      // For a simple icon change, we can bypass the command history for instant feedback,
      // or create a new UpdateElementCommand. Let's use a command for consistency.
      final newElement = element.copyWith(iconId: newIconId);
      await state.addCommand(UpdateElementCommand(element, newElement));
    }
  }
}
