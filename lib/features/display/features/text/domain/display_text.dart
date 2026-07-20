import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';

part 'display_text.freezed.dart';
part 'display_text.g.dart';

enum DisplayTextStatus { active, archived }

@freezed
abstract class DisplayText with _$DisplayText {
  const factory DisplayText({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    String? title,
    required String text,
    required String userId,
    @ServerWriteTimestampConverter() required DateTime timestamp,
    @Default(DisplayTextStatus.active)
    @JsonKey(unknownEnumValue: DisplayTextStatus.active)
    DisplayTextStatus status,
    @Default(<String>[]) List<String> tags,
  }) = _DisplayText;

  factory DisplayText.fromJson(Map<String, dynamic> json) =>
      _$DisplayTextFromJson(json);
}
