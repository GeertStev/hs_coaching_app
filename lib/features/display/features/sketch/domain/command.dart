import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_data_providers.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';

/// The Command Interface that all command classes will implement.
abstract class Command {
  Future<void> execute(Ref ref, String sketchId);
  Future<void> undo(Ref ref, String sketchId);
}

class AddElementCommand implements Command {
  AddElementCommand(this._element);
  final SketchElement _element;

  @override
  Future<void> execute(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);

    // 1. Optimistic UI Update (direct zichtbaar voor de coach)
    notifier.addOrUpdateOptimistically(_element);

    // 2. Achtergrond synchronisatie naar Firebase
    try {
      await ref
          .read(sketchRepositoryProvider)
          .addOrUpdateElement(sketchId, _element);
    } catch (e) {
      // Rollback bij fout
      notifier.removeOptimistically(_element.id);
      rethrow;
    }
  }

  @override
  Future<void> undo(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);
    notifier.removeOptimistically(_element.id);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .removeElement(sketchId, _element.id);
    } catch (e) {
      notifier.addOrUpdateOptimistically(_element);
      rethrow;
    }
  }
}

class RemoveElementCommand implements Command {
  RemoveElementCommand(this._element);
  final SketchElement _element;

  @override
  Future<void> execute(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);
    notifier.removeOptimistically(_element.id);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .removeElement(sketchId, _element.id);
    } catch (e) {
      notifier.addOrUpdateOptimistically(_element);
      rethrow;
    }
  }

  @override
  Future<void> undo(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);
    notifier.addOrUpdateOptimistically(_element);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .addOrUpdateElement(sketchId, _element);
    } catch (e) {
      notifier.removeOptimistically(_element.id);
      rethrow;
    }
  }
}

class UpdateElementCommand implements Command {
  UpdateElementCommand(this.oldElement, this.newElement);
  final SketchElement oldElement;
  final SketchElement newElement;

  @override
  Future<void> execute(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);
    notifier.addOrUpdateOptimistically(newElement);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .addOrUpdateElement(sketchId, newElement);
    } catch (e) {
      notifier.addOrUpdateOptimistically(oldElement);
      rethrow;
    }
  }

  @override
  Future<void> undo(Ref ref, String sketchId) async {
    final notifier = ref.read(sketchElementsStreamProvider(sketchId).notifier);
    notifier.addOrUpdateOptimistically(oldElement);

    try {
      await ref
          .read(sketchRepositoryProvider)
          .addOrUpdateElement(sketchId, oldElement);
    } catch (e) {
      notifier.addOrUpdateOptimistically(newElement);
      rethrow;
    }
  }
}
