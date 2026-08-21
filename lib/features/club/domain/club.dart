import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_core/core/data/firestore_converters.dart';

part 'club.freezed.dart';
part 'club.g.dart';

/// Een club (bv. Holy Squid). Leden, ploegen en uitnodigingen leven in
/// subcollecties onder `clubs/{clubId}`.
@freezed
abstract class Club with _$Club {
  const factory Club({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    required String name,
    String? description,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
