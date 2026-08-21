import 'package:flutter/material.dart';

/// Naamgevingsconventie uit DESIGN_dark.md/DESIGN_light.md ("Kinetic Performance
/// System"). De namen (`timer-display`, `data-point`, ...) komen niet overeen met
/// Flutter's standaard TextTheme-slots (`displayLarge`, `bodyMedium`, ...), dus een
/// aparte ThemeExtension houdt de call sites leesbaar als
/// `Theme.of(context).typography.timerDisplay` in plaats van te gokken welke
/// M3-slot het dichtst in de buurt komt.
///
/// De type-schaal zelf (font/size/weight/lineHeight/letterSpacing) is identiek
/// tussen de twee thema's — alleen de kleur verschilt (`onSurface` per thema) —
/// vandaar dat [kinetic] die als enige parameter neemt in plaats van een aparte
/// factory per thema.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.timerDisplay,
    required this.headlineLg,
    required this.headlineMd,
    required this.headlineSm,
    required this.headlineLgMobile,
    required this.bodyLg,
    required this.bodyMd,
    required this.labelCaps,
    required this.dataPoint,
  });

  factory AppTypography.kinetic({required Color onSurface}) {
    const anybody = 'Anybody';
    const hankenGrotesk = 'Hanken Grotesk';
    const jetBrainsMono = 'JetBrains Mono';

    return AppTypography(
      timerDisplay: TextStyle(
        fontFamily: anybody,
        fontSize: 84,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: -3.36, // -0.04em * 84px
        color: onSurface,
      ),
      headlineLg: TextStyle(
        fontFamily: anybody,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: onSurface,
      ),
      headlineMd: TextStyle(
        fontFamily: anybody,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      headlineSm: TextStyle(
        fontFamily: anybody,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      headlineLgMobile: TextStyle(
        fontFamily: anybody,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: onSurface,
      ),
      bodyLg: TextStyle(
        fontFamily: hankenGrotesk,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: onSurface,
      ),
      bodyMd: TextStyle(
        fontFamily: hankenGrotesk,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),
      labelCaps: TextStyle(
        fontFamily: jetBrainsMono,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: 1.2, // 0.1em * 12px
        color: onSurface,
      ),
      dataPoint: TextStyle(
        fontFamily: jetBrainsMono,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1,
        color: onSurface,
      ),
    );
  }

  final TextStyle timerDisplay;
  final TextStyle headlineLg;
  final TextStyle headlineMd;
  final TextStyle headlineSm;
  final TextStyle headlineLgMobile;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle labelCaps;
  final TextStyle dataPoint;

  @override
  AppTypography copyWith({
    TextStyle? timerDisplay,
    TextStyle? headlineLg,
    TextStyle? headlineMd,
    TextStyle? headlineSm,
    TextStyle? headlineLgMobile,
    TextStyle? bodyLg,
    TextStyle? bodyMd,
    TextStyle? labelCaps,
    TextStyle? dataPoint,
  }) {
    return AppTypography(
      timerDisplay: timerDisplay ?? this.timerDisplay,
      headlineLg: headlineLg ?? this.headlineLg,
      headlineMd: headlineMd ?? this.headlineMd,
      headlineSm: headlineSm ?? this.headlineSm,
      headlineLgMobile: headlineLgMobile ?? this.headlineLgMobile,
      bodyLg: bodyLg ?? this.bodyLg,
      bodyMd: bodyMd ?? this.bodyMd,
      labelCaps: labelCaps ?? this.labelCaps,
      dataPoint: dataPoint ?? this.dataPoint,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      timerDisplay: TextStyle.lerp(timerDisplay, other.timerDisplay, t)!,
      headlineLg: TextStyle.lerp(headlineLg, other.headlineLg, t)!,
      headlineMd: TextStyle.lerp(headlineMd, other.headlineMd, t)!,
      headlineSm: TextStyle.lerp(headlineSm, other.headlineSm, t)!,
      headlineLgMobile: TextStyle.lerp(headlineLgMobile, other.headlineLgMobile, t)!,
      bodyLg: TextStyle.lerp(bodyLg, other.bodyLg, t)!,
      bodyMd: TextStyle.lerp(bodyMd, other.bodyMd, t)!,
      labelCaps: TextStyle.lerp(labelCaps, other.labelCaps, t)!,
      dataPoint: TextStyle.lerp(dataPoint, other.dataPoint, t)!,
    );
  }
}
