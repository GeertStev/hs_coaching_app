import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

/// The Command Interface that all command classes will implement.
abstract class Command {
  /// Executes the command's action.
  Future<void> execute(SketchRepository repo);

  /// Reverts the command's action.
  Future<void> undo(SketchRepository repo);
}

/// A command for adding a new element to the canvas.
class AddElementCommand implements Command {
  AddElementCommand(this._element);

  final SketchElement _element;

  @override
  Future<void> execute(SketchRepository repo) async {
    await repo.addOrUpdateElement(_element);
  }

  @override
  Future<void> undo(SketchRepository repo) async {
    await repo.removeElement(_element.id);
  }
}

/// A command for removing an element from the canvas.
class RemoveElementCommand implements Command {
  RemoveElementCommand(this._element);

  final SketchElement _element;

  @override
  Future<void> execute(SketchRepository repo) async {
    await repo.removeElement(_element.id);
  }

  @override
  Future<void> undo(SketchRepository repo) async {
    await repo.addOrUpdateElement(_element);
  }
}

/// A command for updating an existing element (e.g., moving, rotating).
class UpdateElementCommand implements Command {
  UpdateElementCommand(this.oldElement, this.newElement);

  final SketchElement oldElement;
  final SketchElement newElement;

  @override
  Future<void> execute(SketchRepository repo) async {
    await repo.addOrUpdateElement(newElement);
  }

  @override
  Future<void> undo(SketchRepository repo) async {
    await repo.addOrUpdateElement(oldElement);
  }
}
