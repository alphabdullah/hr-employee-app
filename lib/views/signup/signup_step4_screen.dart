import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Step 4: Bank Details Screen
class SignUpStep4Screen extends StatefulWidget {
  final bool isEditMode;
  
  const SignUpStep4Screen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankTownController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _sortCodeController = TextEditingController();

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _bankTownController.dispose();
    _accountNumberController.dispose();
    _sortCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set current step to 4 when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(4);
      viewModel.setEditMode(widget.isEditMode);
      
      // Load profile data to prefill forms
      viewModel.loadProfileData().then((_) {
        if (mounted) {
          // Pre-fill form fields with loaded data
          final step4Model = viewModel.step4Model;
          if (step4Model.accountHolder != null) {
            _accountHolderController.text = step4Model.accountHolder!;
          }
          if (step4Model.bankName != null) {
            _bankNameController.text = step4Model.bankName!;
          }
          if (step4Model.bankTown != null) {
            _bankTownController.text = step4Model.bankTown!;
          }
          if (step4Model.accountNumber != null) {
            _accountNumberController.text = step4Model.accountNumber!;
          }
          if (step4Model.sortCode != null) {
            _sortCodeController.text = step4Model.sortCode!;
          }
          setState(() {});
        }
      });
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
                StepIndicator(currentStep: 4, totalSteps: 4),
                
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
                    'Bank Details',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                  Text(
                    'Please provide your bank account information',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(14),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                  // Account Holder
                  TextFormField(
                    controller: _accountHolderController,
                    decoration: InputDecoration(
                      labelText: 'Account Holder Name',
                      hintText: 'Enter account holder name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: viewModel.updateStep4AccountHolder,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  // Bank Name
                  TextFormField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      hintText: 'Enter bank name',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                    onChanged: viewModel.updateStep4BankName,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  // Bank Town
                  TextFormField(
                    controller: _bankTownController,
                    decoration: InputDecoration(
                      labelText: 'Bank Town',
                      hintText: 'Enter bank town',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    onChanged: viewModel.updateStep4BankTown,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  // Account Number
                  TextFormField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      hintText: 'Enter account number',
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    onChanged: viewModel.updateStep4AccountNumber,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  // Sort Code
                  TextFormField(
                    controller: _sortCodeController,
                    decoration: InputDecoration(
                      labelText: 'Sort Code',
                      hintText: '20-00-00',
                      prefixIcon: Icon(Icons.sort_outlined),
                    ),
                    onChanged: viewModel.updateStep4SortCode,
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
                                        viewModel.goToStep(3);
                                        Navigator.pushReplacementNamed(
                                          context,
                                          RouteNames.signUpStep3,
                                          arguments: {'isEditMode': widget.isEditMode},
                                        );
                                      },
                                child: Text('Back'),
                              ),
                            ),
                            SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                            Expanded(
                              child: PrimaryButton(
                                text: widget.isEditMode ? 'Update' : 'Finish',
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
    final success = await viewModel.submitStep4();
    if (success && mounted) {
      if (widget.isEditMode) {
        // In edit mode, go back to profile edit screen
        Navigator.pop(context, true);
        ToastMessage.showSuccess('Bank details updated successfully!', context);
      } else {
        // In registration mode - clear all shared preferences before navigating to login
        // This ensures that when app restarts, user will be taken to login screen
        await AuthService.clearAll();
        
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
        ToastMessage.showSuccess('Registration completed successfully! Please login.', context);
      }
    } else if (mounted && viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}
