import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/tools/stateless_tool.dart';
import 'package:uuid/uuid.dart';
import 'package:hs_coaching_app/features/display/data/display_global_settings_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_ui_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_service_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/drawing_session_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/sketch_painter.dart';

class SketchCanvas extends ConsumerStatefulWidget {
  const SketchCanvas({
    super.key,
    required this.sketchId,
    required this.targetSize,
    required this.actualSize,
    this.backgroundUrl,
  });
  final String sketchId;
  final Size targetSize;
  final Size actualSize;
  final String? backgroundUrl;

  @override
  ConsumerState<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends ConsumerState<SketchCanvas> {
  final _canvasKey = GlobalKey();
  final _uuid = const Uuid();

  Future<void> _showIconMenu(IconMenuRequest req) async {
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final globalPos = renderBox.localToGlobal(req.localPosition);
    final newIconId = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        globalPos.dx,
        globalPos.dy,
      ),
      items: availableIcons.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Center(child: Icon(entry.value)),
        );
      }).toList(),
    );

    if (newIconId != null && newIconId != req.element.iconId) {
      final newElement = req.element.copyWith(iconId: newIconId);
      ref
          .read(commandHistoryProvider(widget.sketchId).notifier)
          .execute(UpdateElementCommand(req.element, newElement));
    }
  }

  @override
  Widget build(BuildContext context) {
    final elementsAsync = ref.watch(
      sketchElementsStreamProvider(widget.sketchId),
    );
    final selectedElementId = ref.watch(selectedElementIdProvider);
    final sessionState = ref.watch(drawingSessionProvider);
    final settings = ref.read(globalSettingsProvider).value;
    final sessionNotifier = ref.read(drawingSessionProvider.notifier);

    ref.listen(drawingSessionProvider, (prev, next) {
      if (next.iconMenuRequest != null) {
        _showIconMenu(next.iconMenuRequest!);
        sessionNotifier.clearIconMenuRequest();
      }
    });

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final renderBox =
            _canvasKey.currentContext?.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(
          details.offset.translate(24, 24),
        );

        // Inline transform mapping
        final scaleX = widget.targetSize.width / widget.actualSize.width;
        final scaleY = widget.targetSize.height / widget.actualSize.height;
        final transformedPosition = Offset(
          (localOffset.dx * scaleX).clamp(0.0, widget.targetSize.width),
          (localOffset.dy * scaleY).clamp(0.0, widget.targetSize.height),
        );

        final newIcon = IconElement(
          id: _uuid.v4(),
          iconId: details.data,
          position: transformedPosition,
          size: 48.0,
        );
        ref
            .read(commandHistoryProvider(widget.sketchId).notifier)
            .execute(AddElementCommand(newIcon));
      },
      builder: (context, candidateData, rejectedData) {
        final elements = elementsAsync.value ?? [];
        final currentElements = [
          sessionState.temporaryElement,
        ].whereType<SketchElement>().toList();

        return GestureDetector(
          key: _canvasKey,
          onPanStart: (details) => sessionNotifier.onPanStart(
            widget.sketchId,
            details.localPosition,
            widget.actualSize,
            widget.targetSize,
          ),
          onPanUpdate: (details) => sessionNotifier.onPanUpdate(
            widget.sketchId,
            details.localPosition,
            widget.actualSize,
            widget.targetSize,
          ),
          onPanEnd: (details) => sessionNotifier.onPanEnd(
            widget.sketchId,
            widget.actualSize,
            widget.targetSize,
          ),
          onTapUp: (details) => sessionNotifier.onTapUp(
            widget.sketchId,
            details.localPosition,
            widget.actualSize,
            widget.targetSize,
          ),
          child: Container(
            color: settings?.backgroundColor ?? Colors.white,
            child: Stack(
              children: [
                // 1. De SVG Achtergrond (Geregeld door flutter_svg's netwerk widget)
                if (widget.backgroundUrl != null &&
                    widget.backgroundUrl!.trim().isNotEmpty)
                  Positioned.fill(
                    child: SvgPicture.network(
                      widget.backgroundUrl!,
                      fit: BoxFit
                          .fill, // Zorgt dat de SVG precies de canvas dimensies vult
                      placeholderBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      // Voorkom caching-issues bij snelle opeenvolgende wisselingen
                      key: ValueKey(widget.backgroundUrl),
                    ),
                  ),

                // 2. Het Transparante Teken-canvas erbovenop
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .transparent, // Belangrijk: Transparant zodat de SVG erdoorheen schijnt!
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CustomPaint(
                      painter: SketchPainter(
                        elements: elements,
                        currentElements: currentElements,
                        selectedElementId: selectedElementId,
                        actualSize: widget.actualSize,
                        targetSize: widget.targetSize,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
