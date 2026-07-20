import 'package:flutter/material.dart';

class ColorSelectCircle extends StatelessWidget {
  const ColorSelectCircle({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, // Matcht de standaard grootte van een Icon
      height: 24,
      decoration: BoxDecoration(
        color: color, // De geselecteerde kleur als vulling
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400, // Kleur van de subtiele rand
          width: 1.5, // Dikte van de rand
        ),
      ),
    );
  }
}
