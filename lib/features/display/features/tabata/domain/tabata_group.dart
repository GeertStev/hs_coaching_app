import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/features/display/features/tabata/domain/tabata_exercise.dart';
import 'package:uuid/uuid.dart';

part 'tabata_group.freezed.dart';
part 'tabata_group.g.dart';

/// Een groep oefeningen (gevormd door één kaart op een andere te droppen in
/// de editor): [children] worden na elkaar afgewerkt, en die hele reeks wordt
/// [rounds] keer herhaald met [restBetweenRepeats] rust tussen de herhalingen
/// (geen rust na de laatste herhaling). Eén niveau diep — een groep bevat geen
/// geneste groepen.
///
/// [restAfter] is de rust ná deze groep, vóór de volgende (sibling) kaart.
/// Wordt genegeerd wanneer dit de laatste kaart in [Tabata.items] is.
@freezed
abstract class TabataGroup with _$TabataGroup {
  const TabataGroup._();

  @JsonSerializable(explicitToJson: true)
  const factory TabataGroup({
    required String id,
    @Default('') String title,
    @Default(1) int rounds,
    @Default(0) int restBetweenRepeats,
    @Default(<TabataExercise>[]) List<TabataExercise> children,
    @Default(0) int restAfter,
  }) = _TabataGroup;

  factory TabataGroup.fromJson(Map<String, dynamic> json) =>
      _$TabataGroupFromJson(json);

  /// Duur van deze groep (alle herhalingen + rust ertussen + rust tussen de
  /// kinderen, zonder [restAfter]) — voor kaart-samenvattingen. Niet gebruikt
  /// door [Tabata.progressAt], die werkt op de volledige tijdlijn.
  int get durationMillis {
    if (rounds <= 0 || children.isEmpty) return 0;
    var perRepeatMillis = 0;
    for (var i = 0; i < children.length; i++) {
      perRepeatMillis += children[i].durationMillis;
      if (i < children.length - 1) {
        perRepeatMillis += children[i].restAfter * 1000;
      }
    }
    return perRepeatMillis * rounds + (rounds - 1) * restBetweenRepeats * 1000;
  }
}

/// Nieuwe groep met een verse id, gevormd uit [children].
TabataGroup newTabataGroup({
  required List<TabataExercise> children,
  String title = '',
}) {
  return TabataGroup(id: const Uuid().v4(), title: title, children: children);
}
