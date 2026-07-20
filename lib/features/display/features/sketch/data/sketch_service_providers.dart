import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';

class CommandHistoryState {
  const CommandHistoryState({this.canUndo = false, this.canRedo = false});
  final bool canUndo;
  final bool canRedo;
}

/// Beheert de lokale undo- en redo-stacks van commando's voor een specifieke sketch.
class CommandHistoryNotifier extends Notifier<CommandHistoryState> {
  final String sketchId;

  // Riverpod 3.0 constructor parameter mapping
  CommandHistoryNotifier(this.sketchId);

  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  @override
  CommandHistoryState build() => const CommandHistoryState();

  Future<void> execute(Command command) async {
    await command.execute(ref, sketchId);
    _undoStack.add(command);
    _redoStack.clear();
    _updateState();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final command = _undoStack.removeLast();
    await command.undo(ref, sketchId);
    _redoStack.add(command);
    _updateState();
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final command = _redoStack.removeLast();
    await command.execute(ref, sketchId);
    _undoStack.add(command);
    _updateState();
  }

  void _updateState() {
    state = CommandHistoryState(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }
}

// Wijzig de provider naar .family
final commandHistoryProvider =
    NotifierProvider.family<
      CommandHistoryNotifier,
      CommandHistoryState,
      String
    >(CommandHistoryNotifier.new);
