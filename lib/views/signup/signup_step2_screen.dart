import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Text input formatter for Date (DD/MM/YYYY)
class DateFormatter extends TextInputFormatter {
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
    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += text[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Step 2: Compliance Information Screen
class SignUpStep2Screen extends StatefulWidget {
  final bool isEditMode;
  
  const SignUpStep2Screen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _drivingLicenseNoController = TextEditingController();
  final _drivingLicenseDateController = TextEditingController();
  final _otherCardTextController = TextEditingController();
  final _disabilityAdjustmentsTextController = TextEditingController();
  final _disabilityDetailsTextController = TextEditingController();

  bool _isDriver = false;
  bool _ownCar = false;
  bool _criminalRecord = false;
  bool _cscs = false;
  bool _sia = false;
  bool _mhe = false;
  bool _cis = false;
  bool _firstAid = false;
  bool _registeredDisabled = false;

  @override
  void dispose() {
    _drivingLicenseNoController.dispose();
    _drivingLicenseDateController.dispose();
    _otherCardTextController.dispose();
    _disabilityAdjustmentsTextController.dispose();
    _disabilityDetailsTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(2);
      viewModel.setEditMode(widget.isEditMode);
      
      // Load profile data to prefill forms
      viewModel.loadProfileData().then((_) {
        if (mounted) {
          final step2Model = viewModel.step2Model;
          _isDriver = step2Model.isDriver ?? false;
          _ownCar = step2Model.ownCar ?? false;
          _criminalRecord = step2Model.criminalRecord ?? false;
          _cscs = step2Model.cscs ?? false;
          _sia = step2Model.sia ?? false;
          _mhe = step2Model.mhe ?? false;
          _cis = step2Model.cis ?? false;
          _firstAid = step2Model.firstAid ?? false;
          _registeredDisabled = step2Model.registeredDisabled ?? false;

          if (step2Model.drivingLicenseNo != null) {
            _drivingLicenseNoController.text = step2Model.drivingLicenseNo!;
          }
          if (step2Model.drivingLicenseDate != null) {
            // Convert YYYY-MM-DD to DD/MM/YYYY for display
            try {
              final dateParts = step2Model.drivingLicenseDate!.split('-');
              if (dateParts.length == 3) {
                _drivingLicenseDateController.text =
                    '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
              } else {
                _drivingLicenseDateController.text = step2Model.drivingLicenseDate!;
              }
            } catch (e) {
              _drivingLicenseDateController.text = step2Model.drivingLicenseDate!;
            }
          }
          if (step2Model.otherCardText != null) {
            _otherCardTextController.text = step2Model.otherCardText!;
          }
          if (step2Model.disabilityAdjustmentsText != null) {
            _disabilityAdjustmentsTextController.text = step2Model.disabilityAdjustmentsText!;
          }
          if (step2Model.disabilityDetailsText != null) {
            _disabilityDetailsTextController.text = step2Model.disabilityDetailsText!;
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
          'Compliance Details',
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
                StepIndicator(
                  currentStep: 2,
                  totalSteps: viewModel.hasCustomFields ? 6 : 5,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUnitUtil.getSpacing(24),
                      vertical: ScreenUnitUtil.getSpacing(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Please provide the compliance information below',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(14),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          SwitchListTile(
                            title: const Text('Are you a driver?'),
                            value: _isDriver,
                            onChanged: (value) {
                              setState(() => _isDriver = value);
                              viewModel.updateStep2IsDriver(value);
                            },
                          ),
                          if (_isDriver) ...[
                            TextFormField(
                              controller: _drivingLicenseNoController,
                              decoration: InputDecoration(
                                labelText: 'Driving License Number *',
                                prefixIcon: const Icon(Icons.badge_outlined),
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
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onChanged: viewModel.updateStep2DrivingLicenseNo,
                              validator: (value) {
                                if (_isDriver) {
                                  if (value == null || value.isEmpty) {
                                    return 'Driving license number is required';
                                  }
                                  if (value.length > 100) {
                                    return 'Driving license number must be maximum 100 characters';
                                  }
                                  if (value.trim().isEmpty) {
                                    return 'Driving license number cannot be only spaces';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                            TextFormField(
                              controller: _drivingLicenseDateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Driving License Date (DD/MM/YYYY) *',
                                hintText: 'DD/MM/YYYY or tap calendar icon',
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _drivingLicenseDateController.text.isNotEmpty
                                          ? (() {
                                              try {
                                                final parts = _drivingLicenseDateController.text.split('/');
                                                if (parts.length == 3) {
                                                  return DateTime(
                                                    int.parse(parts[2]),
                                                    int.parse(parts[1]),
                                                    int.parse(parts[0]),
                                                  );
                                                }
                                              } catch (e) {
                                                // Invalid date
                                              }
                                              return DateTime.now();
                                            })()
                                          : DateTime.now(),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      // Format as DD/MM/YYYY for display
                                      _drivingLicenseDateController.text =
                                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                      // Convert to YYYY-MM-DD for backend
                                      final dateStr =
                                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                      viewModel.updateStep2DrivingLicenseDate(dateStr);
                                    }
                                  },
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
                              inputFormatters: [
                                DateFormatter(),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onChanged: (value) {
                                // Convert DD/MM/YYYY to YYYY-MM-DD for backend
                                if (value.length == 10) {
                                  final parts = value.split('/');
                                  if (parts.length == 3) {
                                    try {
                                      final day = int.parse(parts[0]);
                                      final month = int.parse(parts[1]);
                                      final year = int.parse(parts[2]);
                                      if (day >= 1 &&
                                          day <= 31 &&
                                          month >= 1 &&
                                          month <= 12 &&
                                          year >= 1970 &&
                                          year <= DateTime.now().year) {
                                        final dateStr =
                                            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                                        viewModel.updateStep2DrivingLicenseDate(dateStr);
                                      }
                                    } catch (e) {
                                      // Invalid date format
                                    }
                                  }
                                } else {
                                  viewModel.updateStep2DrivingLicenseDate(null);
                                }
                              },
                              validator: (value) {
                                if (_isDriver) {
                                  if (value == null || value.isEmpty) {
                                    return 'Driving license date is required';
                                  }
                                  if (value.length != 10) {
                                    return 'Please enter a complete date (DD/MM/YYYY)';
                                  }
                                  final parts = value.split('/');
                                  if (parts.length != 3) {
                                    return 'Invalid date format. Use DD/MM/YYYY';
                                  }
                                  try {
                                    final day = int.parse(parts[0]);
                                    final month = int.parse(parts[1]);
                                    final year = int.parse(parts[2]);

                                    if (day < 1 || day > 31)
                                      return 'Day must be between 1 and 31';
                                    if (month < 1 || month > 12)
                                      return 'Month must be between 1 and 12';
                                    if (year < 1970 || year > DateTime.now().year)
                                      return 'Year must be between 1970 and ${DateTime.now().year}';

                                    final date = DateTime(year, month, day);
                                    if (date.year != year ||
                                        date.month != month ||
                                        date.day != day)
                                      return 'Invalid date';

                                    if (date.isAfter(DateTime.now())) {
                                      return 'Driving license date cannot be in the future';
                                    }
                                  } catch (e) {
                                    return 'Invalid date format';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                          ],

                          SwitchListTile(
                            title: const Text('Do you own a car?'),
                            value: _ownCar,
                            onChanged: (value) {
                              setState(() => _ownCar = value);
                              viewModel.updateStep2OwnCar(value);
                            },
                          ),

                          SwitchListTile(
                            title: const Text('Criminal record'),
                            value: _criminalRecord,
                            onChanged: (value) {
                              setState(() => _criminalRecord = value);
                              viewModel.updateStep2CriminalRecord(value);
                            },
                          ),
                          if (_criminalRecord)
                            DropdownButtonFormField<String>(
                              value: viewModel.step2Model.criminalRecordType,
                              decoration: InputDecoration(
                                labelText: 'Criminal Record Type *',
                                prefixIcon: const Icon(Icons.lock_outline),
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
                              items: const [
                                DropdownMenuItem(value: 'spent', child: Text('Spent')),
                                DropdownMenuItem(value: 'unspent', child: Text('Unspent')),
                              ],
                              onChanged: viewModel.updateStep2CriminalRecordType,
                              validator: (value) {
                                if (_criminalRecord) {
                                  if (value == null || value.isEmpty) {
                                    return 'Criminal record type is required';
                                  }
                                  if (value != 'spent' && value != 'unspent') {
                                    return 'Criminal record type must be "spent" or "unspent"';
                                  }
                                }
                                return null;
                              },
                            ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          Text(
                            'Do you have any of the cards above or another licence?',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                          Wrap(
                            spacing: ScreenUnitUtil.getSpacing(6),
                            children: [
                              FilterChip(
                                label: const Text('CSCS'),
                                selected: _cscs,
                                onSelected: (value) {
                                  setState(() => _cscs = value);
                                  viewModel.updateStep2Cscs(value);
                                },
                              ),
                              FilterChip(
                                label: const Text('SIA'),
                                selected: _sia,
                                onSelected: (value) {
                                  setState(() => _sia = value);
                                  viewModel.updateStep2Sia(value);
                                },
                              ),
                              FilterChip(
                                label: const Text('MHE'),
                                selected: _mhe,
                                onSelected: (value) {
                                  setState(() => _mhe = value);
                                  viewModel.updateStep2Mhe(value);
                                },
                              ),
                              FilterChip(
                                label: const Text('CIS'),
                                selected: _cis,
                                onSelected: (value) {
                                  setState(() => _cis = value);
                                  viewModel.updateStep2Cis(value);
                                },
                              ),
                              FilterChip(
                                label: const Text('First Aid'),
                                selected: _firstAid,
                                onSelected: (value) {
                                  setState(() => _firstAid = value);
                                  viewModel.updateStep2FirstAid(value);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                          // Text(
                          //   'Do you have any of the cards above or another licence?',
                          //   style: TextStyle(
                          //     fontSize: ScreenUnitUtil.getFontSize(14),
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                          TextFormField(
                            controller: _otherCardTextController,
                            decoration: InputDecoration(
                              labelText: 'Other Licence Details',
                              prefixIcon: const Icon(Icons.description_outlined),
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
                              LengthLimitingTextInputFormatter(255),
                            ],
                            onChanged: viewModel.updateStep2OtherCardText,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length > 255) {
                                  return 'Other licence details must be maximum 255 characters';
                                }
                                if (value.trim().isEmpty) {
                                  return 'Other licence details cannot be only spaces';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          SwitchListTile(
                            title: const Text('Registered disabled'),
                            value: _registeredDisabled,
                            onChanged: (value) {
                              setState(() => _registeredDisabled = value);
                              viewModel.updateStep2RegisteredDisabled(value);
                            },
                          ),
                          if (_registeredDisabled) ...[
                            TextFormField(
                              controller: _disabilityAdjustmentsTextController,
                              decoration: InputDecoration(
                                labelText: 'Adjustments *',
                                prefixIcon: const Icon(Icons.accessible_outlined),
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
                              maxLines: 3,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(500),
                              ],
                              onChanged: viewModel.updateStep2DisabilityAdjustmentsText,
                              validator: (value) {
                                if (_registeredDisabled) {
                                  if (value == null || value.isEmpty) {
                                    return 'Disability adjustments are required';
                                  }
                                  if (value.length > 500) {
                                    return 'Disability adjustments must be maximum 500 characters';
                                  }
                                  if (value.trim().isEmpty) {
                                    return 'Disability adjustments cannot be only spaces';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                            TextFormField(
                              controller: _disabilityDetailsTextController,
                              decoration: InputDecoration(
                                labelText: 'Disability Details *',
                                prefixIcon: const Icon(Icons.notes_outlined),
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
                              maxLines: 3,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(500),
                              ],
                              onChanged: viewModel.updateStep2DisabilityDetailsText,
                              validator: (value) {
                                if (_registeredDisabled) {
                                  if (value == null || value.isEmpty) {
                                    return 'Disability details are required';
                                  }
                                  if (value.length > 500) {
                                    return 'Disability details must be maximum 500 characters';
                                  }
                                  if (value.trim().isEmpty) {
                                    return 'Disability details cannot be only spaces';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: viewModel.isStepLoading
                                      ? null
                                      : () {
                                          viewModel.goToStep(1);
                                          Navigator.pushReplacementNamed(
                                            context,
                                            RouteNames.signUpStep1,
                                            arguments: {'isEditMode': widget.isEditMode},
                                          );
                                        },
                                  child: const Text('Back'),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit(SignUpViewModel viewModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewModel.submitStep2();
      if (success && mounted) {
        if (widget.isEditMode) {
          Navigator.pop(context, true);
          ToastMessage.showSuccess('Compliance information updated successfully!', context);
        } else {
          viewModel.goToStep(3);
          Navigator.pushReplacementNamed(
            context,
            RouteNames.signUpStep3,
            arguments: {'isEditMode': false},
          );
          ToastMessage.showSuccess('Compliance information saved successfully!', context);
        }
      } else if (mounted && viewModel.errorMessage != null) {
        ToastMessage.showError(viewModel.errorMessage!, context);
      }
    }
  }
}
