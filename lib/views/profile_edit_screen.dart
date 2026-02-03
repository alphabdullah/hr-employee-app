import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../routes/route_names.dart';
import '../resources/components/primary_button.dart';

/// Profile Edit Screen - Allows editing all 4 registration steps
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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
              SizedBox(height: ScreenUnitUtil.getSpacing(24)),
              Text(
                'Pick a section to update',
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(20),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(34)),
              _buildPrimaryStepButton(context, 'Profile', Icons.person_outline, 1),
              SizedBox(height: ScreenUnitUtil.getSpacing(20)),
              _buildPrimaryStepButton(context, 'Compliance', Icons.verified_user_outlined, 2),
              SizedBox(height: ScreenUnitUtil.getSpacing(20)),
              _buildPrimaryStepButton(context, 'Availability', Icons.calendar_today_outlined, 3),
              SizedBox(height: ScreenUnitUtil.getSpacing(20)),
              _buildPrimaryStepButton(context, 'Bank Details', Icons.account_balance_outlined, 4),
              SizedBox(height: ScreenUnitUtil.getSpacing(34)),
              Text(
                'Tap any button to go directly into that step for editing.',
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryStepButton(BuildContext context, String label, IconData icon, int step) {
    return Center(
      child: SizedBox(
        width: ScreenUnitUtil.getWidth(300),
        child: PrimaryButton(
          text: label,
          icon: icon,
          onPressed: () {
            _navigateToStep(context, step);
          },
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
        // For step 4, redirect to declaration screen first
        route = RouteNames.declaration;
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
