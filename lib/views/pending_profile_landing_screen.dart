import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../resources/components/primary_button.dart';
import '../resources/components/step_indicator.dart';
import '../routes/route_names.dart';
import '../utils/screen_unit_util.dart';
import '../viewmodels/signup_viewmodel.dart';

class PendingProfileLandingScreen extends StatefulWidget {
  const PendingProfileLandingScreen({super.key});

  @override
  State<PendingProfileLandingScreen> createState() => _PendingProfileLandingScreenState();
}

class _PendingProfileLandingScreenState extends State<PendingProfileLandingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch custom fields when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpViewModel>().fetchCustomFields();
    });
  }

  void _navigateToStep(BuildContext context, int step) {
    final route = {
      1: RouteNames.signUpStep1,
      2: RouteNames.signUpStep2,
      3: RouteNames.signUpStep3,
      4: RouteNames.signUpStep4,
      5: RouteNames.signUpStep5,
      6: RouteNames.signUpStep6,
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
        child: Consumer<SignUpViewModel>(
          builder: (context, viewModel, child) {
            // Determine total steps based on custom fields
            final totalSteps = viewModel.hasCustomFields ? 6 : 5;
            
            return Padding(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepIndicator(currentStep: 1, totalSteps: totalSteps),
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
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  PrimaryButton(
                    text: 'Tax Details (Step 5)',
                    onPressed: () => _navigateToStep(context, 5),
                  ),
                  // Show Step 6 button if custom fields exist
                  if (viewModel.hasCustomFields && viewModel.customFields.isNotEmpty) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    PrimaryButton(
                      text: 'Additional Information (Step 6)',
                      onPressed: () => _navigateToStep(context, 6),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
