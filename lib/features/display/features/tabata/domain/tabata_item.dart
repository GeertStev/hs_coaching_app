import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_group.dart';

part 'tabata_item.freezed.dart';
part 'tabata_item.g.dart';

/// Eén kaart op het topniveau van [Tabata.items]: hetzij een losse oefening,
/// hetzij een groep oefeningen. Union-type zodat de editor en de
/// tijdlijn-berekening (`Tabata._flatten`) beide types uniform kunnen
/// verwerken via pattern matching.
@freezed
sealed class TabataItem with _$TabataItem {
  const TabataItem._();

  @JsonSerializable(explicitToJson: true)
  const factory TabataItem.exercise(TabataExercise exercise) =
      TabataItemExercise;
  @JsonSerializable(explicitToJson: true)
  const factory TabataItem.group(TabataGroup group) = TabataItemGroup;

  factory TabataItem.fromJson(Map<String, dynamic> json) =>
      _$TabataItemFromJson(json);

  /// Rust ná deze kaart, vóór de volgende sibling-kaart (genegeerd als dit de
  /// laatste kaart in zijn lijst is) — ongeacht of het een oefening of een
  /// groep is.
  int get restAfter => switch (this) {
    TabataItemExercise(:final exercise) => exercise.restAfter,
    TabataItemGroup(:final group) => group.restAfter,
  };

  /// Stabiele id van de onderliggende oefening/groep (voor slepen/herordenen).
  String get id => switch (this) {
    TabataItemExercise(:final exercise) => exercise.id,
    TabataItemGroup(:final group) => group.id,
  };

  /// Duur van deze kaart (zonder [restAfter]) — voor kaart-samenvattingen.
  int get durationMillis => switch (this) {
    TabataItemExercise(:final exercise) => exercise.durationMillis,
    TabataItemGroup(:final group) => group.durationMillis,
  };
}
