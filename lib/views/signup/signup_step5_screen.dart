import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/signup_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Step 5: P46 Tax Details Screen
class SignUpStep5Screen extends StatefulWidget {
  final bool isEditMode;

  const SignUpStep5Screen({super.key, this.isEditMode = false});

  @override
  State<SignUpStep5Screen> createState() => _SignUpStep5ScreenState();
}

class _SignUpStep5ScreenState extends State<SignUpStep5Screen> {
  final _formKey = GlobalKey<FormState>();

  final _niController = TextEditingController();
  final _titleController = TextEditingController();
  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _houseFlatController = TextEditingController();
  final _restOfAddressController = TextEditingController();

  String? _selectedGender;
  String? _selectedOptionAbc;
  bool _optionD = false;
  bool _confirmCorrect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(5);
      viewModel.setEditMode(widget.isEditMode);

      // Ensure profile data is loaded so we can pre-fill common fields
      await viewModel.loadProfileData();
      _prefillFromModels(viewModel);
    });
  }

  void _prefillFromModels(SignUpViewModel viewModel) {
    final step1 = viewModel.step1Model;
    final p46 = viewModel.step5P46Model;

    // Read existing values from the models (P46 model has priority, then step 1)
    final natInsuranceNo = (p46.natInsuranceNo ?? step1.natInsuranceNo) ?? '';
    final title = p46.title ?? '';
    final surname = p46.surname ?? step1.surname;
    final firstName = p46.firstName ?? step1.name;
    final dob = (p46.dob ?? step1.dob ?? '');
    final postcode = (p46.postcode ?? step1.postCode) ?? '';
    final houseFlatNumber = p46.houseFlatNumber ?? '';
    final restOfAddress = (p46.restOfAddress ?? step1.address) ?? '';
    final gender = p46.gender ?? step1.gender;
    final optionAbc = p46.optionAbc;
    final optionD = p46.optionD ?? false;

    // Populate controllers / local state
    _niController.text = natInsuranceNo;
    _titleController.text = title;
    _surnameController.text = surname;
    _firstNameController.text = firstName;
    _dobController.text = dob.toString();
    _postcodeController.text = postcode;
    _houseFlatController.text = houseFlatNumber;
    _restOfAddressController.text = restOfAddress;
    _selectedGender = gender;
    _selectedOptionAbc = optionAbc;
    _optionD = optionD;

    // Seed the P46 model so that all current values (including prefilled ones)
    // are present in the view model before any user edits. This ensures that
    // submitStep5P46() / updateStep5P46() send a complete body even if the
    // user does not change some of the prefilled fields.
    viewModel
      ..updateStep5P46NatInsuranceNo(
        natInsuranceNo.trim().isEmpty ? null : natInsuranceNo.trim(),
      )
      ..updateStep5P46Title(title.trim().isEmpty ? null : title.trim())
      ..updateStep5P46Surname(surname.trim().isEmpty ? null : surname.trim())
      ..updateStep5P46FirstName(firstName.trim().isEmpty ? null : firstName.trim())
      ..updateStep5P46Dob(dob.isEmpty ? null : dob)
      ..updateStep5P46Postcode(
        postcode.trim().isEmpty ? null : postcode.trim(),
      )
      ..updateStep5P46HouseFlatNumber(
        houseFlatNumber.trim().isEmpty ? null : houseFlatNumber.trim(),
      )
      ..updateStep5P46RestOfAddress(
        restOfAddress.trim().isEmpty ? null : restOfAddress.trim(),
      )
      ..updateStep5P46Gender(gender)
      ..updateStep5P46OptionAbc(optionAbc)
      ..updateStep5P46OptionD(optionD);

    setState(() {});
  }

  @override
  void dispose() {
    _niController.dispose();
    _titleController.dispose();
    _surnameController.dispose();
    _firstNameController.dispose();
    _dobController.dispose();
    _postcodeController.dispose();
    _houseFlatController.dispose();
    _restOfAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickDob(SignUpViewModel viewModel) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      _dobController.text = formatted;

      viewModel.updateStep5P46Dob(formatted);
      viewModel.updateStep1Dob(formatted);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tax Details (P46)',
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
            return SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StepIndicator(
                      currentStep: 5,
                      totalSteps: viewModel.hasCustomFields ? 6 : 5,
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                    Text(
                      'HM Revenue & Customs',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      'P46: Employee without a Form P45',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    Text(
                      'Section one\n\n'
                      'To be completed by the employee\n\n'
                      'Please complete section one and then hand back the form to your present employer. '
                      'If you later receive a form P45 from your previous employer, please hand it to your present employer.',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                    Text(
                      'Your present circumstances',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      'Please read all the following statements carefully and tick the one that applies to you.',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    Text(
                      'Your details',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // National Insurance number
                    TextFormField(
                      controller: _niController,
                      decoration: const InputDecoration(
                        labelText: 'National Insurance number *',
                        hintText: 'AB 12 34 56 C',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'National Insurance number is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        viewModel.updateStep5P46NatInsuranceNo(value.trim());
                        viewModel.updateStep1NatInsuranceNo(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Mr, Mrs, Miss, Ms or other',
                      ),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      onChanged: (value) {
                        viewModel.updateStep5P46Title(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // Surname
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Surname or family name *',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Surname is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        viewModel.updateStep5P46Surname(value.trim());
                        viewModel.updateStep1Surname(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // First name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First or given name(s) *',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        viewModel.updateStep5P46FirstName(value.trim());
                        viewModel.updateStep1Name(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // Date of birth
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of birth *',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Date of birth is required';
                        }
                        return null;
                      },
                      onTap: () => _pickDob(viewModel),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // Gender
                    Text(
                      'Are you male or female? *',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: _selectedGender,
                            onChanged: (val) {
                              setState(() => _selectedGender = val);
                              viewModel.updateStep5P46Gender(val);
                              viewModel.updateStep1Gender(val);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'Female',
                            groupValue: _selectedGender,
                            onChanged: (val) {
                              setState(() => _selectedGender = val);
                              viewModel.updateStep5P46Gender(val);
                              viewModel.updateStep1Gender(val);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_selectedGender == null)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUnitUtil.getSpacing(12),
                          bottom: ScreenUnitUtil.getSpacing(8),
                        ),
                        child: Text(
                          'Please select gender',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: ScreenUnitUtil.getFontSize(12),
                          ),
                        ),
                      ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    // Address
                    TextFormField(
                      controller: _postcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postcode *',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Postcode is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        viewModel.updateStep5P46Postcode(value.trim());
                        viewModel.updateStep1PostCode(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    TextFormField(
                      controller: _houseFlatController,
                      decoration: const InputDecoration(
                        labelText: 'House or flat number',
                      ),
                      onChanged: (value) {
                        viewModel.updateStep5P46HouseFlatNumber(value.trim());
                      },
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),

                    TextFormField(
                      controller: _restOfAddressController,
                      decoration: const InputDecoration(
                        labelText:
                            'Rest of address including house name or flat name',
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        viewModel.updateStep5P46RestOfAddress(value.trim());
                        viewModel.updateStep1Address(value.trim());
                      },
                    ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                    // Present circumstances
                    Text(
                      'Your present circumstances *',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    _buildOptionAbcTile(
                      code: 'A',
                      description:
                          'This is my first job since 6 April and I have not been receiving taxable Jobseeker’s Allowance or taxable Incapacity Benefit or a state or occupational pension.',
                    ),
                    _buildOptionAbcTile(
                      code: 'B',
                      description:
                          'This is now my only job, but since last 6 April I have had another job, or have received taxable Jobseeker’s Allowance or taxable Incapacity Benefit. I do not receive a state or occupational pension.',
                    ),
                    _buildOptionAbcTile(
                      code: 'C',
                      description:
                          'I have another job or receive a state or occupational pension.',
                    ),
                    if (_selectedOptionAbc == null)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUnitUtil.getSpacing(12),
                          bottom: ScreenUnitUtil.getSpacing(8),
                        ),
                        child: Text(
                          'Please select one option (A, B or C)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: ScreenUnitUtil.getFontSize(12),
                          ),
                        ),
                      ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                    // Student loans
                    Text(
                      'Student Loans',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    Text(
                      'If you left a course of Higher Education before last 6 April and received your first Student Loan instalment on or after 1 September 1998 and you have not fully repaid your student loan, tick box D.',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      '(If you are required to repay your Student Loan through your bank or building society account do not tick box D.)',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    CheckboxListTile(
                      value: _optionD,
                      onChanged: (val) {
                        setState(() => _optionD = val ?? false);
                        viewModel.updateStep5P46OptionD(_optionD);
                      },
                      title: const Text('Tick box D if the above applies to you.'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                    // Signature confirmation
                    Text(
                      'Signature and date',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    CheckboxListTile(
                      value: _confirmCorrect,
                      onChanged: (val) {
                        setState(() => _confirmCorrect = val ?? false);
                      },
                      title: const Text(
                        'I can confirm that this information is correct.',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (!_confirmCorrect)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUnitUtil.getSpacing(12),
                          bottom: ScreenUnitUtil.getSpacing(8),
                        ),
                        child: Text(
                          'Please confirm that the information is correct',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: ScreenUnitUtil.getFontSize(12),
                          ),
                        ),
                      ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                    // Error message
                    if (viewModel.errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(
                          ScreenUnitUtil.getSpacing(12),
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.errorContainer,
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
                            SizedBox(
                                width: ScreenUnitUtil.getSpacing(8)),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                    // Navigation buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: viewModel.isStepLoading
                                ? null
                                : () {
                                    viewModel.goToStep(4);
                                    Navigator.pushReplacementNamed(
                                      context,
                                      RouteNames.signUpStep4,
                                      arguments: {
                                        'isEditMode': widget.isEditMode,
                                      },
                                    );
                                  },
                            child: const Text('Back'),
                          ),
                        ),
                        SizedBox(
                            width: ScreenUnitUtil.getSpacing(16)),
                    Expanded(
                          child: PrimaryButton(
                            text: widget.isEditMode
                                ? 'Update'
                                : (viewModel.hasCustomFields
                                    ? 'Next'
                                    : 'Finish'),
                            isLoading: viewModel.isStepLoading,
                            onPressed: () => _handleSubmit(viewModel),
                          ),
                        ), 
                      ],
                    ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  Text(
                    'Regal Court, 42–44 High Street, Slough, SL1 1EL\nMobile: 07809439408',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(12),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionAbcTile({
    required String code,
    required String description,
  }) {
    return RadioListTile<String>(
      value: code,
      groupValue: _selectedOptionAbc,
      onChanged: (val) {
        final viewModel = context.read<SignUpViewModel>();
        setState(() => _selectedOptionAbc = val);
        viewModel.updateStep5P46OptionAbc(val);
      },
      title: Text(description),
      secondary: Text(
        code,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ScreenUnitUtil.getFontSize(16),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(SignUpViewModel viewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGender == null || _selectedOptionAbc == null) return;
    if (!_confirmCorrect) return;

    final success = await viewModel.submitStep5P46();
    if (success && mounted) {
      if (widget.isEditMode) {
        Navigator.pop(context, true);
        ToastMessage.showSuccess('Tax details updated successfully', context);
        return;
      }

      if (viewModel.hasCustomFields && viewModel.customFields.isNotEmpty) {
        // Move to Step 6: Additional Information
        viewModel.goToStep(6);
        Navigator.pushReplacementNamed(
          context,
          RouteNames.signUpStep6,
          arguments: {'isEditMode': widget.isEditMode},
        );
        ToastMessage.showSuccess('Tax details saved!', context);
      } else {
        // Registration complete - save token if available
        if (viewModel.registrationToken != null &&
            viewModel.registrationToken!.isNotEmpty) {
          await AuthService.saveToken(viewModel.registrationToken!);
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.home,
          (route) => false,
        );
        ToastMessage.showSuccess(
          'Registration completed successfully!',
          context,
        );
      }
    } else if (mounted && viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}

