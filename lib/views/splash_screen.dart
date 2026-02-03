import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/route_names.dart';
import '../utils/screen_unit_util.dart';

/// Splash Screen
/// Checks authentication status and navigates to appropriate screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a bit for splash screen to show (optional, for better UX)
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    final token = await AuthService.getToken();

    // Navigate based on authentication status
    if (mounted) {
      if (isLoggedIn && token != null && token.isNotEmpty) {
        // User is logged in - check registration progress and user status
        final registrationProgress = await AuthService.getRegistrationProgress();
        final userStatus = await AuthService.getUserStatus();
        
        // Check if user needs to complete registration steps
        if (registrationProgress != null && registrationProgress.nextStep != null) {
          // User needs to complete registration steps
          String route;
          switch (registrationProgress.nextStep) {
            case 2:
              route = RouteNames.signUpStep2;
              break;
            case 3:
              route = RouteNames.signUpStep3;
              break;
            case 4:
              // If nextStep is 4, user needs to complete declarations first
              route = RouteNames.declaration;
              break;
            default:
              route = RouteNames.signUpStep1;
          }
          Navigator.of(context).pushReplacementNamed(route, arguments: {'isEditMode': false});
        } else if (registrationProgress != null && 
                   registrationProgress.allStepsComplete && 
                   userStatus == 'pending') {
          // All steps complete but status is pending - show pending dashboard
          Navigator.of(context).pushReplacementNamed(RouteNames.pendingDashboard);
        } else {
          // All steps complete and status is not pending - navigate to home
          Navigator.of(context).pushReplacementNamed(RouteNames.home);
        }
      } else {
        // User is not logged in, navigate to login
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Icon(
              Icons.work_outline,
              size: ScreenUnitUtil.getFontSize(80),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(24)),
            // App Name
            Text(
              'HR Employee App',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(24),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(32)),
            // Loading Indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
