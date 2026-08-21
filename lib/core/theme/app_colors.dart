import 'package:flutter/material.dart';

/// Kleurtokens uit DESIGN_dark.md ("Kinetic Performance System" — het originele,
/// donkere thema).
abstract final class AppColorsDark {
  static const surface = Color(0xFF121414);
  static const surfaceDim = Color(0xFF121414);
  static const surfaceBright = Color(0xFF38393A);
  static const surfaceContainerLowest = Color(0xFF0C0F0F);
  static const surfaceContainerLow = Color(0xFF1A1C1C);
  static const surfaceContainer = Color(0xFF1E2020);
  static const surfaceContainerHigh = Color(0xFF282A2B);
  static const surfaceContainerHighest = Color(0xFF333535);
  static const onSurface = Color(0xFFE2E2E2);
  static const onSurfaceVariant = Color(0xFFC4C5D6);
  static const inverseSurface = Color(0xFFE2E2E2);
  static const inverseOnSurface = Color(0xFF2F3131);
  static const outline = Color(0xFF8E909F);
  static const outlineVariant = Color(0xFF444653);
  static const surfaceTint = Color(0xFFB7C4FF);

  static const primary = Color(0xFFB7C4FF);
  static const onPrimary = Color(0xFF002583);
  static const primaryContainer = Color(0xFF0033AA);
  static const onPrimaryContainer = Color(0xFF94A9FF);
  static const inversePrimary = Color(0xFF3354C8);
  static const primaryFixed = Color(0xFFDDE1FF);
  static const primaryFixedDim = Color(0xFFB7C4FF);
  static const onPrimaryFixed = Color(0xFF001453);
  static const onPrimaryFixedVariant = Color(0xFF0F3AB0);

  static const secondary = Color(0xFFFEBA2F);
  static const onSecondary = Color(0xFF422C00);
  static const secondaryContainer = Color(0xFFD99A00);
  static const onSecondaryContainer = Color(0xFF503700);
  static const secondaryFixed = Color(0xFFFFDEAA);
  static const secondaryFixedDim = Color(0xFFFEBA2F);
  static const onSecondaryFixed = Color(0xFF271900);
  static const onSecondaryFixedVariant = Color(0xFF5F4100);

  static const tertiary = Color(0xFFC8C6C5);
  static const onTertiary = Color(0xFF313030);
  static const tertiaryContainer = Color(0xFF414141);
  static const onTertiaryContainer = Color(0xFFAFADAC);
  static const tertiaryFixed = Color(0xFFE5E2E1);
  static const tertiaryFixedDim = Color(0xFFC8C6C5);
  static const onTertiaryFixed = Color(0xFF1C1B1B);
  static const onTertiaryFixedVariant = Color(0xFF474746);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  /// `background`/`on-background`/`surface-variant` uit DESIGN_dark.md zijn bewust niet
  /// opgenomen: ze zijn byte-identiek aan `surface`/`on-surface`/`surface-container-highest`
  /// en de bijhorende ColorScheme-velden zijn gedeprecieerd sinds Flutter 3.18.
  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    surface: surface,
    onSurface: onSurface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    outline: outline,
    outlineVariant: outlineVariant,
    surfaceTint: surfaceTint,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    inversePrimary: inversePrimary,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    onPrimaryFixed: onPrimaryFixed,
    onPrimaryFixedVariant: onPrimaryFixedVariant,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    onSecondaryFixed: onSecondaryFixed,
    onSecondaryFixedVariant: onSecondaryFixedVariant,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
  );
}

/// Kleurtokens uit DESIGN_light.md ("Kinetic Performance: Aquatic Edition" —
/// het nieuwe, lichte thema). Zelfde structuur als [AppColorsDark]; zie
/// `app_theme.dart` voor waar de twee thema's inhoudelijk uiteenlopen
/// (niet zomaar dezelfde tokennamen 1-op-1 hergebruiken — zie de toelichting
/// daar over M3's tonale rolomkering tussen licht en donker).
abstract final class AppColorsLight {
  static const surface = Color(0xFFF7F9FC);
  static const surfaceDim = Color(0xFFD8DADD);
  static const surfaceBright = Color(0xFFF7F9FC);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F7);
  static const surfaceContainer = Color(0xFFECEEF1);
  static const surfaceContainerHigh = Color(0xFFE6E8EB);
  static const surfaceContainerHighest = Color(0xFFE0E3E6);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF434656);
  static const inverseSurface = Color(0xFF2D3133);
  static const inverseOnSurface = Color(0xFFEFF1F4);
  static const outline = Color(0xFF737688);
  static const outlineVariant = Color(0xFFC3C5D9);
  static const surfaceTint = Color(0xFF004DEA);

  static const primary = Color(0xFF0041C8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0055FF);
  static const onPrimaryContainer = Color(0xFFE3E6FF);
  static const inversePrimary = Color(0xFFB6C4FF);
  static const primaryFixed = Color(0xFFDCE1FF);
  static const primaryFixedDim = Color(0xFFB6C4FF);
  static const onPrimaryFixed = Color(0xFF001551);
  static const onPrimaryFixedVariant = Color(0xFF0039B3);

  static const secondary = Color(0xFF7C5800);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFEB700);
  static const onSecondaryContainer = Color(0xFF6B4B00);
  static const secondaryFixed = Color(0xFFFFDEA8);
  static const secondaryFixedDim = Color(0xFFFFBA20);
  static const onSecondaryFixed = Color(0xFF271900);
  static const onSecondaryFixedVariant = Color(0xFF5E4200);

  static const tertiary = Color(0xFF455063);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF5D687C);
  static const onTertiaryContainer = Color(0xFFDCE8FF);
  static const tertiaryFixed = Color(0xFFD8E3FA);
  static const tertiaryFixedDim = Color(0xFFBCC7DD);
  static const onTertiaryFixed = Color(0xFF111C2C);
  static const onTertiaryFixedVariant = Color(0xFF3C475A);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  /// `background`/`on-background`/`surface-variant` uit DESIGN_light.md zijn bewust niet
  /// opgenomen — zelfde reden als [AppColorsDark]: byte-identiek aan
  /// `surface`/`on-surface`/`surface-container-highest`, en die ColorScheme-velden zijn
  /// gedeprecieerd sinds Flutter 3.18.
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    surface: surface,
    onSurface: onSurface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    outline: outline,
    outlineVariant: outlineVariant,
    surfaceTint: surfaceTint,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    inversePrimary: inversePrimary,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    onPrimaryFixed: onPrimaryFixed,
    onPrimaryFixedVariant: onPrimaryFixedVariant,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    onSecondaryFixed: onSecondaryFixed,
    onSecondaryFixedVariant: onSecondaryFixedVariant,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
  );
}
