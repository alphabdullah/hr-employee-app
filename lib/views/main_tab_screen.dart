import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/job_viewmodel.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../routes/route_names.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
// import 'availability_shortcut_screen.dart';
import 'settings_screen.dart';

/// Main tab screen shown after login with 4 tabs: Home, Explore, Chat, Settings
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _tokenValidationTimer;
  Timer? _jobsPollingTimer;
  bool _isHandlingInvalidToken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Start polling for notifications when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationViewModel = context.read<NotificationViewModel>();
      notificationViewModel.loadNotifications();
      notificationViewModel.startPolling();
      _startTokenValidationPolling();
      _startJobsPolling();
    });
  }

  @override
  void dispose() {
    _stopTokenValidationPolling();
    _stopJobsPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final notificationViewModel = context.read<NotificationViewModel>();
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh notifications
      debugPrint('[MainTabScreen] App resumed - refreshing notifications');
      notificationViewModel.loadNotifications(forceRefresh: true);
      notificationViewModel.startPolling();
      _startTokenValidationPolling();
      _startJobsPolling();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background - stop polling to save battery
      debugPrint('[MainTabScreen] App paused - stopping notification polling');
      notificationViewModel.stopPolling();
      _stopTokenValidationPolling();
      _stopJobsPolling();
    }
  }

  void _startTokenValidationPolling() {
    _tokenValidationTimer?.cancel();
    _validateTokenOnce();
    _tokenValidationTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _validateTokenOnce(),
    );
  }

  void _stopTokenValidationPolling() {
    _tokenValidationTimer?.cancel();
    _tokenValidationTimer = null;
  }

  void _startJobsPolling() {
    _jobsPollingTimer?.cancel();
    _pollJobsOnce();
    _jobsPollingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _pollJobsOnce(),
    );
  }

  void _stopJobsPolling() {
    _jobsPollingTimer?.cancel();
    _jobsPollingTimer = null;
  }

  Future<void> _pollJobsOnce() async {
    if (!mounted || _isHandlingInvalidToken) return;
    try {
      await context.read<JobViewModel>().loadMyJobs(
            forceRefresh: true,
            silent: true,
          );
      await context.read<JobViewModel>().fetchAttendance(silent: true);
    } catch (_) {
      // Ignore transient polling errors
    }
  }

  Future<void> _validateTokenOnce() async {
    if (!mounted || _isHandlingInvalidToken) return;

    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return;

    final response = await ApiClient.get(
      ApiEndpoints.validateToken,
      token: token,
    );
    final isValid = response.isSuccess && response.getField<bool>('valid') == true;

    if (!isValid && mounted && !_isHandlingInvalidToken) {
      _isHandlingInvalidToken = true;
      _stopTokenValidationPolling();
      _stopJobsPolling();
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
      }
    }
  }

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
            ChatScreen(key: ValueKey('chat_$themeKey')),
            // AvailabilityShortcutScreen(key: ValueKey('availability_$themeKey')),
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
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.calendar_today_outlined),
          //   activeIcon: Icon(Icons.calendar_today),
          //   label: 'Availability',
          // ),
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

