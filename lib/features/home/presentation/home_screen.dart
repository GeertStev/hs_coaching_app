import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';

import 'package:flutter_svg/svg.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/presentation/display_feature_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/user_menu_button.dart';

const assetName = 'assets/logo.svg';
Widget appLogo(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return SvgPicture.asset(
    assetName,
    colorFilter: ColorFilter.mode(
      isDark ? Colors.white : Colors.black,
      BlendMode.srcIn,
    ),
    semanticsLabel: 'App logo',
  );
}

class HomeWelcomeTab extends StatelessWidget {
  const HomeWelcomeTab({super.key, required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const UpNext(),
          //const SizedBox(height: 20),
          SizedBox(width: 200, height: 200, child: appLogo(context)),
          //const SizedBox(height: 20),
          Text(
            'Welcome, $firstName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Voorvertoning van de eerstvolgende geplande sessie. Er bestaat nog geen
/// sessie/planning-feature in de app (zie CLAUDE.md), dus deze widget neemt
/// voorlopig standaardwaarden als constructor-defaults; zodra die feature er
/// is, wordt dit een `ConsumerWidget` die zijn data uit een echte provider haalt.
class UpNext extends StatelessWidget {
  const UpNext({
    super.key,
    this.title = 'Zwembad De Kimpel',
    this.startTime = '21:00',
    this.endTime = '22:00',
    this.attendeeCount = 12,
    this.onDetailsTap,
  });

  final String title;
  final String startTime;
  final String endTime;
  final int attendeeCount;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typography = theme.appTypography;
    final metrics = theme.appMetrics;
    final cardRadius = BorderRadius.circular(metrics.radiusDefault);

    return SizedBox(
      width: 360,
      child: Card(
        child: InkWell(
          borderRadius: cardRadius,
          onTap: onDetailsTap,
          child: Padding(
            padding: EdgeInsets.all(metrics.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEXT SESSION',
                  style: typography.labelCaps.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: metrics.spacingXs),
                Text(title, style: typography.headlineSm),
                SizedBox(height: metrics.spacingSm),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: metrics.spacingXs),
                    Text(
                      '$startTime - $endTime',
                      style: typography.bodyMd.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: metrics.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AttendeeStack(
                      count: attendeeCount,
                      colorScheme: colorScheme,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: typography.bodyMd.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: metrics.spacingXs / 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlappende avatar-stack met een "+N"-badge voor de deelnemers die niet
/// meer passen. Toont losse kleurvlakken (geen `UserAvatar`/initialen): er is
/// hier nog geen echte deelnemerslijst om initialen uit te halen (zie de
/// class-doc hierboven).
class _AttendeeStack extends StatelessWidget {
  const _AttendeeStack({required this.count, required this.colorScheme});

  final int count;
  final ColorScheme colorScheme;

  static const _diameter = 32.0;
  static const _overlap = 22.0;
  static const _maxShown = 3;

  @override
  Widget build(BuildContext context) {
    final shown = count < _maxShown ? count : _maxShown;
    final overflow = count - shown;
    final tones = [
      colorScheme.outlineVariant,
      colorScheme.surfaceContainerHighest,
      colorScheme.tertiaryContainer,
    ];

    Widget dot(Color color, {Widget? child}) => Container(
      width: _diameter,
      height: _diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: colorScheme.surfaceContainerLowest, width: 2),
      ),
      child: child,
    );

    return SizedBox(
      height: _diameter,
      width: _diameter + (shown - 1 + (overflow > 0 ? 1 : 0)) * _overlap,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(left: i * _overlap, child: dot(tones[i % tones.length])),
          if (overflow > 0)
            Positioned(
              left: shown * _overlap,
              child: dot(
                colorScheme.primary,
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeTab {
  const _HomeTab({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final Widget content;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch de appUserProvider (dit zorgt ervoor dat de widget herbouwt als de data binnen is)
    final appUserAsync = ref.watch(appUserProvider);

    // We vangen de verschillende statussen op met .when
    return appUserAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Er is iets fout gegaan: $err'))),
      data: (user) {
        // Mocht de user écht niet bestaan in de database:
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Gebruikersprofiel niet gevonden.')),
          );
        }

        // Definieer de tabbladen nu we zeker weten dat 'user' geladen is
        final tabs = <_HomeTab>[
          _HomeTab(
            title: 'Home',
            icon: Icons.home,
            content: HomeWelcomeTab(firstName: user.firstName),
          ),
          _HomeTab(
            title: 'Player',
            icon: Icons.person,
            content: HomeWelcomeTab(firstName: user.firstName),
          ),
          _HomeTab(
            title: 'Team',
            icon: Icons.group,
            content: HomeWelcomeTab(firstName: user.firstName),
          ),
          const _HomeTab(
            title: 'Screen control',
            icon: Icons.video_settings,
            content: DisplayFeaturesScreen(),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(tabs[_selectedIndex].title),
            actions: const [UserMenuButton()],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [for (final tab in tabs) tab.content],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              for (final tab in tabs)
                BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.title),
            ],
          ),
        );
      },
    );
  }
}
