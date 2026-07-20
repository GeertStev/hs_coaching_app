import 'dart:math' as math;
import 'package:flutter/material.dart';
//import 'dart:ui' as ui;
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_element.dart';

class SketchPainter extends CustomPainter {
  const SketchPainter({
    required this.elements,
    this.currentElements = const [],
    this.selectedElementId,
    required this.actualSize,
    required this.targetSize,
    //this.backgroundImage,
  });

  final List<SketchElement> elements;
  final List<SketchElement> currentElements;
  final String? selectedElementId;
  final Size actualSize;
  final Size targetSize;
  //final ui.Image? backgroundImage;

  /// Scales an offset from the target coordinate system to the local canvas system.
  Offset _scaleToLocal(Offset targetOffset) {
    if (targetSize.isEmpty || actualSize.isEmpty) return targetOffset;
    final scaleX = actualSize.width / targetSize.width;
    final scaleY = actualSize.height / targetSize.height;
    return Offset(targetOffset.dx * scaleX, targetOffset.dy * scaleY);
  }

  /// Scales a value from the target coordinate system to the local canvas system.
  /// We use the average of the scale factors to have a consistent scaling for radii and stroke widths.
  double _scaleValueToLocal(double targetValue) {
    if (targetSize.isEmpty || actualSize.isEmpty) return targetValue;
    final scaleX = actualSize.width / targetSize.width;
    final scaleY = actualSize.height / targetSize.height;
    return targetValue * ((scaleX + scaleY) / 2.0);
  }

  // Ray-casting (Pnpoly) algoritme om te bepalen of een punt zich in een veelhoek bevindt
  static bool _isPointInPolygon(Offset p, List<Offset> vertices) {
    var inside = false;
    var j = vertices.length - 1;
    for (var i = 0; i < vertices.length; i++) {
      if (((vertices[i].dy > p.dy) != (vertices[j].dy > p.dy)) &&
          (p.dx <
              (vertices[j].dx - vertices[i].dx) *
                      (p.dy - vertices[i].dy) /
                      (vertices[j].dy - vertices[i].dy) +
                  vertices[i].dx)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final currentIds = currentElements.map((e) => e.id).toSet();
    final staticElements = elements
        .where((e) => !currentIds.contains(e.id))
        .toList();

    // 1. Teken eerst de stilstaande lijnen en vormen (alles behalve iconen)
    for (final element in staticElements.where((e) => e is! IconElement)) {
      _drawElement(canvas, size, element);
    }
    // 2. Teken dan de bewegende/getekende lijnen en vormen
    for (final element in currentElements.where((e) => e is! IconElement)) {
      _drawElement(canvas, size, element);
    }
    // 3. Teken stilstaande icoontjes er bovenop
    for (final element in staticElements.whereType<IconElement>()) {
      _drawElement(canvas, size, element);
    }
    // 4. Teken tot slot de momenteel versleepte icoontjes
    for (final element in currentElements.whereType<IconElement>()) {
      _drawElement(canvas, size, element);
    }

    // Draw selection UI if an element is selected
    final selectedElement = _findElementById(selectedElementId);
    if (selectedElement != null) {
      _drawSelectionUI(canvas, selectedElement);
    } else if (_findElementById(selectedElementId, checkCurrent: false) !=
        null) {
      _drawSelectionUI(
        canvas,
        _findElementById(selectedElementId, checkCurrent: false)!,
      );
    }
  }

  SketchElement? _findElementById(String? id, {bool checkCurrent = true}) {
    if (id == null) return null;
    if (checkCurrent) {
      try {
        // Check current elements first for immediate feedback
        return currentElements.firstWhere((e) => e.id == id);
      } catch (_) {
        // Then check persisted elements
      }
    }
    // Check persisted elements
    try {
      return elements.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void _drawElement(Canvas canvas, Size size, SketchElement element) {
    switch (element) {
      case PathElement(:final points, :final color, :final strokeWidth):
        if (points.isEmpty) return;

        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;

        final path = Path();
        final firstPoint = _scaleToLocal(points.first.offset);
        path.moveTo(firstPoint.dx, firstPoint.dy);
        for (var i = 1; i < points.length; i++) {
          final point = _scaleToLocal(points[i].offset);
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint);

      case ArrowElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
      ):
        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;
        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);

        final path = Path()
          ..moveTo(localStart.dx, localStart.dy)
          ..lineTo(localEnd.dx, localEnd.dy);

        // Draw arrow head
        final angle = math.atan2(
          localEnd.dy - localStart.dy,
          localEnd.dx - localStart.dx,
        );
        final arrowSize = _scaleValueToLocal(15.0);
        const arrowAngle = 25 * math.pi / 180;
        path.moveTo(
          localEnd.dx - arrowSize * math.cos(angle - arrowAngle),
          localEnd.dy - arrowSize * math.sin(angle - arrowAngle),
        );
        path.lineTo(localEnd.dx, localEnd.dy);
        path.lineTo(
          localEnd.dx - arrowSize * math.cos(angle + arrowAngle),
          localEnd.dy - arrowSize * math.sin(angle + arrowAngle),
        );

        canvas.drawPath(path, paint);

      case LineElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
      ):
        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;
        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);
        canvas.drawLine(localStart, localEnd, paint);

      case RectangleElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);
        final rect = Rect.fromPoints(localStart, localEnd);
        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawRect(rect, paint);
        }
        paint.style = PaintingStyle.stroke;
        paint.color = color;
        paint.strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawRect(rect, paint);

      case PolygonElement(
        :final points,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        if (points.isEmpty) return;

        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final path = Path();
        final firstPoint = _scaleToLocal(points.first.offset);
        path.moveTo(firstPoint.dx, firstPoint.dy);
        for (var i = 1; i < points.length; i++) {
          final point = _scaleToLocal(points[i].offset);
          path.lineTo(point.dx, point.dy);
        }
        path.close(); // Maak de vorm sluitend!

        // Teken vulling
        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawPath(path, paint);
        }

        // Teken randen
        paint
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawPath(path, paint);

        // EXTRA: Als deze veelhoek op dit moment getekend wordt (in currentElements),
        // teken dan kleine hulpcirkels op de hoekpunten zodat de coach ziet waar hij kan klikken.
        final isTemporary = currentElements.any((e) => e.id == element.id);
        if (isTemporary) {
          final vertexPaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;
          for (final p in points) {
            canvas.drawCircle(_scaleToLocal(p.offset), 4.0, vertexPaint);
          }
          // Highlight het allereerste punt extra als 'sluitingsdoel'
          canvas.drawCircle(
            _scaleToLocal(points.first.offset),
            7.0,
            Paint()
              ..color = Colors.green
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
          );
        }

      case CircleElement(
        :final center,
        :final radius,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final localCenter = _scaleToLocal(center);
        final localRadius = _scaleValueToLocal(radius);

        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawCircle(localCenter, localRadius, paint);
        }
        paint.style = PaintingStyle.stroke;
        paint.color = color;
        paint.strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawCircle(localCenter, localRadius, paint);

      case IconElement(
        :final position,
        :final iconId,
        :final size,
        :final rotation,
      ):
        final iconData = availableIcons[iconId];
        if (iconData == null) return;
        final localPosition = _scaleToLocal(position);
        final localSize = _scaleValueToLocal(size);

        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(iconData.codePoint),
            style: TextStyle(
              fontSize: localSize,
              fontFamily: iconData.fontFamily,
              color: Colors.black, // Icons have their own color
            ),
          ),
        )..layout();

        canvas.save();
        canvas.translate(localPosition.dx, localPosition.dy);
        canvas.rotate(rotation);
        textPainter.paint(canvas, Offset(-localSize / 2, -localSize / 2));
        canvas.restore();
    }
  }

  void _drawSelectionUI(Canvas canvas, SketchElement element) {
    final rect = getBoundingBox(element, actualSize, targetSize);
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw a dashed bounding box
    // A simple rectangle is fine for now.
    // For a dashed line, a more complex path drawing logic would be needed.
    paint.color = Colors.blue.withAlpha(127);
    canvas.drawRect(rect.inflate(2.0), paint);

    // If it's an icon, draw the rotation handle
    if (element is IconElement) {
      final handleOffset = getRotationHandle(element, actualSize, targetSize);
      canvas.drawLine(_scaleToLocal(element.position), handleOffset, paint);
      canvas.drawCircle(handleOffset, 6, paint..style = PaintingStyle.fill);

      // Draw dropdown handle
      final dropdownHandleOffset = getDropdownHandle(
        element,
        actualSize,
        targetSize,
      );
      final path = Path()
        ..moveTo(dropdownHandleOffset.dx - 6, dropdownHandleOffset.dy - 4)
        ..lineTo(dropdownHandleOffset.dx + 6, dropdownHandleOffset.dy - 4)
        ..lineTo(dropdownHandleOffset.dx, dropdownHandleOffset.dy + 4)
        ..close();
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
    }
  }

  static Offset getRotationHandle(
    IconElement element,
    Size actualSize,
    Size targetSize,
  ) {
    const handleDistance = 20.0;
    // We calculate in local space, so scale the element size first
    final scaleX = actualSize.width / targetSize.width;
    final scaleY = actualSize.height / targetSize.height;
    final avgScale = (scaleX + scaleY) / 2.0;

    final localPosition = Offset(
      element.position.dx * scaleX,
      element.position.dy * scaleY,
    );
    final localSize = element.size * avgScale;

    final handleVector = Offset(0, -localSize / 2 - handleDistance);
    return localPosition +
        Offset.fromDirection(
          handleVector.direction + element.rotation,
          handleVector.distance,
        );
  }

  static Offset getDropdownHandle(
    IconElement element,
    Size actualSize,
    Size targetSize,
  ) {
    final rect = getBoundingBox(element, actualSize, targetSize);
    return rect.centerRight + const Offset(15, 0);
  }

  static bool elementHitTest(
    SketchElement element,
    Offset localPoint,
    Size actualSize,
    Size targetSize,
  ) {
    // Define a tolerance for how close the user must be to an element to erase/select it.
    // This could be a fixed value or based on the element's stroke width.
    const double hitTolerance = 25.0;

    // Helper to scale offsets from target to local space for hit testing
    Offset scaleToLocal(Offset o) {
      if (actualSize.isEmpty || targetSize.isEmpty) return o;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return Offset(o.dx * scaleX, o.dy * scaleY);
    }

    // Helper to scale values (like stroke width)
    double scaleValToLocal(double v) {
      if (actualSize.isEmpty || targetSize.isEmpty) return v;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return v * ((scaleX + scaleY) / 2.0);
    }

    // Helper to calculate the shortest distance from a point to a line segment.
    double distanceToSegment(Offset p, Offset a, Offset b) {
      final l2 = (a - b).distanceSquared;
      if (l2 == 0.0) return (p - a).distance;
      final t =
          ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
      final clampedT = t.clamp(0.0, 1.0);
      final projection = a + (b - a) * clampedT;
      return (p - projection).distance;
    }

    switch (element) {
      case PathElement(:final points, :final strokeWidth):
        if (points.length < 2) return false;
        final tolerance = math.max(
          hitTolerance,
          scaleValToLocal(strokeWidth.toDouble()),
        );
        for (var i = 0; i < points.length - 1; i++) {
          final p1 = scaleToLocal(points[i].offset);
          final p2 = scaleToLocal(points[i + 1].offset);
          if (distanceToSegment(localPoint, p1, p2) <= tolerance / 2) {
            return true;
          }
        }
        return false;

      case LineElement(:final start, :final end, :final strokeWidth):
      case ArrowElement(:final start, :final end, :final strokeWidth):
        final tolerance = math.max(
          hitTolerance,
          scaleValToLocal(strokeWidth.toDouble()),
        );
        final localStart = scaleToLocal(start);
        final localEnd = scaleToLocal(end);
        return distanceToSegment(localPoint, localStart, localEnd) <=
            tolerance / 2;

      case RectangleElement(:final start, :final end, :final strokeWidth):
        final localStart = scaleToLocal(start);
        final localEnd = scaleToLocal(end);
        final rect = Rect.fromPoints(localStart, localEnd);

        final tolerance = math.max(
          hitTolerance,
          scaleValToLocal(strokeWidth.toDouble()),
        );
        final tl = rect.topLeft;
        final tr = rect.topRight;
        final bl = rect.bottomLeft;
        final br = rect.bottomRight;

        return distanceToSegment(localPoint, tl, tr) <= tolerance / 2 ||
            distanceToSegment(localPoint, tr, br) <= tolerance / 2 ||
            distanceToSegment(localPoint, br, bl) <= tolerance / 2 ||
            distanceToSegment(localPoint, bl, tl) <= tolerance / 2;

      case PolygonElement(:final points, :final strokeWidth, :final fillColor):
        if (points.length < 3) return false;
        final tolerance = math.max(
          hitTolerance,
          scaleValToLocal(strokeWidth.toDouble()),
        );

        // 1. Check of de klik op de perimeter (de randen) ligt
        for (var i = 0; i < points.length; i++) {
          final p1 = scaleToLocal(points[i].offset);
          // Sluit de lus door van het laatste punt terug naar het eerste te gaan (% points.length)
          final p2 = scaleToLocal(points[(i + 1) % points.length].offset);
          if (distanceToSegment(localPoint, p1, p2) <= tolerance / 2) {
            return true;
          }
        }

        // 2. Als de veelhoek gevuld is, check dan of de klik binnen de veelhoek valt (Ray-Casting)
        if (fillColor != null) {
          final localVertices = points
              .map((p) => scaleToLocal(p.offset))
              .toList();
          return _isPointInPolygon(localPoint, localVertices);
        }
        return false;

      case CircleElement(:final center, :final radius, :final strokeWidth):
        final localCenter = scaleToLocal(center);
        final localRadius = scaleValToLocal(radius);
        final distance = (localPoint - localCenter).distance;

        final tolerance = math.max(
          hitTolerance,
          scaleValToLocal(strokeWidth.toDouble()),
        );
        return (distance - localRadius).abs() <= tolerance / 2;

      case IconElement():
        // For icons, the bounding box is a reasonable approximation.
        return getBoundingBox(
          element,
          actualSize,
          targetSize,
        ).contains(localPoint);
    }
  }

  static Rect getBoundingBox(
    SketchElement element,
    Size actualSize,
    Size targetSize,
  ) {
    // Helper to scale offsets for bounding box calculation
    Offset scale(Offset o) {
      if (actualSize.isEmpty || targetSize.isEmpty) return o;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return Offset(o.dx * scaleX, o.dy * scaleY);
    }

    // Helper to scale values
    double scaleVal(double v) {
      if (actualSize.isEmpty || targetSize.isEmpty) return v;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return v * ((scaleX + scaleY) / 2.0);
    }

    switch (element) {
      case PathElement(:final points, :final strokeWidth):
        if (points.isEmpty) return Rect.zero;
        var l = scale(points.first.offset).dx,
            r = l,
            t = scale(points.first.offset).dy,
            b = t;
        for (final p in points) {
          final localP = scale(p.offset);
          l = math.min(l, localP.dx);
          r = math.max(r, localP.dx);
          t = math.min(t, localP.dy);
          b = math.max(b, localP.dy);
        }
        return Rect.fromLTRB(
          l,
          t,
          r,
          b,
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case ArrowElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case LineElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case RectangleElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case PolygonElement(:final points, :final strokeWidth):
        if (points.isEmpty) return Rect.zero;
        var l = scale(points.first.offset).dx,
            r = l,
            t = scale(points.first.offset).dy,
            b = t;
        for (final p in points) {
          final localP = scale(p.offset);
          l = math.min(l, localP.dx);
          r = math.max(r, localP.dx);
          t = math.min(t, localP.dy);
          b = math.max(b, localP.dy);
        }
        return Rect.fromLTRB(
          l,
          t,
          r,
          b,
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case CircleElement(:final center, :final radius, :final strokeWidth):
        return Rect.fromCircle(
          center: scale(center),
          radius: scaleVal(radius),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case IconElement(:final position, :final size):
        // Bounding box for selection is in local space
        return Rect.fromCenter(
          center: scale(position),
          width: scaleVal(size),
          height: scaleVal(size),
        );
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}
