import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_coaching_app/features/display/features/timer/domain/timer_set.dart';

/// A widget for editing the content of a TimerSet, including its
/// description, rest time, and list of exercises.
class TimerSetContentEditor extends StatefulWidget {
  const TimerSetContentEditor({
    super.key,
    this.initialSet,
    required this.onChanged,
  });

  final TimerSet? initialSet;
  final void Function(int restBetween, List<ExerciseInSet> exercises) onChanged;

  @override
  State<TimerSetContentEditor> createState() => _TimerSetContentEditorState();
}

class _TimerSetContentEditorState extends State<TimerSetContentEditor> {
  late final TextEditingController _restBetweenController;
  late List<ExerciseInSet> _exercises;

  // Controllers for each exercise field
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _roundsControllers = [];
  final List<TextEditingController> _workControllers = [];
  final List<TextEditingController> _restControllers = [];

  @override
  void initState() {
    super.initState();
    _restBetweenController = TextEditingController(
      text: widget.initialSet?.restBetweenExercisesSeconds.toString() ?? '30',
    );
    _exercises = List.from(widget.initialSet?.exercises ?? []);

    for (final exercise in _exercises) {
      _addControllersForExercise(exercise, listen: false);
    }

    _restBetweenController.addListener(_onChanged);
    for (int i = 0; i < _exercises.length; i++) {
      _addListenersForExerciseIndex(i);
    }
  }

  @override
  void dispose() {
    _restBetweenController.removeListener(_onChanged);
    _restBetweenController.dispose();
    for (final controller in [
      ..._nameControllers,
      ..._roundsControllers,
      ..._workControllers,
      ..._restControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    widget.onChanged(
      int.tryParse(_restBetweenController.text) ?? 0,
      List.from(_exercises), // Pass a copy
    );
  }

  void _onExerciseChanged(int index) {
    final updatedExercise = _exercises[index].copyWith(
      name: _nameControllers[index].text,
      rounds: int.tryParse(_roundsControllers[index].text) ?? 0,
      workSeconds: int.tryParse(_workControllers[index].text) ?? 0,
      restSeconds: int.tryParse(_restControllers[index].text) ?? 0,
    );
    _exercises[index] = updatedExercise;
    _onChanged();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(
        const ExerciseInSet(
          name: 'New Exercise',
          rounds: 8,
          workSeconds: 20,
          restSeconds: 10,
        ),
      );
      _addControllersForExercise(_exercises.last);
      _onChanged();
    });
  }

  void _addControllersForExercise(
    ExerciseInSet exercise, {
    bool listen = true,
  }) {
    _nameControllers.add(TextEditingController(text: exercise.name));
    _roundsControllers.add(
      TextEditingController(text: exercise.rounds.toString()),
    );
    _workControllers.add(
      TextEditingController(text: exercise.workSeconds.toString()),
    );
    _restControllers.add(
      TextEditingController(text: exercise.restSeconds.toString()),
    );
    if (listen) {
      _addListenersForExerciseIndex(_exercises.length - 1);
    }
  }

  void _addListenersForExerciseIndex(int index) {
    _nameControllers[index].addListener(() => _onExerciseChanged(index));
    _roundsControllers[index].addListener(() => _onExerciseChanged(index));
    _workControllers[index].addListener(() => _onExerciseChanged(index));
    _restControllers[index].addListener(() => _onExerciseChanged(index));
  }

  void _removeExercise(int index) {
    setState(() {
      // Dispose and remove controllers
      _nameControllers.removeAt(index).dispose();
      _roundsControllers.removeAt(index).dispose();
      _workControllers.removeAt(index).dispose();
      _restControllers.removeAt(index).dispose();

      // Remove exercise from list
      _exercises.removeAt(index);

      // Re-trigger the parent widget's onChanged
      _onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _restBetweenController,
          decoration: const InputDecoration(
            labelText: 'Rest Between Exercises (seconds)',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v!.trim().isEmpty ? 'A value is required' : null,
        ),
        const SizedBox(height: 24),
        Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        if (_exercises.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No exercises added yet.')),
          ),
        SizedBox(
          width: 200,
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                key: ValueKey(_exercises[index].hashCode + index),
                title: Text(
                  _nameControllers[index].text.isEmpty
                      ? 'Exercise ${index + 1}'
                      : _nameControllers[index].text,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeExercise(index),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Exercise Name',
                          ),
                          validator: (v) =>
                              v!.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _roundsControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Rounds',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _workControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Work (s)',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _restControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Rest (s)',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ),
      ],
    );
  }
}
