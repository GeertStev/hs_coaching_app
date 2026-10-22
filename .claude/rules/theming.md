---
paths:
  - "lib/**/presentation/**"
  - "lib/core/theme/**"
  - "lib/main.dart"
---

# Theming (`lib/core/theme/`)

Source of truth: `DESIGN_dark.md` and `DESIGN_light.md` ("Kinetic Performance System"). Same type
scale and spacing/radius grid, different color tokens. `AppTheme.dark()`/`.light()` build the
`ThemeData`; `MainApp` picks one via `themeModeControllerProvider` (persisted user choice through
`sharedPreferencesProvider`, toggle in `ProfileScreen`'s "Weergave" section).

## Which token, from where
- `headlineLg/Md/Sm`, `bodyLg/Md` → `Theme.of(context).textTheme.headlineLarge` etc.
- `timerDisplay`, `dataPoint`, `labelCaps`, `headlineLgMobile` → `Theme.of(context).appTypography.<name>`.
- Spacing/radius → always `Theme.of(context).appMetrics.spacingMd` / `.radiusDefault` etc., never a
  bare number, even one that matches a token.
- Colors → `colorScheme` roles or `AppColorsDark`/`AppColorsLight`, never `Colors.*`.
- Gotcha: the extension getters are `appTypography`/`appMetrics`. `ThemeData.typography` already
  exists, so a getter named `typography` is silently shadowed. Don't rename them.

## Component theming
Shape/elevation/border for a widget kind belongs in `AppTheme`, not on the instance. Only override
for a genuine per-instance state (e.g. `ContentItemCard`'s `isCurrent` border, `colorScheme.primary`).
Don't set a local `border:`/`fillColor:` on a `TextField`; it overrides the theme.

- `cardTheme`: dark = `radiusDefault`, 1px 10%-white inner border, soft shadow. Light = white
  `surfaceContainerLowest` fill + subtle `outlineVariant` border (the lightest container reads as raised).
- `inputDecorationTheme`: recessed fill + 2px focus underline. Dark = `surfaceContainerLowest` fill,
  `secondary` (Energy Yellow) underline. Light = `surfaceContainerHighest` fill, `primary` (Athletic
  Blue) underline.
- `chipTheme`: `StadiumBorder()` in both.
- When porting a per-theme choice, check that the token's **semantic role** points the same way in
  both palettes. `surfaceContainerLowest` is darkest in dark but white in light; `secondary` is vivid
  yellow only in dark.
- `surfaceTint` is intentionally left on.

## Palette rules
- No green. "Success" → `colorScheme.primary`; neutral/disabled → `onSurfaceVariant`;
  destructive → `error`.
- Fonts are bundled assets (not `google_fonts`). Only these weights exist: Anybody 600/700/800,
  Hanken Grotesk 400/500, JetBrains Mono 600/700. Any other weight is silently faux-synthesized.
