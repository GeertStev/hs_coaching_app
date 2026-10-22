import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/element_editing.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_core/sketch/sketch_geometry.dart';

void expectOffset(Offset actual, Offset expected) {
  expect(actual.dx, closeTo(expected.dx, 1e-9));
  expect(actual.dy, closeTo(expected.dy, 1e-9));
}

RectangleElement rect({double rotation = 0, Color? fillColor}) =>
    RectangleElement(
      id: 'r',
      color: Colors.white,
      strokeWidth: 2,
      start: const Offset(0, 0),
      end: const Offset(20, 10),
      rotation: rotation,
      fillColor: fillColor,
    );

const line = LineElement(
  id: 'l',
  color: Colors.white,
  strokeWidth: 2,
  start: Offset(0, 0),
  end: Offset(10, 0),
);

final polygon = PolygonElement(
  id: 'p',
  color: Colors.white,
  strokeWidth: 2,
  points: const [
    Point(offset: Offset(0, 0), pressure: 1),
    Point(offset: Offset(10, 0), pressure: 1),
    Point(offset: Offset(5, 8), pressure: 1),
  ],
);

const circle = CircleElement(
  id: 'c',
  color: Colors.white,
  strokeWidth: 2,
  center: Offset(50, 50),
  radius: 10,
);

void main() {
  group('applyStyle', () {
    test('kleur en dikte op een lijn', () {
      final updated =
          applyStyle(line, color: Colors.red, strokeWidth: 4) as LineElement;
      expect(updated.color, Colors.red);
      expect(updated.strokeWidth, 4);
    });

    test('vulling aanzetten gebruikt de lijnkleur', () {
      final updated = applyStyle(rect(), filled: true) as RectangleElement;
      expect(updated.fillColor, Colors.white.withAlpha(fillAlpha));
    });

    test('vulling uitzetten', () {
      final updated =
          applyStyle(rect(fillColor: Colors.white), filled: false)
              as RectangleElement;
      expect(updated.fillColor, isNull);
    });

    test('nieuwe kleur op een gevulde vorm kleurt ook de vulling', () {
      final updated =
          applyStyle(rect(fillColor: Colors.white), color: Colors.red)
              as RectangleElement;
      expect(updated.color, Colors.red);
      expect(updated.fillColor, Colors.red.withAlpha(fillAlpha));
    });

    test('nieuwe kleur op een ongevulde vorm laat ze ongevuld', () {
      final updated = applyStyle(rect(), color: Colors.red) as RectangleElement;
      expect(updated.fillColor, isNull);
    });

    test('icoon blijft ongewijzigd', () {
      const icon = IconElement(
        id: 'i',
        position: Offset.zero,
        iconId: 'person',
        size: 48,
      );
      expect(applyStyle(icon, color: Colors.red, filled: true), icon);
    });
  });

  group('lijn', () {
    test('handles zijn begin- en eindpunt', () {
      expect(editHandles(line), const [Offset(0, 0), Offset(10, 0)]);
    });

    test('eindpunt verslepen laat het beginpunt staan', () {
      final updated = moveHandle(line, 1, const Offset(30, 40)) as LineElement;
      expect(updated.start, const Offset(0, 0));
      expect(updated.end, const Offset(30, 40));
    });
  });

  group('rechthoek', () {
    for (var corner = 0; corner < 4; corner++) {
      for (final rotation in [0.0, 0.7, -2.0]) {
        test('hoek $corner verslepen bij rotatie $rotation', () {
          final original = rect(rotation: rotation);
          final opposite = rectangleCorners(original)[(corner + 2) % 4];
          const target = Offset(37, 23);

          final updated =
              moveHandle(original, corner, target) as RectangleElement;
          final corners = rectangleCorners(updated);

          // De versleepte hoek volgt de vinger, de overkant blijft staan,
          // de rotatie blijft en de vorm blijft een rechthoek.
          expectOffset(corners[corner], target);
          expectOffset(corners[(corner + 2) % 4], opposite);
          expect(updated.rotation, rotation);
          final a = corners[1] - corners[0];
          final b = corners[2] - corners[1];
          expect(a.dx * b.dx + a.dy * b.dy, closeTo(0, 1e-9));
        });
      }
    }

    test('verschuiven behoudt de rotatie', () {
      final moved =
          translateElement(rect(rotation: 0.5), const Offset(5, 5))
              as RectangleElement;
      expect(moved.rotation, 0.5);
      expect(moved.start, const Offset(5, 5));
    });

    test('roteren rond het middelpunt', () {
      // Middelpunt (10, 5): van rechts naar onder is een kwartslag
      final rotated = rotateRectangle(
        rect(),
        const Offset(30, 5),
        const Offset(10, 25),
      );
      expect(rotated.rotation, closeTo(math.pi / 2, 1e-9));
      expect(rotated.start, rect().start);
    });

    test('roteren klikt vast vlak bij 45°', () {
      final angle = math.pi / 4 + 2 * math.pi / 180;
      final rotated = rotateRectangle(
        rect(),
        const Offset(30, 5),
        const Offset(10, 5) + Offset.fromDirection(angle, 20),
      );
      expect(rotated.rotation, closeTo(math.pi / 4, 1e-9));
    });

    test('roteren klikt niet vast verder van 45°', () {
      final angle = math.pi / 4 + 10 * math.pi / 180;
      final rotated = rotateRectangle(
        rect(),
        const Offset(30, 5),
        const Offset(10, 5) + Offset.fromDirection(angle, 20),
      );
      expect(rotated.rotation, closeTo(angle, 1e-9));
    });
  });

  group('veelhoek', () {
    test('handles zijn de hoekpunten', () {
      expect(editHandles(polygon), const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(5, 8),
      ]);
    });

    test('hoekpunt verslepen wijzigt enkel dat punt', () {
      final updated =
          moveHandle(polygon, 2, const Offset(5, 20)) as PolygonElement;
      expect(updated.points.map((p) => p.offset), const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(5, 20),
      ]);
    });
  });

  group('cirkel', () {
    test('vier handles op de rand', () {
      expect(editHandles(circle), const [
        Offset(60, 50),
        Offset(50, 60),
        Offset(40, 50),
        Offset(50, 40),
      ]);
    });

    test('rand verslepen wijzigt de straal, middelpunt blijft', () {
      final updated =
          moveHandle(circle, 0, const Offset(50, 80)) as CircleElement;
      expect(updated.center, const Offset(50, 50));
      expect(updated.radius, 30);
    });
  });
}
