import 'package:flutter/material.dart';

/// Content-specific widget for editing text content.
class TextContentEditor extends StatelessWidget {
  const TextContentEditor({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 4,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(labelText: 'Text to display'),
    );
  }
}
