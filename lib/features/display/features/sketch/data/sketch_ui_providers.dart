import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/application/search_service.dart';

enum DrawingTool {
  freehand,
  arrow,
  line,
  rectangle,
  polygon,
  circle,
  eraser,
  select,
}

/// Beheert de actieve tekentool en deselecteert elementen bij een switch.
class ActiveToolNotifier extends Notifier<DrawingTool> {
  @override
  DrawingTool build() => DrawingTool.freehand;

  void setTool(DrawingTool tool) {
    ref.read(selectedElementIdProvider.notifier).deselect();
    state = tool;
  }
}

final activeToolProvider = NotifierProvider<ActiveToolNotifier, DrawingTool>(
  ActiveToolNotifier.new,
);

/// Beheert de actieve tekenkleur voor nieuwe vormen.
class SelectedColorNotifier extends Notifier<Color> {
  @override
  Color build() => Colors.white;

  void setColor(Color color) => state = color;
}

final selectedColorProvider = NotifierProvider<SelectedColorNotifier, Color>(
  SelectedColorNotifier.new,
);

/// Beheert de lijndikte van de actieve tekenpen.
class StrokeWidthNotifier extends Notifier<int> {
  @override
  int build() => 2;

  void setStrokeWidth(int width) => state = width;
}

final strokeWidthProvider = NotifierProvider<StrokeWidthNotifier, int>(
  StrokeWidthNotifier.new,
);

/// Bepaalt of gesloten vormen (cirkel/rechthoek) gevuld moeten worden.
class FillShapeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final fillShapeProvider = NotifierProvider<FillShapeNotifier, bool>(
  FillShapeNotifier.new,
);

/// Houdt het ID bij van het geselecteerde element op het canvas (voor verplaatsing/rotatie).
class SelectedElementIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? elementId) => state = elementId;
  void deselect() => state = null;
}

final selectedElementIdProvider =
    NotifierProvider<SelectedElementIdNotifier, String?>(
      SelectedElementIdNotifier.new,
    );

/// Beheert de geselecteerde tag ten behoeve van de filter-UI in de lijst.
class SelectedTagNotifier extends Notifier<String?> implements TagNotifier {
  @override
  String? build() => null;

  @override
  void setTag(String? newTag) => state = newTag;
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
);

/// Beheert de zoekquery voor de sketchlijst met een ingebouwde debounce van 500ms.
class SearchQueryNotifier extends Notifier<String> implements SearchNotifier {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  @override
  void setQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => state = query);
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
