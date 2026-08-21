import 'package:flutter/material.dart';

/// Afstand- en radiusschaal uit DESIGN.md (`rounded`/`spacing`). Beide zijn statische
/// waarden op een 4px-grid die nooit per thema variëren, maar wonen als ThemeExtension
/// naast [AppTypography] zodat call sites hetzelfde `Theme.of(context)`-toegangspatroon
/// gebruiken in plaats van losse top-level constanten.
@immutable
class AppMetrics extends ThemeExtension<AppMetrics> {
  const AppMetrics({
    required this.radiusSm,
    required this.radiusDefault,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.spacingUnit,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.containerMargin,
    required this.gutter,
    required this.cardPadding,
  });

  factory AppMetrics.kinetic() {
    return const AppMetrics(
      radiusSm: 4, // 0.25rem
      radiusDefault: 8, // 0.5rem
      radiusMd: 12, // 0.75rem
      radiusLg: 16, // 1rem
      radiusXl: 24, // 1.5rem
      radiusFull: 9999,
      spacingUnit: 4,
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 16,
      spacingLg: 24,
      spacingXl: 32,
      containerMargin: 16,
      gutter: 12,
      cardPadding: 16,
    );
  }

  final double radiusSm;
  final double radiusDefault;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;
  final double spacingUnit;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double containerMargin;
  final double gutter;
  final double cardPadding;

  @override
  AppMetrics copyWith({
    double? radiusSm,
    double? radiusDefault,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    double? spacingUnit,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? containerMargin,
    double? gutter,
    double? cardPadding,
  }) {
    return AppMetrics(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusDefault: radiusDefault ?? this.radiusDefault,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      spacingUnit: spacingUnit ?? this.spacingUnit,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      containerMargin: containerMargin ?? this.containerMargin,
      gutter: gutter ?? this.gutter,
      cardPadding: cardPadding ?? this.cardPadding,
    );
  }

  @override
  AppMetrics lerp(ThemeExtension<AppMetrics>? other, double t) {
    if (other is! AppMetrics) return this;
    double l(double a, double b) => a + (b - a) * t;
    return AppMetrics(
      radiusSm: l(radiusSm, other.radiusSm),
      radiusDefault: l(radiusDefault, other.radiusDefault),
      radiusMd: l(radiusMd, other.radiusMd),
      radiusLg: l(radiusLg, other.radiusLg),
      radiusXl: l(radiusXl, other.radiusXl),
      radiusFull: l(radiusFull, other.radiusFull),
      spacingUnit: l(spacingUnit, other.spacingUnit),
      spacingXs: l(spacingXs, other.spacingXs),
      spacingSm: l(spacingSm, other.spacingSm),
      spacingMd: l(spacingMd, other.spacingMd),
      spacingLg: l(spacingLg, other.spacingLg),
      spacingXl: l(spacingXl, other.spacingXl),
      containerMargin: l(containerMargin, other.containerMargin),
      gutter: l(gutter, other.gutter),
      cardPadding: l(cardPadding, other.cardPadding),
    );
  }
}
