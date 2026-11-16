import 'package:hs_coaching_core/core/errors/user_message.dart';
import 'package:hs_coaching_core/scheduler/rating_config.dart';
import 'package:hs_coaching_core/scheduler/scheduler_models.dart';
import 'package:hs_coaching_core/scheduler/sheet_import.dart';

/// Foutmelding voor de schermen van de Team scheduler; valt terug op core's
/// `userMessage`.
String schedulerErrorMessage(Object? error) {
  if (error is SheetImportException || error is FormatException) {
    return 'This file is not a Teamscheduler export.';
  }
  return userMessage(error);
}

/// Naam van de rang zonder het volgnummer uit het blad ("16.Dolphin").
String rankName(RankTier? tier) {
  if (tier == null) return '';
  final dot = tier.name.indexOf('.');
  return dot < 0 ? tier.name : tier.name.substring(dot + 1);
}

String adjustmentTypeLabel(RatingAdjustmentType type) => switch (type) {
  RatingAdjustmentType.instant => 'Instant',
  RatingAdjustmentType.linear => 'Linear',
};

/// Een wijziging met teken, bv. "+50" of "-25".
String signed(double value) {
  final rounded = value.round();
  return rounded > 0 ? '+$rounded' : '$rounded';
}
