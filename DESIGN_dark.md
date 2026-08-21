---
name: Kinetic Performance System
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0c0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#c4c5d6'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#8e909f'
  outline-variant: '#444653'
  surface-tint: '#b7c4ff'
  primary: '#b7c4ff'
  on-primary: '#002583'
  primary-container: '#0033aa'
  on-primary-container: '#94a9ff'
  inverse-primary: '#3354c8'
  secondary: '#feba2f'
  on-secondary: '#422c00'
  secondary-container: '#d99a00'
  on-secondary-container: '#503700'
  tertiary: '#c8c6c5'
  on-tertiary: '#313030'
  tertiary-container: '#414141'
  on-tertiary-container: '#afadac'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b7c4ff'
  on-primary-fixed: '#001453'
  on-primary-fixed-variant: '#0f3ab0'
  secondary-fixed: '#ffdeaa'
  secondary-fixed-dim: '#feba2f'
  on-secondary-fixed: '#271900'
  on-secondary-fixed-variant: '#5f4100'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1c1b1b'
  on-tertiary-fixed-variant: '#474746'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  timer-display:
    fontFamily: Anybody
    fontSize: 84px
    fontWeight: '800'
    lineHeight: '1'
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Anybody
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Anybody
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-sm:
    fontFamily: Anybody
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.2'
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.5'
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.1em
  data-point:
    fontFamily: JetBrains Mono
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1'
  headline-lg-mobile:
    fontFamily: Anybody
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 16px
  gutter: 12px
  card-padding: 16px
---

## Brand & Style

The design system is engineered for high-intensity athletic environments. It prioritizes **functional energy** and **utilitarian precision**, ensuring that users can process complex interval data at a glance while in a state of physical exertion. 

The aesthetic sits at the intersection of **Corporate Modern** and **Tactile Minimalism**. It uses a dark, high-contrast foundation to make active timers "pop" and minimize eye strain in varied lighting. Surfaces feel physical and layered, using subtle depth to communicate the hierarchy of nested workout groups and individual exercises. The mood is disciplined, motivating, and professional—evoking the feeling of high-end gym equipment and precision stopwatches.

## Colors

The palette is anchored by **Athletic Blue**, used for primary actions and "Work" states, providing a sense of stability and strength. **Energy Yellow** acts as a high-visibility accent for "Rest" states, countdowns, and critical warnings, ensuring they pierce through the dark interface.

The "Modern Dark" theme uses a deep obsidian background to maximize the contrast of the secondary accent. Tonal variants of the surface color differentiate nested intervals:
- **Level 1 (Main Background):** Deepest black.
- **Level 2 (Exercise Cards):** Dark charcoal with subtle sheen.
- **Level 3 (Nested Groups):** Slightly lighter grey-blue tint to indicate containment.

## Typography

Typography is the primary driver of the user experience. **Anybody** provides a variable, high-impact weight for headers and active timers, allowing for aggressive sizing that remains legible even when the device is vibrating or at arm's length.

**Hanken Grotesk** handles functional body text for setup and descriptions, offering a clean, contemporary feel. **JetBrains Mono** is utilized for all "technical" data points (reps, seconds, step adjustments) to ensure character widths are consistent and values don't "jump" when timers are active. 

All primary labels are set in uppercase monospaced type to distinguish them clearly from user-generated exercise names.

## Layout & Spacing

The layout utilizes a **fluid-width vertical stack** optimized for mobile interaction. It follows a strict 4px grid system to maintain rhythmic alignment.

### Structure
- **Vertical Rhythm:** 12px gutters between sibling cards. 24px spacing between distinct workout phases.
- **Nesting Logic:** When exercises are grouped, the parent container introduces a 16px left-side indentation and a tinted background stroke to visually "hook" the items together.
- **Drag & Drop:** Safe areas for drag handles are a minimum of 44x44px to accommodate sweaty or moving fingers.
- **Margins:** A 16px safe-area margin is maintained on all screen edges to prevent UI elements from hugging the bezel.

## Elevation & Depth

This design system uses **Tonal Layers** combined with **Tactile Outlines** to communicate hierarchy.

1.  **Base Layer:** The darkest surface, representing the "floor" of the app.
2.  **Card Layer:** Elevated by a subtle 1px inner border (opacity 10% white) and a soft, large-radius ambient shadow to make them feel like physical tiles.
3.  **Active/Dragging State:** When a card is picked up, it increases in scale (1.02x), gains a high-intensity Energy Yellow border, and casts a deeper, more diffused shadow to simulate physical lift.
4.  **Nested Groups:** Use a "well" effect—slightly darker than the background with a recessed inner shadow—to show that exercise cards are "inside" a set.

## Shapes

The shape language is **Rounded**, balancing the aggressive typography with approachable, modern UI elements.

- **Main Cards:** 0.5rem (8px) radius for a sturdy, professional look.
- **Control Buttons:** 1rem (16px) radius for "Play/Pause" to make them feel distinct and tactile.
- **Drag Handles:** 3 vertical lines or a knurled pattern texture to imply grip.
- **Tags/Chips:** Fully pill-shaped for "Rounds" or "Step" indicators to differentiate them from functional cards.

## Components

### Exercise Cards
Cards must display four key quadrants: Title/Rounds, Work Duration, Rest Duration, and Step Adjustment. The drag handle is always positioned on the far left. Values should be editable via tap-to-input or "scrubbing" the value left/right.

### Workout Groups (Containers)
A specialized card that can wrap multiple Exercise Cards. It features a header showing total group repeats (e.g., "5x") and a group rest period at the bottom. The visual "rail" on the left connects all items in the group.

### Action Buttons
- **Primary (Start):** Athletic Blue background with white text.
- **Secondary (Add):** Ghost button with a dashed Energy Yellow border.
- **Destructive (Clear):** Low-contrast grey, turning Red only on long-press.

### Progress Indicators
A thin, high-contrast Energy Yellow bar at the top of the active card that fills horizontally as the current interval elapses.

### Input Fields
Darker than the card background, using monospaced type for numeric entry. Active fields use a 2px Energy Yellow bottom-border.