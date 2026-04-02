import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../models/registration_progress_model.dart';
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
        // Validate token first. If expired/invalid, force login.
        final isTokenValid = await _validateToken(token);
        if (!isTokenValid) {
          await AuthService.logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          }
          return;
        }

        // Validate current status from API (important for pending status)
        try {
          final response = await ApiClient.get(
            ApiEndpoints.getMe,
            token: token,
          );

          if (response.isSuccess) {
            // Get current status from API - check both root level and user object
            final userData = response.getField<Map<String, dynamic>>('user');
            final statusFromUser = userData?['status']?.toString();
            final statusFromRoot = response.getField<String>('status');
            final currentStatus = (statusFromUser ?? statusFromRoot ?? '').toLowerCase().trim();
            
            // If status is pending, clear token and navigate to login
            if (currentStatus == 'pending') {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(RouteNames.login);
              }
              return;
            }
            
            // If status is empty or null, also treat as pending (fallback)
            if (currentStatus.isEmpty) {
              debugPrint('[SplashScreen] Status is empty - treating as pending');
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(RouteNames.login);
              }
              return;
            }

            // Status is not pending - proceed with normal navigation
            RegistrationProgressModel? registrationProgress;
            final registrationProgressData = response.getField<Map<String, dynamic>>('registration_progress');
            if (registrationProgressData != null) {
              try {
                final parsedProgress = RegistrationProgressModel.fromJson(registrationProgressData);
                registrationProgress = parsedProgress;
                // Save to SharedPreferences for future use
                await AuthService.saveRegistrationProgress(parsedProgress);
              } catch (e) {
                debugPrint('[SplashScreen] Failed to parse registration progress: $e');
                registrationProgress = await AuthService.getRegistrationProgress();
              }
            } else {
              registrationProgress = await AuthService.getRegistrationProgress();
            }
            
            // Save current status (since it's not pending and not empty)
            await AuthService.saveUserStatus(currentStatus);
            
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
            } else {
              // All steps complete and status is not pending - navigate to home
              Navigator.of(context).pushReplacementNamed(RouteNames.home);
            }
          } else {
            // API call failed - fallback to cached data or login
            await _navigateWithCachedData();
          }
        } catch (e) {
          // API call failed - fallback to cached data or login
          debugPrint('[SplashScreen] Error validating status: $e');
          await _navigateWithCachedData();
        }
      } else {
        // User is not logged in, navigate to login
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await ApiClient.get(
        ApiEndpoints.validateToken,
        token: token,
      );
      if (!response.isSuccess) {
        debugPrint('[SplashScreen] Token validation API failed: ${response.message}');
        return false;
      }

      final valid = response.getField<bool>('valid');
      return valid == true;
    } catch (e) {
      debugPrint('[SplashScreen] Token validation error: $e');
      return false;
    }
  }

  Future<void> _navigateWithCachedData() async {
    final registrationProgress = await AuthService.getRegistrationProgress();
    final userStatus = await AuthService.getUserStatus();
    
    // If status is null but token exists, treat as pending and navigate to login
    if (userStatus == null) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
      return;
    }
    
    // Check if user needs to complete registration steps
    if (registrationProgress != null && registrationProgress.nextStep != null) {
      String route;
      switch (registrationProgress.nextStep) {
        case 2:
          route = RouteNames.signUpStep2;
          break;
        case 3:
          route = RouteNames.signUpStep3;
          break;
        case 4:
          route = RouteNames.declaration;
          break;
        default:
          route = RouteNames.signUpStep1;
      }
      Navigator.of(context).pushReplacementNamed(route, arguments: {'isEditMode': false});
    } else if (registrationProgress != null && 
               registrationProgress.allStepsComplete && 
               userStatus == 'pending') {
      // All steps complete but status is pending - navigate to login (should not happen with API validation)
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
    } else {
      // All steps complete and status is not pending - navigate to home
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
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
        Image.asset(
          'assets/icon/icon.png',
          width: ScreenUnitUtil.getFontSize(96),
          height: ScreenUnitUtil.getFontSize(96),
          fit: BoxFit.contain,
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(24)),
        // App Name
        Text(
          'TempSpot',
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
