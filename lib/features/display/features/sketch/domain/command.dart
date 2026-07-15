import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

/// The Command Interface that all command classes will implement.
abstract class Command {
  Future<void> execute(SketchRepository repo, String sketchId);
  Future<void> undo(SketchRepository repo, String sketchId);
}

class AddElementCommand implements Command {
  AddElementCommand(this._element);
  final SketchElement _element;

  @override
  Future<void> execute(SketchRepository repo, String sketchId) async =>
      await repo.addOrUpdateElement(sketchId, _element);

  @override
  Future<void> undo(SketchRepository repo, String sketchId) async =>
      await repo.removeElement(sketchId, _element.id);
}

class RemoveElementCommand implements Command {
  RemoveElementCommand(this._element);
  final SketchElement _element;

  @override
  Future<void> execute(SketchRepository repo, String sketchId) async =>
      await repo.removeElement(sketchId, _element.id);

  @override
  Future<void> undo(SketchRepository repo, String sketchId) async =>
      await repo.addOrUpdateElement(sketchId, _element);
}

class UpdateElementCommand implements Command {
  UpdateElementCommand(this.oldElement, this.newElement);
  final SketchElement oldElement;
  final SketchElement newElement;

  @override
  Future<void> execute(SketchRepository repo, String sketchId) async =>
      await repo.addOrUpdateElement(sketchId, newElement);

  @override
  Future<void> undo(SketchRepository repo, String sketchId) async =>
      await repo.addOrUpdateElement(sketchId, oldElement);
}
