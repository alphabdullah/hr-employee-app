import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

/// Main tab screen shown after login with 4 tabs: Home, Explore, Chat, Settings
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          // Use theme mode in key to force rebuild when theme changes
          // This ensures screens update their colors immediately when theme changes
          final themeKey = settingsViewModel.themeMode.toString();
          
          final pages = [
            HomeScreen(key: ValueKey('home_$themeKey')),
            ExploreScreen(key: ValueKey('explore_$themeKey')),
            ChatScreen(key: ValueKey('chat_$themeKey')),
            SettingsScreen(key: ValueKey('settings_$themeKey')),
          ];
          
          return IndexedStack(
            index: _currentIndex,
            children: pages,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkPrimary // Bright blue for dark theme
            : AppColors.secondary, // Muted teal for light theme
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        selectedLabelStyle: TextStyle(
          fontSize: ScreenUnitUtil.getFontSize(12),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ScreenUnitUtil.getFontSize(12),
          fontWeight: FontWeight.w400,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

