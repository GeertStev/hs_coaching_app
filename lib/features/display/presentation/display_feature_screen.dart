import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/game/presentation/game_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/image/presentation/display_image_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/display_sketch_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/team/presentation/display_team_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/text/presentation/display_text_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/timer/presentation/timer_control_screen.dart';
import 'package:hs_coaching_app/features/display/features/chrono/chrono_control_screen.dart';

class DisplayFeaturesScreen extends ConsumerStatefulWidget {
  const DisplayFeaturesScreen({super.key});

  @override
  ConsumerState<DisplayFeaturesScreen> createState() =>
      _DisplayFeaturesScreenState();
}

class _DisplayFeaturesScreenState extends ConsumerState<DisplayFeaturesScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _featureWidgets = [
    SketchControlScreen(),
    ImageControlScreen(),
    TextControlScreen(),
    ChronoControlScreen(),
    TimerControlScreen(),
    TeamControlScreen(),
    GameControlScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.draw_outlined),
              selectedIcon: Icon(Icons.draw),
              label: Text('Sketch'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.image_outlined),
              selectedIcon: Icon(Icons.image),
              label: Text('Image'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.text_fields_outlined),
              selectedIcon: Icon(Icons.text_fields),
              label: Text('Text'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: Text('Chrono'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.hourglass_top_outlined),
              selectedIcon: Icon(Icons.hourglass_top),
              label: Text('Timer'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: Text('Team'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon: Icon(Icons.sports_esports),
              label: Text('Game'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: _featureWidgets),
        ),
      ],
    );
  }
}
