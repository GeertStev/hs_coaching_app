---
name: 'Kinetic Performance: Aquatic Edition'
colors:
  surface: '#f7f9fc'
  surface-dim: '#d8dadd'
  surface-bright: '#f7f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f7'
  surface-container: '#eceef1'
  surface-container-high: '#e6e8eb'
  surface-container-highest: '#e0e3e6'
  on-surface: '#191c1e'
  on-surface-variant: '#434656'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f4'
  outline: '#737688'
  outline-variant: '#c3c5d9'
  surface-tint: '#004dea'
  primary: '#0041c8'
  on-primary: '#ffffff'
  primary-container: '#0055ff'
  on-primary-container: '#e3e6ff'
  inverse-primary: '#b6c4ff'
  secondary: '#7c5800'
  on-secondary: '#ffffff'
  secondary-container: '#feb700'
  on-secondary-container: '#6b4b00'
  tertiary: '#455063'
  on-tertiary: '#ffffff'
  tertiary-container: '#5d687c'
  on-tertiary-container: '#dce8ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#001551'
  on-primary-fixed-variant: '#0039b3'
  secondary-fixed: '#ffdea8'
  secondary-fixed-dim: '#ffba20'
  on-secondary-fixed: '#271900'
  on-secondary-fixed-variant: '#5e4200'
  tertiary-fixed: '#d8e3fa'
  tertiary-fixed-dim: '#bcc7dd'
  on-tertiary-fixed: '#111c2c'
  on-tertiary-fixed-variant: '#3c475a'
  background: '#f7f9fc'
  on-background: '#191c1e'
  surface-variant: '#e0e3e6'
typography:
  timer-display:
    fontFamily: Anybody
    fontSize: 84px
    fontWeight: '800'
    lineHeight: 84px
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Anybody
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Anybody
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 27px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 12px
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 12px
  margin-page: 16px
  touch-target: 44px
---

## Brand & Style

This design system is engineered for the high-stakes, high-humidity environment of Underwater Hockey management. The brand personality is **professional, aquatic, and utilitarian**, shifting to a **Light Mode** theme. This transition ensures maximum clarity in bright pool-side settings and outdoor aquatic centers while maintaining a premium, high-performance feel for personal stat tracking.

The design style is **Corporate / Modern** with a focus on **Tactile Minimalism**. It utilizes clean white surfaces and "Athletic Blue" accents to evoke the precision of a professional stopwatch and the clarity of shallow water. The UI must feel grounded and reliable—tools for coaches managing chaos and players analyzing split-second performance. The aesthetic avoids unnecessary ornamentation, favoring structural integrity and functional clarity.

## Colors

The palette is anchored by **Athletic Blue**, a high-saturation hue that represents the water and professional stability. **Energy Yellow** is used sparingly for critical performance alerts, active countdowns, and "Rest" states to ensure they pierce through the interface.

The system utilizes a **Light Mode** foundation to provide a crisp, high-contrast experience in aquatic environments.
- **Background:** Clean neutrals (#F7F9FC) provide a stable, airy base.
- **Surfaces:** Layered light greys and whites distinguish between different functional containers like management areas and data zones.
- **Accents:** Athletic Blue is the primary driver for "Work" states and primary actions.
- **Contrast:** High-contrast text (Deep charcoal on light backgrounds) ensures readability when the screen is viewed at a distance or at an angle under bright overhead lights.

## Typography

The typography system balances impact with utilitarian precision. **Anybody** is the display powerhouse, used for aggressive sizing on timers and headlines to ensure visibility across the pool deck. Its variable nature allows it to feel athletic and urgent.

**Hanken Grotesk** serves as the primary engine for team management, line-ups, and stats, providing a clean and contemporary professional feel. **JetBrains Mono** is reserved strictly for technical data—times, repetitions, and coordinates—where character consistency is vital to prevent visual "shimmer" during active updates. 

All technical labels and metadata tags should be rendered in uppercase to separate system-level information from user-defined content.

## Layout & Spacing

The layout is built on a **Fluid Grid** with a strict 4px rhythmic unit. It is optimized for mobile-first poolside controls where precision interaction is required under physical duress.

- **Vertical Rhythm:** Elements are separated by 12px (gutters) for sibling items and 24px for distinct logical sections.
- **Nesting Logic:** For team line-ups or grouped intervals, child elements are indented by 16px to create a clear structural hierarchy.
- **Pool-side Accessibility:** All interactive elements maintain a minimum 44px touch target. Padding within cards is generous (16px) to allow for clear separation between data points, preventing accidental taps.
- **Breakpoints:** On desktop/tablet, the management dashboard transitions to a multi-column view while the "Active Timer" remains centralized and dominant.

## Elevation & Depth

This design system uses **Tonal Layers** and **Soft Shadows** rather than heavy glows to maintain a clean, organized feel in its light configuration.

- **Surface Levels:** Depth is communicated by shifting through the light grey scale. The background is the lightest layer, while active containers (like cards) use white surfaces to pop against the off-white background.
- **Layering:** Elements "stacked" on top of the base layer use subtle tonal shifts and thin borders to define their boundaries without adding visual clutter.
- **Active State:** When a coach is dragging a player in a line-up or an interval is active, the card gains a soft ambient shadow and a 2px Athletic Blue border.
- **Recessed Areas:** Data entry fields and "inactive" player slots use a slightly darker, recessed tonal fill to indicate they are containers waiting for input.

## Shapes

The shape language is **Rounded**, striking a balance between the aggressive, sharp-edged nature of competitive sports and the fluid environment of the pool.

- **Main Cards & Containers:** Use a 0.5rem (8px) radius for a sturdy, architectural feel.
- **Action Buttons:** Primary actions like "Start Match" or "Confirm Line-up" use a 1rem (16px) radius to feel tactile and distinct.
- **Status Pills:** Player roles, substitutions, and round numbers use fully pill-shaped containers to differentiate them from functional, square-edged data cards.
- **Interactive Knurling:** Drag handles on player cards use a textured pattern of three vertical lines to suggest physical grip.

## Components

### Performance Cards
Used for both drills and player stats. In the "light" theme, these use white surface colors with subtle light-grey borders. Data points (using JetBrains Mono) are high-contrast for easy scanning.

### Team Management Lists
Lists feature a "rail" on the left side to show grouping. Player names are set in Hanken Grotesk (Body-LG), while their position or status is shown in a JetBrains Mono pill.

### Action Buttons
- **Primary:** Athletic Blue background with White text. Bold and high-contrast.
- **Secondary:** Ghost style with an Athletic Blue outline.
- **Rest/Wait:** Energy Yellow background with black text—only used for "In-between" states.

### Pool-side Controls
Specialized large-scale buttons for "Stop," "Goal," and "Foul." These use the `timer-display` font style scaled down to 48px to ensure they are the most prominent elements on the screen.

### Input Fields
Numeric inputs use a subtle light-grey fill. When focused, they transition to a 2px Athletic Blue bottom border with the numeric value highlighted for quick overwriting.

### Status Indicators
Small, high-visibility circular pips indicate player presence or device connectivity, using a palette of Success Green, Athletic Blue, and Error Red.