import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Step 3: Availability Information Screen
class SignUpStep3Screen extends StatefulWidget {
  final bool isEditMode;
  
  const SignUpStep3Screen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final List<String> _daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    // Set current step to 3 when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(3);
      viewModel.setEditMode(widget.isEditMode);
      
      // Load profile data to prefill forms
      viewModel.loadProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
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
            return Column(
              children: [
                // Step Indicator
                StepIndicator(
                  currentStep: 3,
                  totalSteps: viewModel.hasCustomFields ? 6 : 5,
                ),
                
                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUnitUtil.getSpacing(24),
                      vertical: ScreenUnitUtil.getSpacing(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Text(
                    'Availability Information',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                  Text(
                    'Select your available days for day and night shifts',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(14),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                  // Day Days
                  Text(
                    'Day Shifts',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  Wrap(
                    spacing: ScreenUnitUtil.getSpacing(8),
                    runSpacing: ScreenUnitUtil.getSpacing(8),
                    children: _daysOfWeek.map((day) {
                      final isSelected = viewModel.step3Model.dayDays.contains(day);
                      return FilterChip(
                        label: Text(day.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => viewModel.toggleStep3DayDay(day),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                  // Night Days
                  Text(
                    'Night Shifts',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  Wrap(
                    spacing: ScreenUnitUtil.getSpacing(8),
                    runSpacing: ScreenUnitUtil.getSpacing(8),
                    children: _daysOfWeek.map((day) {
                      final isSelected = viewModel.step3Model.nightDays.contains(day);
                      return FilterChip(
                        label: Text(day.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => viewModel.toggleStep3NightDay(day),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                  // Error Message
                  if (viewModel.errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                        // Navigation Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: viewModel.isStepLoading
                                    ? null
                                    : () {
                                        viewModel.goToStep(2);
                                        Navigator.pushReplacementNamed(
                                          context,
                                          RouteNames.signUpStep2,
                                          arguments: {'isEditMode': widget.isEditMode},
                                        );
                                      },
                                child: Text('Back'),
                              ),
                            ),
                            SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                            Expanded(
                              child: PrimaryButton(
                                text: widget.isEditMode ? 'Update' : 'Next',
                                isLoading: viewModel.isStepLoading || viewModel.isLoadingProfile,
                                onPressed: () => _handleSubmit(viewModel),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _handleSubmit(SignUpViewModel viewModel) async {
    final success = await viewModel.submitStep3();
    if (success && mounted) {
      if (widget.isEditMode) {
        // In edit mode, go back to profile edit screen
        Navigator.pop(context, true);
        ToastMessage.showSuccess('Availability updated successfully!', context);
      } else {
        // In registration mode, go to declaration screen
        Navigator.pushReplacementNamed(
          context,
          RouteNames.declaration,
          arguments: {'isEditMode': false},
        );
        ToastMessage.showSuccess('Availability saved successfully!', context);
      }
    } else if (mounted && viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}
