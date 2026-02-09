import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Text input formatter for UK Sort Code (XX-XX-XX)
class SortCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    for (int i = 0; i < text.length && i < 6; i++) {
      if (i == 2 || i == 4) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Step 4: Bank Details Screen
class SignUpStep4Screen extends StatefulWidget {
  final bool isEditMode;

  const SignUpStep4Screen({super.key, this.isEditMode = false});

  @override
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  final _formKey = GlobalKey<FormState>();
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
          if (step4Model.sortCode != null && step4Model.sortCode!.isNotEmpty) {
            // Format sort code as XX-XX-XX for display
            final cleaned = step4Model.sortCode!.replaceAll('-', '');
            if (cleaned.length == 6) {
              _sortCodeController.text =
                  '${cleaned.substring(0, 2)}-${cleaned.substring(2, 4)}-${cleaned.substring(4, 6)}';
            } else {
              _sortCodeController.text = step4Model.sortCode!;
            }
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
                StepIndicator(
                  currentStep: 4,
                  totalSteps: viewModel.hasCustomFields ? 5 : 4,
                ),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUnitUtil.getSpacing(24),
                      vertical: ScreenUnitUtil.getSpacing(16),
                    ),
                    child: Form(
                      key: _formKey,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                          // Account Holder
                          TextFormField(
                            controller: _accountHolderController,
                            decoration: InputDecoration(
                              labelText: 'Account Holder Name *',
                              hintText: 'Enter account holder name',
                              prefixIcon: const Icon(Icons.person_outline),
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ScreenUnitUtil.getFontSize(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            onChanged: viewModel.updateStep4AccountHolder,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Account holder name is required';
                              }
                              if (value.length > 100) {
                                return 'Account holder name must be maximum 100 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'Account holder name cannot be only spaces';
                              }
                              // Check if it's a valid name (at least 2 characters, contains letters)
                              if (value.trim().length < 2) {
                                return 'Account holder name must be at least 2 characters';
                              }
                              if (!RegExp(
                                r"^[a-zA-Z\s\-']+$",
                              ).hasMatch(value.trim())) {
                                return 'Account holder name can only contain letters, spaces, hyphens, and apostrophes';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Bank Name
                          TextFormField(
                            controller: _bankNameController,
                            decoration: InputDecoration(
                              labelText: 'Bank Name *',
                              hintText: 'Enter bank name',
                              prefixIcon: const Icon(
                                Icons.account_balance_outlined,
                              ),
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ScreenUnitUtil.getFontSize(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            onChanged: viewModel.updateStep4BankName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bank name is required';
                              }
                              if (value.length > 100) {
                                return 'Bank name must be maximum 100 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'Bank name cannot be only spaces';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Bank Town
                          TextFormField(
                            controller: _bankTownController,
                            decoration: InputDecoration(
                              labelText: 'Bank Town *',
                              hintText: 'Enter bank town',
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                              ),
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ScreenUnitUtil.getFontSize(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            onChanged: viewModel.updateStep4BankTown,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bank town is required';
                              }
                              if (value.length > 100) {
                                return 'Bank town must be maximum 100 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'Bank town cannot be only spaces';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Account Number
                          TextFormField(
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Account Number *',
                              hintText: '8 digits (e.g., 12345678)',
                              prefixIcon: const Icon(Icons.numbers_outlined),
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ScreenUnitUtil.getFontSize(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            onChanged: viewModel.updateStep4AccountNumber,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Account number is required';
                              }
                              // UK account numbers are exactly 8 digits
                              if (value.length != 8) {
                                return 'UK account number must be exactly 8 digits';
                              }
                              if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                                return 'Account number must contain only digits';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Sort Code
                          TextFormField(
                            controller: _sortCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Sort Code *',
                              hintText: 'XX-XX-XX (e.g., 20-00-00)',
                              prefixIcon: const Icon(Icons.sort_outlined),
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ScreenUnitUtil.getFontSize(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              SortCodeFormatter(),
                              LengthLimitingTextInputFormatter(
                                8,
                              ), // XX-XX-XX format
                            ],
                            onChanged: (value) {
                              // Remove dashes for backend (store as 6 digits)
                              final cleaned = value.replaceAll('-', '');
                              viewModel.updateStep4SortCode(cleaned);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Sort code is required';
                              }
                              // Remove dashes for validation
                              final cleaned = value.replaceAll('-', '');
                              // UK sort codes are exactly 6 digits
                              if (cleaned.length != 6) {
                                return 'UK sort code must be exactly 6 digits (format: XX-XX-XX)';
                              }
                              if (!RegExp(r'^\d{6}$').hasMatch(cleaned)) {
                                return 'Sort code must contain only digits';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                          // Error Message
                          if (viewModel.errorMessage != null)
                            Container(
                              padding: EdgeInsets.all(
                                ScreenUnitUtil.getSpacing(12),
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                                  Expanded(
                                    child: Text(
                                      viewModel.errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
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
                                            arguments: {
                                              'isEditMode': widget.isEditMode,
                                            },
                                          );
                                        },
                                  child: Text('Back'),
                                ),
                              ),
                              SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                              Expanded(
                                child: PrimaryButton(
                                  text: widget.isEditMode ? 'Update' : 'Finish',
                                  isLoading:
                                      viewModel.isStepLoading ||
                                      viewModel.isLoadingProfile,
                                  onPressed: () => _handleSubmit(viewModel),
                                ),
                              ),
                            ],
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

  Future<void> _handleSubmit(SignUpViewModel viewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await viewModel.submitStep4();
    if (success && mounted) {
      if (widget.isEditMode) {
        // In edit mode, go back to profile edit screen
        Navigator.pop(context, true);
        ToastMessage.showSuccess('Bank details updated successfully!', context);
      } else {
        // Ensure custom fields are fetched before checking
        debugPrint(
          'Step 4: Fetching custom fields to check if Step 5 is needed...',
        );

        // Force fetch (don't use cache) to ensure we have latest data
        await viewModel.fetchCustomFields(forceRefresh: true);

        // Wait a bit to ensure state is updated
        await Future.delayed(const Duration(milliseconds: 100));

        // Check if custom fields exist - if yes, go to Step 5, otherwise complete registration
        debugPrint(
          'Step 4 Submit - hasCustomFields: ${viewModel.hasCustomFields}',
        );
        debugPrint(
          'Step 4 Submit - customFields count: ${viewModel.customFields.length}',
        );
        debugPrint(
          'Step 4 Submit - customFields: ${viewModel.customFields.map((f) => f.label).toList()}',
        );

        // Double check: if customFields list is not empty, navigate to Step 5
        if (viewModel.customFields.isNotEmpty) {
          debugPrint(
            'Step 4 Submit - Custom fields found! Navigating to Step 5...',
          );
          // Navigate to Step 5
          viewModel.goToStep(5);

          // Use pushReplacementNamed to replace Step 4 with Step 5
          Navigator.pushReplacementNamed(
            context,
            RouteNames.signUpStep5,
            arguments: {'isEditMode': false},
          );

          ToastMessage.showSuccess('Bank details saved!', context);
        } else {
          debugPrint(
            'Step 4 Submit - No custom fields found. Completing registration...',
          );
          // Registration complete - save token if we used registration token
          if (viewModel.registrationToken != null &&
              viewModel.registrationToken!.isNotEmpty) {
            await AuthService.saveToken(viewModel.registrationToken!);
          }

          // Navigate to home screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(RouteNames.home, (route) => false);
          ToastMessage.showSuccess(
            'Registration completed successfully!',
            context,
          );
        }
      }
    } else if (mounted && viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}
