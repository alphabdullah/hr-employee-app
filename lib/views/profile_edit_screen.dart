import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/components/step_indicator.dart';
import '../routes/route_names.dart';

/// Profile Edit Screen - Allows editing all 4 registration steps
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    // Load profile data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.setEditMode(true);
      viewModel.loadProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<SignUpViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoadingProfile) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                // Step Indicator
                StepIndicator(currentStep: _currentStep, totalSteps: 4),
                
                // Step Navigation Buttons
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUnitUtil.getSpacing(24),
                    vertical: ScreenUnitUtil.getSpacing(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStepButton(context, 1, 'Profile', Icons.person_outline),
                      _buildStepButton(context, 2, 'Compliance', Icons.verified_user_outlined),
                      _buildStepButton(context, 3, 'Availability', Icons.calendar_today_outlined),
                      _buildStepButton(context, 4, 'Bank', Icons.account_balance_outlined),
                    ],
                  ),
                ),
                
                Divider(),
                
                // Content Area - Show instructions
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: ScreenUnitUtil.getFontSize(64),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                          Text(
                            'Select a step to edit',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(20),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                          Text(
                            'Tap on any step above to edit your profile information',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(14),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepButton(BuildContext context, int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentStep = step;
          });
          _navigateToStep(context, step);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUnitUtil.getSpacing(8),
            horizontal: ScreenUnitUtil.getSpacing(4),
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: ScreenUnitUtil.getFontSize(20),
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(4)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(10),
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStep(BuildContext context, int step) {
    String route;
    switch (step) {
      case 1:
        route = RouteNames.signUpStep1;
        break;
      case 2:
        route = RouteNames.signUpStep2;
        break;
      case 3:
        route = RouteNames.signUpStep3;
        break;
      case 4:
        route = RouteNames.signUpStep4;
        break;
      default:
        route = RouteNames.signUpStep1;
    }

    // Navigate to step screen in edit mode
    Navigator.pushNamed(
      context,
      route,
      arguments: {'isEditMode': true},
    ).then((result) {
      // If update was successful, reload profile data
      if (result == true && mounted) {
        context.read<SignUpViewModel>().loadProfileData();
      }
    });
  }
}
