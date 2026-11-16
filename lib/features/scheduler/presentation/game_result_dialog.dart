import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/scheduler/data/scheduler_providers.dart';

/// De uitslag van een oefenwedstrijd zoals de trainer die invult.
class GameResultInput {
  const GameResultInput({
    required this.date,
    required this.durationMinutes,
    required this.scoreWhite,
    required this.scoreBlack,
  });

  final String date;
  final int durationMinutes;
  final int scoreWhite;
  final int scoreBlack;
}

/// Vraagt de score, de speeltijd en de datum van een wedstrijd. Geeft `null`
/// terug bij annuleren.
Future<GameResultInput?> showGameResultDialog(
  BuildContext context, {
  required String white,
  required String black,
  required GameResultInput initial,
  String title = 'Save result',
}) => showDialog<GameResultInput>(
  context: context,
  builder: (_) => _GameResultDialog(
    white: white,
    black: black,
    initial: initial,
    title: title,
  ),
);

class _GameResultDialog extends StatefulWidget {
  const _GameResultDialog({
    required this.white,
    required this.black,
    required this.initial,
    required this.title,
  });

  final String white;
  final String black;
  final GameResultInput initial;
  final String title;

  @override
  State<_GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<_GameResultDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _white = TextEditingController(
    text: '${widget.initial.scoreWhite}',
  );
  late final _black = TextEditingController(
    text: '${widget.initial.scoreBlack}',
  );
  late final _minutes = TextEditingController(
    text: '${widget.initial.durationMinutes}',
  );
  late String _date = widget.initial.date;

  @override
  void dispose() {
    _white.dispose();
    _black.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = isoDate(picked));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      GameResultInput(
        date: _date,
        durationMinutes: int.parse(_minutes.text),
        scoreWhite: int.parse(_white.text),
        scoreBlack: int.parse(_black.text),
      ),
    );
  }

  Widget _number(
    TextEditingController controller,
    String label, {
    int min = 0,
    Key? key,
  }) => TextFormField(
    key: key,
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      final number = int.tryParse(value ?? '');
      return number == null || number < min ? 'Enter a number' : null;
    },
  );

  @override
  Widget build(BuildContext context) {
    final metrics = Theme.of(context).appMetrics;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _number(
                      _white,
                      widget.white,
                      key: const ValueKey('score-white'),
                    ),
                  ),
                  SizedBox(width: metrics.spacingSm),
                  Expanded(
                    child: _number(
                      _black,
                      widget.black,
                      key: const ValueKey('score-black'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: metrics.spacingSm),
              _number(_minutes, 'Playing time (minutes)', min: 1),
              SizedBox(height: metrics.spacingSm),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text('Date: $_date'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
