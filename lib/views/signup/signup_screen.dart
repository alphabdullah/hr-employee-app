import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../routes/route_names.dart';

/// Main SignUp Screen - Redirects to Step 1
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to Step 1 immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, RouteNames.signUpStep1);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
