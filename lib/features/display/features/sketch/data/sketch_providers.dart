import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/firebase_providers.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_background.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch.dart';
import 'package:hs_coaching_app/features/display/data/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/command.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

final sketchRepositoryProvider = Provider<SketchRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return SketchRepository(
    firestore: firestore,
    storage: storage,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/*
/// This provider will hold the ID of the currently active sketch.
/// It will be overridden in the widget tree when a sketch is selected.
class CurrentSketchIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectSketch(String? sketchId) => state = sketchId;
}

final currentSketchIdProvider =
    NotifierProvider<CurrentSketchIdNotifier, String?>(
      CurrentSketchIdNotifier.new,
    );
*/

final currentSketchIdDocProvider = StreamProvider<String?>((ref) {
  return ref.watch(sketchRepositoryProvider).watchCurrentSketchIdDoc().map((
    snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['currentId'] as String?;
  });
});

final sketchListStreamProvider = StreamProvider.family<List<Sketch>, String?>((
  ref,
  tag,
) {
  return ref.watch(sketchRepositoryProvider).watchAllActiveSketches(tag: tag);
});
final allSketchTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(sketchRepositoryProvider).watchAllSketchTags();
});

final sketchProvider = StreamProvider.family<Sketch, String>((ref, sketchId) {
  ref.watch(displayDeviceIdsProvider);
  return ref.watch(sketchRepositoryProvider).watchSketch(sketchId);
});

final sketchBackgroundsProvider = StreamProvider<List<SketchBackground>>((ref) {
  return ref.watch(sketchRepositoryProvider).watchSketchBackgrounds();
});

/*final sketchElementsStreamProvider = StreamProvider<List<SketchElement>>((ref) {
  // We watch these providers to ensure that if the club, display, or sketch
  // ID changes, this stream provider will be re-evaluated, fetching the
  // elements for the new context.
  ref.watch(displayDeviceIdsProvider);
  ref.watch(currentSketchIdProvider);
  final sketchId = ref.watch(currentSketchIdProvider);
  if (sketchId == null) {
    return Stream.value([]);
  }
  return ref.read(sketchRepositoryProvider).getSketchElements(sketchId);
});*/

final sketchElementsStreamProvider =
    StreamProvider.family<List<SketchElement>, String>((ref, sketchId) {
      ref.watch(displayDeviceIdsProvider);
      // ref.watch(currentSketchIdProvider); // <-- VERWIJDERD
      return ref.read(sketchRepositoryProvider).getSketchElements(sketchId);
    });

///
/// UI STATE PROVIDERS
///

enum DrawingTool { freehand, arrow, line, rectangle, circle, eraser, select }

class ActiveToolNotifier extends Notifier<DrawingTool> {
  @override
  DrawingTool build() => DrawingTool.freehand;

  void setTool(DrawingTool tool) {
    ref.read(selectedElementIdProvider.notifier).deselect();
    state = tool;
  }
}

final activeToolProvider = NotifierProvider<ActiveToolNotifier, DrawingTool>(
  ActiveToolNotifier.new,
);

class SelectedColorNotifier extends Notifier<Color> {
  @override
  Color build() => Colors.black;

  void setColor(Color color) => state = color;
}

final selectedColorProvider = NotifierProvider<SelectedColorNotifier, Color>(
  SelectedColorNotifier.new,
);

class StrokeWidthNotifier extends Notifier<int> {
  @override
  int build() => 2;

  void setStrokeWidth(int width) => state = width;
}

final strokeWidthProvider = NotifierProvider<StrokeWidthNotifier, int>(
  StrokeWidthNotifier.new,
);

class FillShapeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final fillShapeProvider = NotifierProvider<FillShapeNotifier, bool>(
  FillShapeNotifier.new,
);

class CommandHistoryState {
  const CommandHistoryState({this.canUndo = false, this.canRedo = false});
  final bool canUndo;
  final bool canRedo;
}

/*class CommandHistoryNotifier extends Notifier<CommandHistoryState> {
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  @override
  CommandHistoryState build() => const CommandHistoryState();

  Future<void> execute(Command command) async {
    // The repository is now read inside the command itself, which has access
    // to the overridden providers.
    await command.execute(ref.read(sketchRepositoryProvider));
    _undoStack.add(command);
    _redoStack.clear(); // A new action clears the redo history
    _updateState();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final command = _undoStack.removeLast();
    final repo = ref.read(sketchRepositoryProvider);
    await command.undo(repo);
    _redoStack.add(command);
    _updateState();
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final command = _redoStack.removeLast();
    final repo = ref.read(sketchRepositoryProvider);
    await command.execute(repo);
    _undoStack.add(command);
    _updateState();
  }

  void _updateState() {
    state = CommandHistoryState(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }
}*/

class CommandHistoryNotifier extends Notifier<CommandHistoryState> {
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  @override
  CommandHistoryState build() => const CommandHistoryState();

  Future<void> execute(Command command, String sketchId) async {
    await command.execute(ref.read(sketchRepositoryProvider), sketchId);
    _undoStack.add(command);
    _redoStack.clear();
    _updateState();
  }

  Future<void> undo(String sketchId) async {
    if (_undoStack.isEmpty) return;
    final command = _undoStack.removeLast();
    await command.undo(ref.read(sketchRepositoryProvider), sketchId);
    _redoStack.add(command);
    _updateState();
  }

  Future<void> redo(String sketchId) async {
    if (_redoStack.isEmpty) return;
    final command = _redoStack.removeLast();
    await command.execute(ref.read(sketchRepositoryProvider), sketchId);
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

final commandHistoryProvider =
    NotifierProvider<CommandHistoryNotifier, CommandHistoryState>(
      CommandHistoryNotifier.new,
    );

class SelectedElementIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? elementId) => state = elementId;

  void deselect() => state = null;
}

final selectedElementIdProvider =
    NotifierProvider<SelectedElementIdNotifier, String?>(
      SelectedElementIdNotifier.new,
    );

/// Manages the state of the currently selected tag for filtering.
class SelectedTagNotifier extends Notifier<String?> implements TagNotifier {
  @override
  String? build() => null;
  @override
  void setTag(String? newTag) => state = newTag;
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
);

/// Manages the state of the search query string for filtering sketches.
class SearchQueryNotifier extends Notifier<String> implements SearchNotifier {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  @override
  void setQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => state = query);
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
