import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_metrics.dart';
import 'app_typography.dart';

/// Bouwt de "Kinetic Performance System" `ThemeData` uit DESIGN_dark.md
/// (`dark()`) en DESIGN_light.md (`light()`). Zie `theme_mode_controller.dart`
/// voor hoe/wanneer tussen de twee gewisseld wordt (persisted user-toggle, geen
/// hardcoded keuze meer in `main.dart`).
abstract final class AppTheme {
  static ThemeData dark() {
    final typography = AppTypography.kinetic(onSurface: AppColorsDark.onSurface);
    final metrics = AppMetrics.kinetic();
    const colorScheme = AppColorsDark.colorScheme;

    final textTheme = Typography.material2021(colorScheme: colorScheme).white
        .apply(fontFamily: 'Hanken Grotesk')
        .copyWith(
          headlineLarge: typography.headlineLg,
          headlineMedium: typography.headlineMd,
          headlineSmall: typography.headlineSm,
          bodyLarge: typography.bodyLg,
          bodyMedium: typography.bodyMd,
        );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsDark.surface,
      textTheme: textTheme,
      // Geen M3 "scrolled under"-tint: AppBar behoudt zijn kleur bij scrollen.
      appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
      // DESIGN_dark.md "Elevation & Depth": kaarten krijgen een subtiele 1px witte
      // binnenrand (10% opacity) en een zachte ambient shadow. `colorScheme.surfaceTint`
      // (al gezet in AppColorsDark) blijft de M3-tint doen — bewust niet overschreven,
      // DESIGN_dark.md geeft er zelf een expliciete `surface-tint`-token voor.
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.radiusDefault),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      // DESIGN_dark.md "Input Fields": donkerder dan de kaartachtergrond, actieve
      // velden krijgen een 2px Energy Yellow onderrand. Hier gezet als globaal
      // thema in plaats van als per-TextFormField decoration, zodat elk
      // invoerveld in de app dit gratis krijgt.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
      ),
      // DESIGN_dark.md "Shapes": "Tags/Chips: Fully pill-shaped ... to differentiate
      // them from functional cards." Covers Chip/FilterChip/InputChip alike.
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      extensions: [typography, metrics],
    );
  }

  static ThemeData light() {
    final typography = AppTypography.kinetic(onSurface: AppColorsLight.onSurface);
    final metrics = AppMetrics.kinetic();
    const colorScheme = AppColorsLight.colorScheme;

    final textTheme = Typography.material2021(colorScheme: colorScheme).black
        .apply(fontFamily: 'Hanken Grotesk')
        .copyWith(
          headlineLarge: typography.headlineLg,
          headlineMedium: typography.headlineMd,
          headlineSmall: typography.headlineSm,
          bodyLarge: typography.bodyLg,
          bodyMedium: typography.bodyMd,
        );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsLight.surface,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
      // DESIGN_light.md "Elevation & Depth": "active containers (like cards) use
      // white surfaces to pop against the off-white background" — the opposite
      // tonal direction from dark's inner-border trick, since in light mode the
      // *lightest* container (white) is what reads as "raised", not the darkest
      // one. Border is a subtle light-grey/outline stroke rather than dark's
      // translucent-white inner border, per "Performance Cards": "white surface
      // colors with subtle light-grey borders."
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        color: colorScheme.surfaceContainerLowest,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.radiusDefault),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      // DESIGN_light.md "Input Fields": "a subtle light-grey fill ... a 2px
      // Athletic Blue bottom border" on focus — unlike dark's Energy Yellow
      // focus border. The recessed fill can't reuse dark's
      // `surfaceContainerLowest` token by name: in the light palette that's
      // white (#FFFFFF, the *card* tone — see above), so the "slightly darker,
      // recessed" fill instead comes from `surfaceContainerHighest`, the
      // darkest grey in the light container scale.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      // DESIGN_light.md "Shapes": same pill-shaped tags/chips as dark.
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      extensions: [typography, metrics],
    );
  }
}

/// Ergonomische toegang tot de custom tokens: `Theme.of(context).appTypography.timerDisplay`
/// / `Theme.of(context).appMetrics.spacingMd` in plaats van `.extension<AppTypography>()!`.
/// Niet `typography`/`metrics`: `ThemeData.typography` (Flutter's eigen font-schaal
/// klasse) bestaat al en zou een extension-getter met dezelfde naam stilzwijgend
/// overschaduwen in plaats van een compile-fout te geven.
extension AppThemeDataX on ThemeData {
  AppTypography get appTypography => extension<AppTypography>()!;
  AppMetrics get appMetrics => extension<AppMetrics>()!;
}
