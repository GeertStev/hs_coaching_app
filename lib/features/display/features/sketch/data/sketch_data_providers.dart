import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/i_sketch_repository.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_repository.dart';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_core/sketch/sketch_background.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';

/// Biedt toegang tot de ISketchRepository interface met de juiste club- en display-IDs.
final sketchRepositoryProvider = Provider<ISketchRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  return DisplaySketchRepository(
    firestore: firestore,
    storage: storage,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// Streamed het ID van de momenteel actieve sketch.
final currentSketchIdDocProvider = StreamProvider<String?>((ref) {
  return ref.watch(sketchRepositoryProvider).watchCurrentSketchId();
});

/// Streamed de lijst met alle actieve sketches, optioneel gefilterd op tag.
final sketchListStreamProvider = StreamProvider.family<List<Sketch>, String?>((
  ref,
  tag,
) {
  return ref.watch(sketchRepositoryProvider).watchAllActiveSketches(tag: tag);
});

/// Streamed alle beschikbare sketch-tags voor het filtersysteem.
final allSketchTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(sketchRepositoryProvider).watchAllSketchTags();
});

/// Streamed de metadata van één specifieke sketch op basis van zijn ID.
final sketchProvider = StreamProvider.family<Sketch, String>((ref, sketchId) {
  ref.watch(displayDeviceIdsProvider);
  return ref.watch(sketchRepositoryProvider).watchSketch(sketchId);
});

/// Streamed de beschikbare achtergronden (bijv. tactische lay-outs van het zwembad).
final sketchBackgroundsProvider = StreamProvider<List<SketchBackground>>((ref) {
  return ref.watch(sketchRepositoryProvider).watchSketchBackgrounds();
});

/// Streamed de realtime elementen met Optimistic UI updates, volledig conform Riverpod 3.0.
class SketchElementsNotifier extends StreamNotifier<List<SketchElement>> {
  final String sketchId;

  // Parameter wordt nu netjes via de constructor binnengehaald
  SketchElementsNotifier(this.sketchId);

  @override
  Stream<List<SketchElement>> build() {
    ref.watch(displayDeviceIdsProvider);
    return ref.watch(sketchRepositoryProvider).getSketchElements(sketchId);
  }

  void addOrUpdateOptimistically(SketchElement element) {
    // Gebruik .value in plaats van .valueOrNull
    final currentElements = state.value ?? [];
    final elements = List<SketchElement>.from(currentElements);

    final index = elements.indexWhere((e) => e.id == element.id);
    if (index >= 0) {
      elements[index] = element;
    } else {
      elements.add(element);
    }

    state = AsyncData(elements);
  }

  void removeOptimistically(String elementId) {
    // Gebruik .value in plaats van .valueOrNull
    final currentElements = state.value ?? [];
    final elements = List<SketchElement>.from(currentElements)
      ..removeWhere((e) => e.id == elementId);

    state = AsyncData(elements);
  }
}

// De .family modifier op de provider blijft bestaan, maar koppelt de argumenten nu aan de constructor
final sketchElementsStreamProvider =
    StreamNotifierProvider.family<
      SketchElementsNotifier,
      List<SketchElement>,
      String
    >(SketchElementsNotifier.new);
