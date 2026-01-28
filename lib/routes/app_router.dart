import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/login_screen.dart';
import '../views/signup_screen.dart';
import '../views/forgot_password_screen.dart';
import '../views/main_tab_screen.dart';
import '../views/job_detail_screen.dart';
import '../views/job_history_screen.dart';
import '../models/job_model.dart';
import 'route_names.dart';

/// App Router
/// Handles dynamic routing for the application
class AppRouter {
  /// Generate routes dynamically
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteNames.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const MainTabScreen(),
          settings: settings,
        );

      case RouteNames.jobDetail:
        if (args is JobModel) {
          return MaterialPageRoute(
            builder: (_) => JobDetailScreen(job: args),
            settings: settings,
          );
        }
        // Return error route if arguments are invalid
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Invalid job data'),
            ),
          ),
          settings: settings,
        );

      case RouteNames.jobHistory:
        return MaterialPageRoute(
          builder: (_) => const JobHistoryScreen(),
          settings: settings,
        );

      // Unknown route
      default:
        // If route is '/', redirect to splash
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
            settings: settings,
          );
        }
        // Unknown route
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route ${settings.name} not found',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  /// Get initial route
  static String get initialRoute => RouteNames.splash;

  /// Push named route
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Push named route and remove until
  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Push named route and replace
  static Future<T?> pushReplacementNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Object? result,
  }) {
    return Navigator.pushReplacementNamed<T, Object?>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Pop route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}

