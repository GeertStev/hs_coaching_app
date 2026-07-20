import 'package:freezed_annotation/freezed_annotation.dart';

part 'sketch_background.freezed.dart';
part 'sketch_background.g.dart';

@freezed
abstract class SketchBackground with _$SketchBackground {
  const factory SketchBackground({
    @Default('Untitled') String title,
    @Default('') String url,
  }) = _SketchBackground;

  factory SketchBackground.fromJson(Map<String, dynamic> json) =>
      _$SketchBackgroundFromJson(json);
}
