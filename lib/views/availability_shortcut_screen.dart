import 'package:flutter/material.dart';
import '../resources/components/primary_button.dart';
import '../resources/components/step_indicator.dart';
import '../routes/route_names.dart';
import '../utils/screen_unit_util.dart';

class AvailabilityShortcutScreen extends StatelessWidget {
  const AvailabilityShortcutScreen({super.key});

  void _openAvailability(BuildContext context) {
    Navigator.pushNamed(
      context,
      RouteNames.signUpStep3,
      arguments: {'isEditMode': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Availability'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(currentStep: 3, totalSteps: 4),
              SizedBox(height: ScreenUnitUtil.getSpacing(16)),
              Text(
                'Tap below to edit your availability hours and shift preferences.',
                style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(24)),
              PrimaryButton(
                text: 'Edit Availability',
                onPressed: () => _openAvailability(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
