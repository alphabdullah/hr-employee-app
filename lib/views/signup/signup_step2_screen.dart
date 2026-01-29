import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

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
            _drivingLicenseDateController.text = step2Model.drivingLicenseDate!;
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
                const StepIndicator(currentStep: 2, totalSteps: 4),
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
                                labelText: 'Driving license number',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              onChanged: viewModel.updateStep2DrivingLicenseNo,
                              validator: (value) {
                                if (_isDriver && (value == null || value.isEmpty)) {
                                  return 'License number is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                            TextFormField(
                              controller: _drivingLicenseDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Driving license date',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1970),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  final formatted = DateFormat('yyyy-MM-dd').format(picked);
                                  _drivingLicenseDateController.text = formatted;
                                  viewModel.updateStep2DrivingLicenseDate(formatted);
                                }
                              },
                              validator: (value) {
                                if (_isDriver && (value == null || value.isEmpty)) {
                                  return 'Driving license date is required';
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
                                labelText: 'Criminal record type',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'spent', child: Text('Spent')),
                                DropdownMenuItem(value: 'unspent', child: Text('Unspent')),
                              ],
                              onChanged: viewModel.updateStep2CriminalRecordType,
                              validator: (value) {
                                if (_criminalRecord && value == null) {
                                  return 'Select record type';
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
                              labelText: 'Other licence details',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            onChanged: viewModel.updateStep2OtherCardText,
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
                                labelText: 'Adjustments',
                                prefixIcon: Icon(Icons.accessible_outlined),
                              ),
                              onChanged: viewModel.updateStep2DisabilityAdjustmentsText,
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                            TextFormField(
                              controller: _disabilityDetailsTextController,
                              decoration: InputDecoration(
                                labelText: 'Disability details',
                                prefixIcon: Icon(Icons.notes_outlined),
                              ),
                              onChanged: viewModel.updateStep2DisabilityDetailsText,
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
        }
      } else if (mounted && viewModel.errorMessage != null) {
        ToastMessage.showError(viewModel.errorMessage!, context);
      }
    }
  }
}
