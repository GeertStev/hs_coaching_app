import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';

part 'sketch.freezed.dart';
part 'sketch.g.dart';

enum SketchStatus { active, archived }

@freezed
abstract class Sketch with _$Sketch {
  const factory Sketch({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    required String title,
    String? description,
    @TimestampOrNowConverter() required DateTime lastModified,
    required String userId,
    @Default(<String>[]) List<String> tags,
    @Default(SketchStatus.active)
    @JsonKey(unknownEnumValue: SketchStatus.active)
    SketchStatus status,
    @JsonKey(includeIfNull: false) String? backgroundUrl,
  }) = _Sketch;

  factory Sketch.fromJson(Map<String, dynamic> json) =>
      _$SketchFromJson(json);
}
