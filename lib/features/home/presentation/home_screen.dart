import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/display/presentation/display_feature_screen.dart';

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
    final appUserAsync = ref.watch(appUserProvider);

    // We define the widget options inside build to access the user data.
    final List<Widget> widgetOptions = <Widget>[
      // Home Tab Content
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_cricket_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            appUserAsync.when(
              data: (user) => Text(
                // Use the user's first name if available, otherwise a generic welcome.
                'Welcome, ${user?.firstName ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Welcome!'),
            ),
            const Text(
              'Image to be designed',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      // Screen Tab Content
      const DisplayFeaturesScreen(),
    ];

    final titles = ['Home', 'Screen control'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
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
  }
}
