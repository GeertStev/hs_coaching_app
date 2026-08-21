import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/presentation/lazy_indexed_stack.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';
import 'package:hs_coaching_app/features/display/features/game/presentation/game_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/display_image_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/display_sketch_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/display_team_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/display_text_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/chrono/chrono_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/tabata/presentation/tabata_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/training/presentation/training_control_screen.dart';

/// One nav-rail destination bound to its control screen. Deriving both the
/// [NavigationRail]'s destinations and the [LazyIndexedStack]'s children from
/// this single list (instead of two separately-maintained parallel lists)
/// means they can't drift out of index-sync with each other.
class _DisplayFeatureNavItem {
  const _DisplayFeatureNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;
}

class DisplayFeaturesScreen extends ConsumerStatefulWidget {
  const DisplayFeaturesScreen({super.key});

  @override
  ConsumerState<DisplayFeaturesScreen> createState() =>
      _DisplayFeaturesScreenState();
}

class _DisplayFeaturesScreenState extends ConsumerState<DisplayFeaturesScreen> {
  int? _selectedIndex;

  static const List<_DisplayFeatureNavItem> _navItems = [
    _DisplayFeatureNavItem(
      icon: Icons.draw_outlined,
      selectedIcon: Icons.draw,
      label: 'Sketch',
      screen: SketchControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.image_outlined,
      selectedIcon: Icons.image,
      label: 'Image',
      screen: ImageControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.text_fields_outlined,
      selectedIcon: Icons.text_fields,
      label: 'Text',
      screen: TextControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
      label: 'Chrono',
      screen: ChronoControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.hourglass_empty_rounded,
      selectedIcon: Icons.hourglass_top_rounded,
      label: 'Tabata',
      screen: TabataControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
      label: 'Training',
      screen: TrainingControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      label: 'Team',
      screen: TeamControlScreen(),
    ),
    _DisplayFeatureNavItem(
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
      label: 'Game',
      screen: GameControlScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // NavigationRail scrollt zelf niet; bij te weinig hoogte (landscape)
        // maakt deze wrapper hem scrollbaar, met minHeight zodat hij anders
        // gewoon de volledige hoogte vult.
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: _selectedIndex == null
              ? _navigationRailWelcomeScreen()
              : LazyIndexedStack(
                  index: _selectedIndex!,
                  children: [for (final item in _navItems) item.screen],
                ),
        ),
      ],
    );
  }

  Widget _navigationRailWelcomeScreen() {
    return Builder(
      builder: (context) {
        final metrics = Theme.of(context).appMetrics;
        final colorScheme = Theme.of(context).colorScheme;

        return Center(
          child: Padding(
            padding: EdgeInsets.all(metrics.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 64,
                  color: colorScheme.onSurface, //.withValues(alpha: 0.5),
                ),
                SizedBox(height: metrics.spacingMd),
                Text(
                  'Welcome at screen control',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: metrics.spacingSm),
                Text(
                  'Choose a function in the left navigation bar to get started.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
