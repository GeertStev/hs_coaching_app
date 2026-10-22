import 'dart:math' as math;
import 'dart:ui';

import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_core/sketch/sketch_geometry.dart';

/// Pure bewerkingen op sketch-elementen voor de select-tool: stijl wijzigen, verschuiven,
/// handles verslepen en roteren. Alles in doelscherm-coördinaten.

/// Doorzichtigheid van de vulling, gelijk aan wat de tekentools gebruiken.
const int fillAlpha = 125;

/// Of het element een vulling kan hebben (gesloten vormen).
bool isFillable(SketchElement element) =>
    element is RectangleElement ||
    element is PolygonElement ||
    element is CircleElement;

/// Past kleur, dikte en/of vulling toe op een element. Iconen hebben geen stijl en blijven
/// ongewijzigd; vulling wordt genegeerd voor open vormen. Een gevuld element krijgt bij een
/// nieuwe kleur ook een nieuwe vulkleur.
SketchElement applyStyle(
  SketchElement element, {
  Color? color,
  int? strokeWidth,
  bool? filled,
}) {
  Color? fillFor(Color baseColor, Color? currentFill) {
    final isFilled = filled ?? currentFill != null;
    return isFilled ? baseColor.withAlpha(fillAlpha) : null;
  }

  return switch (element) {
    PathElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
    ),
    ArrowElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
    ),
    LineElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
    ),
    RectangleElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
      fillColor: fillFor(color ?? element.color, element.fillColor),
    ),
    PolygonElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
      fillColor: fillFor(color ?? element.color, element.fillColor),
    ),
    CircleElement() => element.copyWith(
      color: color ?? element.color,
      strokeWidth: strokeWidth ?? element.strokeWidth,
      fillColor: fillFor(color ?? element.color, element.fillColor),
    ),
    IconElement() => element,
  };
}

/// Verschuift het hele element over [delta].
SketchElement translateElement(SketchElement element, Offset delta) {
  return element.map(
    path: (e) => e.copyWith(
      points: e.points
          .map((p) => p.copyWith(offset: p.offset + delta))
          .toList(),
    ),
    arrow: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
    line: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
    rectangle: (e) => e.copyWith(start: e.start + delta, end: e.end + delta),
    polygon: (e) => e.copyWith(
      points: e.points
          .map((p) => p.copyWith(offset: p.offset + delta))
          .toList(),
    ),
    circle: (e) => e.copyWith(center: e.center + delta),
    icon: (e) => e.copyWith(position: e.position + delta),
  );
}

/// De versleepbare punten van een element:
/// - lijn/pijl: begin- en eindpunt
/// - rechthoek: de vier hoekpunten (zie [rectangleCorners])
/// - veelhoek: alle hoekpunten
/// - cirkel: vier punten op de rand (rechts, onder, links, boven)
/// Vrije lijnen en iconen hebben geen handles.
List<Offset> editHandles(SketchElement element) {
  return switch (element) {
    LineElement(:final start, :final end) => [start, end],
    ArrowElement(:final start, :final end) => [start, end],
    RectangleElement() => rectangleCorners(element),
    PolygonElement(:final points) => [for (final p in points) p.offset],
    CircleElement(:final center, :final radius) => [
      center + Offset(radius, 0),
      center + Offset(0, radius),
      center + Offset(-radius, 0),
      center + Offset(0, -radius),
    ],
    PathElement() || IconElement() => const [],
  };
}

/// Verplaatst handle [index] (zoals in [editHandles]) naar [target].
SketchElement moveHandle(SketchElement element, int index, Offset target) {
  switch (element) {
    case LineElement():
      return index == 0
          ? element.copyWith(start: target)
          : element.copyWith(end: target);
    case ArrowElement():
      return index == 0
          ? element.copyWith(start: target)
          : element.copyWith(end: target);
    case RectangleElement():
      return _moveRectangleCorner(element, index, target);
    case PolygonElement(:final points):
      if (index < 0 || index >= points.length) return element;
      final updated = List<Point>.from(points);
      updated[index] = updated[index].copyWith(offset: target);
      return element.copyWith(points: updated);
    case CircleElement(:final center):
      // Het middelpunt blijft staan; de rand volgt de vinger.
      return element.copyWith(radius: (target - center).distance);
    case PathElement() || IconElement():
      return element;
  }
}

/// Sleept één hoek van een (gedraaide) rechthoek; de tegenoverliggende hoek blijft op zijn
/// plaats en de vorm blijft een rechthoek met dezelfde rotatie.
RectangleElement _moveRectangleCorner(
  RectangleElement rect,
  int index,
  Offset target,
) {
  if (index < 0 || index > 3) return rect;
  final opposite = rectangleCorners(rect)[(index + 2) % 4];
  final center = (target + opposite) / 2;
  // Terug naar het niet-gedraaide assenstelsel rond het nieuwe middelpunt.
  final p = rotateAround(target, center, -rect.rotation);
  final o = rotateAround(opposite, center, -rect.rotation);
  // Hoekvolgorde: 0 = start, 1 = (end.x, start.y), 2 = end, 3 = (start.x, end.y).
  final (start, end) = switch (index) {
    0 => (p, o),
    1 => (Offset(o.dx, p.dy), Offset(p.dx, o.dy)),
    2 => (o, p),
    _ => (Offset(p.dx, o.dy), Offset(o.dx, p.dy)),
  };
  return rect.copyWith(start: start, end: end);
}

/// Hoek (radialen) waarop een rotatie vastklikt als ze er dichtbij komt.
const double rotationSnapStep = math.pi / 4;
const double rotationSnapTolerance = 4 * math.pi / 180;

/// Draait [original] zodat de richting middelpunt→[from] naar middelpunt→[to] gaat.
/// Klikt vast op veelvouden van 45° binnen [rotationSnapTolerance].
RectangleElement rotateRectangle(
  RectangleElement original,
  Offset from,
  Offset to,
) {
  final center = rectangleCenter(original);
  final delta = (to - center).direction - (from - center).direction;
  var rotation = _normalizeAngle(original.rotation + delta);
  final snapped =
      (rotation / rotationSnapStep).roundToDouble() * rotationSnapStep;
  if ((rotation - snapped).abs() <= rotationSnapTolerance) {
    rotation = _normalizeAngle(snapped);
  }
  return original.copyWith(rotation: rotation);
}

/// Brengt een hoek naar het bereik (-pi, pi].
double _normalizeAngle(double angle) {
  var a = angle % (2 * math.pi);
  if (a > math.pi) a -= 2 * math.pi;
  return a;
}
