import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/presentation/display_feature_screen.dart';
import 'package:hs_coaching_app/features/profile/presentation/user_menu_button.dart';

const assetName = 'assets/logo.svg';
final Widget svgIcon = SvgPicture.asset(
  assetName,
  //colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
  semanticsLabel: 'App logo',
);

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
        final List<Widget> widgetOptions = <Widget>[
          // Home Tab Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 200, height: 200, child: svgIcon),
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${user.firstName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Screen Tab Content
          const DisplayFeaturesScreen(),
        ];

        final titles = ['Home', 'Screen control'];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_selectedIndex]),
            actions: const [UserMenuButton()],
          ),
          body: IndexedStack(index: _selectedIndex, children: widgetOptions),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_settings),
                label: 'Screen',
              ),
            ],
          ),
        );
      },
    );
  }
}
