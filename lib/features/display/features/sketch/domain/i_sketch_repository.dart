import 'dart:io';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_core/sketch/sketch_background.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';

abstract class ISketchRepository {
  /// Streamed de realtime elementen van een specifieke sketch.
  Stream<List<SketchElement>> getSketchElements(String sketchId);

  /// Voegt een element toe of werkt een bestaand element bij.
  Future<void> addOrUpdateElement(String sketchId, SketchElement element);

  /// Verwijdert een specifiek element uit een sketch.
  Future<void> removeElement(String sketchId, String elementId);

  /// Verwijdert alle elementen van een sketch.
  Future<void> clearSketch(String sketchId);

  /// Streamed de lijst met alle actieve sketches, optioneel gefilterd op tag.
  Stream<List<Sketch>> watchAllActiveSketches({String? tag});

  /// Streamed de metadata van één specifieke sketch op basis van zijn ID.
  Stream<Sketch> watchSketch(String sketchId);

  /// Maakt een nieuwe sketch aan en retourneert het gegenereerde ID.
  Future<String> createSketch({
    required String title,
    required String userId,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  });

  /// Werkt de metadata van een bestaande sketch bij.
  Future<void> updateSketch({
    required String id,
    required String title,
    String? description,
    required List<String> tags,
    String? backgroundUrl,
  });

  /// Archiveert een sketch.
  Future<void> archiveSketch(String sketchId);

  /// Haalt een sketch uit het archief.
  Future<void> unarchiveSketch(String sketchId);

  /// Verwijdert een sketch permanent inclusief alle subcollecties.
  Future<void> hardDeleteSketch(String sketchId);

  /// Werkt de `lastModified` timestamp van de sketch bij.
  Future<void> updateSketchTimestamp(String sketchId);

  /// Streamed het ID van de momenteel actieve sketch.
  Stream<String?> watchCurrentSketchId();

  /// Zet het ID van de momenteel actieve sketch.
  Future<void> setCurrentSketchId(String? sketchId);

  /// Wist de huidige actieve sketch-koppeling.
  Future<void> clearCurrentSketch();

  /// Voegt een nieuwe achtergrondafbeelding toe.
  Future<void> addSketchBackground({
    required File imageFile,
    required String title,
  });

  /// Wijzigt direct de achtergrond-URL van een specifieke sketch.
  Future<void> updateSketchBackground(String id, String? backgroundUrl);

  /// Streamed alle unieke gebruikte sketch-tags.
  Stream<List<String>> watchAllSketchTags();

  /// Streamed alle beschikbare achtergronden.
  Stream<List<SketchBackground>> watchSketchBackgrounds();
}
