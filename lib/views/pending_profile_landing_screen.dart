import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../resources/components/primary_button.dart';
import '../resources/components/step_indicator.dart';
import '../routes/route_names.dart';
import '../utils/screen_unit_util.dart';
import '../viewmodels/signup_viewmodel.dart';

class PendingProfileLandingScreen extends StatelessWidget {
  const PendingProfileLandingScreen({super.key});

  void _navigateToStep(BuildContext context, int step) {
    final route = {
      1: RouteNames.signUpStep1,
      2: RouteNames.signUpStep2,
      3: RouteNames.signUpStep3,
      4: RouteNames.signUpStep4,
    }[step];

    if (route == null) return;

    Navigator.pushNamed(
      context,
      route,
      arguments: {'isEditMode': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(currentStep: 1, totalSteps: 4),
              SizedBox(height: ScreenUnitUtil.getSpacing(16)),
              Text(
                'Your account is still pending for approval. You can still update your profile information.',
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(16),
                ),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(24)),
              PrimaryButton(
                text: 'Profile (Step 1)',
                onPressed: () => _navigateToStep(context, 1),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              PrimaryButton(
                text: 'Compliance (Step 2)',
                onPressed: () => _navigateToStep(context, 2),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              PrimaryButton(
                text: 'Availability (Step 3)',
                onPressed: () => _navigateToStep(context, 3),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              PrimaryButton(
                text: 'Bank Details (Step 4)',
                onPressed: () => _navigateToStep(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
