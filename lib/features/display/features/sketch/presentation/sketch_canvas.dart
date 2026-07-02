import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/data/display_global_settings_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/arrow_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/circle_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/eraser_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/freehand_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/line_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/rectangle_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/select_tool.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/tool.dart';
import 'package:uuid/uuid.dart';

class SketchCanvas extends ConsumerStatefulWidget {
  const SketchCanvas({
    super.key,
    required this.targetSize,
    required this.actualSize,
    this.backgroundUrl,
  });
  final Size targetSize;
  final Size actualSize;
  final String? backgroundUrl;

  @override
  ConsumerState<SketchCanvas> createState() => _SketchCanvasState();
}

// The public interface for the Tool classes to interact with the canvas state.
// This prevents tools from having to depend on the full `_SketchCanvasState`.
abstract class SketchCanvasState {
  WidgetRef get ref;
  SketchCanvas get widget;
  BuildContext get context;
  Uuid get uuid;

  Offset transformAndClampOffset(Offset localOffset);
  void setTemporaryElement(SketchElement? element);
  void clearTemporaryElement();
  Future<void> addCommand(Command command);
}

class _SketchCanvasState extends ConsumerState<SketchCanvas>
    implements SketchCanvasState {
  final _canvasKey = GlobalKey();
  @override
  final uuid = const Uuid();

  // State for the background image
  ImageProvider? _backgroundImageProvider;
  ui.Image? _backgroundImage;

  // By creating instances of the tools here, we ensure that their internal
  // state (like the element being drawn) is preserved across pan events.
  late final Map<DrawingTool, Tool> _tools;

  @override
  void initState() {
    super.initState();
    _tools = {
      DrawingTool.freehand: FreehandTool(),
      DrawingTool.arrow: ArrowTool(),
      DrawingTool.line: LineTool(),
      DrawingTool.rectangle: RectangleTool(),
      DrawingTool.circle: CircleTool(),
      DrawingTool.eraser: EraserTool(),
      DrawingTool.select: SelectTool(),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBackgroundImage();
  }

  @override
  void didUpdateWidget(covariant SketchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backgroundUrl != oldWidget.backgroundUrl) {
      _updateBackgroundImage();
    }
  }

  void _updateBackgroundImage() {
    if (widget.backgroundUrl == null) {
      if (_backgroundImage != null) {
        setState(() => _backgroundImage = null);
      }
      return;
    }

    _backgroundImageProvider = NetworkImage(widget.backgroundUrl!);
    final imageStream = _backgroundImageProvider!.resolve(
      createLocalImageConfiguration(context),
    );
    imageStream.addListener(
      ImageStreamListener((imageInfo, _) {
        if (mounted) setState(() => _backgroundImage = imageInfo.image);
      }),
    );
  }

  SketchElement? _temporaryElement;

  /// Transforms a local offset on the widget to the target screen's coordinate system and clamps it.
  @override
  Offset transformAndClampOffset(Offset localOffset) {
    if (widget.actualSize.isEmpty || widget.targetSize.isEmpty) {
      return localOffset;
    }

    final scaleX = widget.targetSize.width / widget.actualSize.width;
    final scaleY = widget.targetSize.height / widget.actualSize.height;

    final transformedDx = localOffset.dx * scaleX;
    final transformedDy = localOffset.dy * scaleY;

    // Clamp to ensure it's within the target screen bounds
    final clampedDx = transformedDx.clamp(0.0, widget.targetSize.width);
    final clampedDy = transformedDy.clamp(0.0, widget.targetSize.height);

    return Offset(clampedDx, clampedDy);
  }

  @override
  void setTemporaryElement(SketchElement? element) {
    setState(() => _temporaryElement = element);
  }

  @override
  void clearTemporaryElement() {
    setState(() => _temporaryElement = null);
  }

  @override
  Future<void> addCommand(Command command) async {
    await ref.read(commandHistoryProvider.notifier).execute(command);
  }

  Tool get _activeTool {
    final tool = ref.watch(activeToolProvider);
    // Return the cached tool instance.
    return _tools[tool]!;
  }

  @override
  Widget build(BuildContext context) {
    final elementsAsync = ref.watch(sketchElementsStreamProvider);
    final selectedElementId = ref.watch(selectedElementIdProvider);
    final settings = ref.read(globalSettingsProvider).value;

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        // The `details.offset` is a global position. We need to convert it to
        // the local coordinate system of the canvas.
        final RenderBox renderBox =
            _canvasKey.currentContext?.findRenderObject() as RenderBox;
        final transformedPosition = transformAndClampOffset(
          //Translate because of sizebox around icon
          renderBox.globalToLocal(details.offset.translate(24, 24)),
        );

        const iconSize = 48.0;
        final newIcon = IconElement(
          id: uuid.v4(),
          iconId: details.data,
          position: transformedPosition, // Already transformed
          size: iconSize,
        );
        addCommand(AddElementCommand(newIcon));
      },
      builder: (context, candidateData, rejectedData) {
        final elements = elementsAsync.value ?? [];
        final currentElements = [
          _temporaryElement,
        ].whereType<SketchElement>().toList();

        return GestureDetector(
          key: _canvasKey,
          onPanStart: (details) => _activeTool.onPanStart(details, this),
          onPanUpdate: (details) => _activeTool.onPanUpdate(details, this),
          onPanEnd: (details) => _activeTool.onPanEnd(details, this),
          onTapUp: (details) => _activeTool.onTapUp(details, this),
          child: Container(
            color: settings?.backgroundColor ?? Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white30,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomPaint(
                painter: SketchPainter(
                  elements: elements,
                  currentElements: currentElements,
                  selectedElementId: selectedElementId,
                  actualSize: widget.actualSize,
                  targetSize: widget.targetSize,
                  backgroundImage: _backgroundImage,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}
