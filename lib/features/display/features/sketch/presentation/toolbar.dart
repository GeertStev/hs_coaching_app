import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_service_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_ui_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/display_sketch_controller.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/widgets/color_select_circle.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/drawing_session_provider.dart';

class Toolbar extends ConsumerWidget {
  const Toolbar({super.key, required this.sketchId});
  final String sketchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeToolProvider);
    final strokeWidth = ref.watch(strokeWidthProvider);
    final selectedColor = ref.watch(selectedColorProvider);
    final isFilled = ref.watch(fillShapeProvider);
    final commandHistoryState = ref.watch(commandHistoryProvider(sketchId));
    final commandHistoryNotifier = ref.read(
      commandHistoryProvider(sketchId).notifier,
    );

    // Watch de actieve sketch en de beschikbare SVG-achtergronden
    final currentSketch = ref.watch(sketchProvider(sketchId)).value;
    final backgroundsAsync = ref.watch(sketchBackgroundsProvider);

    void changeTool(DrawingTool tool) {
      ref
          .read(drawingSessionProvider.notifier)
          .finishCurrentToolSession(sketchId);
      ref.read(activeToolProvider.notifier).setTool(tool);
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Draggable Icons
        Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final icon in availableIcons.entries)
                Draggable<String>(
                  data: icon.key,
                  feedback: Icon(icon.value, size: 48),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(icon.value, size: 32),
                  ),
                ),
            ],
          ),
        ),

        // Drawing items
        Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolButton(
                icon: Icons.edit,
                label: 'Freehand',
                isSelected: activeTool == DrawingTool.freehand,
                onPressed: () => changeTool(DrawingTool.freehand),
              ),
              _ToolButton(
                icon: Icons.horizontal_rule,
                label: 'Line',
                isSelected: activeTool == DrawingTool.line,
                onPressed: () => changeTool(DrawingTool.line),
              ),
              _ToolButton(
                icon: Icons.arrow_forward,
                label: 'Arrow',
                isSelected: activeTool == DrawingTool.arrow,
                onPressed: () => changeTool(DrawingTool.arrow),
              ),
              _ToolButton(
                icon: Icons.crop_square,
                label: 'Rectangle',
                isSelected: activeTool == DrawingTool.rectangle,
                onPressed: () => changeTool(DrawingTool.rectangle),
              ),
              _ToolButton(
                icon: Icons.pentagon_outlined,
                label: 'Veelhoek',
                isSelected: activeTool == DrawingTool.polygon,
                onPressed: () => changeTool(DrawingTool.polygon),
              ),
              _ToolButton(
                icon: Icons.circle_outlined,
                label: 'Circle',
                isSelected: activeTool == DrawingTool.circle,
                onPressed: () => changeTool(DrawingTool.circle),
              ),
            ],
          ),
        ),

        // Properties
        Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color selection
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: DropdownButton<Color>(
                    value: selectedColor,
                    icon: const SizedBox.shrink(),
                    underline: const SizedBox.shrink(),
                    selectedItemBuilder: (context) {
                      // ToDo list colors, maybe editable list?
                      return [
                            Colors.white,
                            Colors.black,
                            Colors.amber,
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                          ]
                          .map((c) => ColorSelectCircle(color: selectedColor))
                          .toList();
                    },
                    items:
                        [
                              Colors.white,
                              Colors.black,
                              Colors.amber,
                              Colors.red,
                              Colors.green,
                              Colors.blue,
                            ]
                            .map(
                              (itemColor) => DropdownMenuItem(
                                value: itemColor,
                                child: ColorSelectCircle(color: itemColor),
                              ),
                            )
                            .toList(),
                    onChanged: (color) {
                      if (color != null) {
                        ref
                            .read(selectedColorProvider.notifier)
                            .setColor(color);
                      }
                    },
                  ),
                ),
              ),

              // Fill toggle
              IconButton(
                icon: Icon(
                  Icons.format_color_fill,
                  color: isFilled ? selectedColor : null,
                ),
                tooltip: 'Fill Shape',
                onPressed: () => ref.read(fillShapeProvider.notifier).toggle(),
              ),

              // Stroke width
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: DropdownButton<int>(
                    value: strokeWidth.round(),
                    icon: const Icon(Icons.line_weight),
                    menuWidth: 48,
                    underline: const SizedBox.shrink(),
                    items: [1, 2, 4]
                        .map(
                          (width) => DropdownMenuItem(
                            value: width,
                            child: Text(width.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(strokeWidthProvider.notifier)
                            .setStrokeWidth(value);
                      }
                    },
                  ),
                ),
              ),

              // Background image
              backgroundsAsync.when(
                data: (backgrounds) {
                  final currentUrl = currentSketch?.backgroundUrl ?? '';
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.layers_outlined),
                    tooltip: 'Background',
                    initialValue: currentUrl,
                    onSelected: (url) {
                      ref
                          .read(sketchControllerProvider.notifier)
                          .updateBackground(sketchId, url == '' ? null : url);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: '',
                        child: Text('No background'),
                      ),
                      ...backgrounds.map(
                        (bg) => PopupMenuItem<String>(
                          value: bg.url,
                          child: Text(bg.title),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ),

        // Actions
        Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolButton(
                icon: Icons.touch_app,
                label: 'Select',
                isSelected: activeTool == DrawingTool.select,
                onPressed: () => changeTool(DrawingTool.select),
              ),
              _ToolButton(
                icon: Icons.delete_outline,
                label: 'Eraser',
                isSelected: activeTool == DrawingTool.eraser,
                onPressed: () => changeTool(DrawingTool.eraser),
              ),

              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: commandHistoryState.canUndo
                    ? () => commandHistoryNotifier.undo()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
                onPressed: commandHistoryState.canRedo
                    ? () => commandHistoryNotifier.redo()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Clear All',
                onPressed: () =>
                    ref.read(sketchRepositoryProvider).clearSketch(sketchId),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: label,
      style: isSelected
          ? IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              /*disabledBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.5),*/
            )
          : null,
    );
  }
}
