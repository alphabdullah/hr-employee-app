// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../viewmodels/signup_viewmodel.dart';
// import '../../utils/screen_unit_util.dart';
// import '../../resources/components/primary_button.dart';
// import '../../resources/components/step_indicator.dart';
// import '../../routes/route_names.dart';
// import '../../utils/toast_message.dart';

// /// Step 1: Profile & Account Information Screen
// class SignUpStep1Screen extends StatefulWidget {
//   final bool isEditMode;

//   const SignUpStep1Screen({
//     super.key,
//     this.isEditMode = false,
//   });

//   @override
//   State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
// }

// class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _surnameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _passwordConfirmationController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _telNoController = TextEditingController();
//   final _whatsappNoController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _countryController = TextEditingController();

//   final _cityController = TextEditingController();
//   final _postCodeController = TextEditingController();
//   final _natInsuranceNoController = TextEditingController();
//   final _nationalityController = TextEditingController();
//   final _workPermitExpiryController = TextEditingController();
//   final _studentVisaHoursController = TextEditingController();
//   final _regionController = TextEditingController();
//   final _districtController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscurePasswordConfirmation = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _surnameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _passwordConfirmationController.dispose();
//     _dobController.dispose();
//     _telNoController.dispose();
//     _whatsappNoController.dispose();
//     _addressController.dispose();
//     _countryController.dispose();
//     _cityController.dispose();
//     _postCodeController.dispose();
//     _natInsuranceNoController.dispose();
//     _nationalityController.dispose();
//     _workPermitExpiryController.dispose();
//     _studentVisaHoursController.dispose();
//     _regionController.dispose();
//     _districtController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Set current step to 1 when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = context.read<SignUpViewModel>();
//       viewModel.goToStep(1);
//       viewModel.setEditMode(widget.isEditMode);

//       // Load profile data to prefill forms
//       viewModel.loadProfileData().then((_) {
//         if (mounted) {
//           final step1Model = viewModel.step1Model;
//           _nameController.text = step1Model.name;
//           _surnameController.text = step1Model.surname;
//           _emailController.text = step1Model.email;
//           if (step1Model.dob != null) _dobController.text = step1Model.dob!;
//           if (step1Model.telNo != null) _telNoController.text = step1Model.telNo!;
//           if (step1Model.whatsappNo != null) _whatsappNoController.text = step1Model.whatsappNo!;
//           if (step1Model.address != null) _addressController.text = step1Model.address!;
//           if (step1Model.country != null) _countryController.text = step1Model.country!;
//           if (step1Model.region != null) _regionController.text = step1Model.region!; // New
//           if (step1Model.district != null) _districtController.text = step1Model.district!; // New
//           if (step1Model.city != null) _cityController.text = step1Model.city!;
//           if (step1Model.postCode != null) _postCodeController.text = step1Model.postCode!;
//           if (step1Model.natInsuranceNo != null) _natInsuranceNoController.text = step1Model.natInsuranceNo!;
//           if (step1Model.nationality != null) _nationalityController.text = step1Model.nationality!;
//           if (step1Model.workPermitExpiry != null) _workPermitExpiryController.text = step1Model.workPermitExpiry!;
//           if (step1Model.studentVisaHoursPerWeek != null) {
//             _studentVisaHoursController.text = step1Model.studentVisaHoursPerWeek.toString();
//           }
//           setState(() {});
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ScreenUnitUtil.init(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Create Account',
//           style: TextStyle(
//             fontSize: ScreenUnitUtil.getFontSize(20),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Consumer<SignUpViewModel>(
//           builder: (context, viewModel, child) {
//             // Listen for changes in model to update read-only controllers
//             _countryController.text = viewModel.step1Model.country ?? '';
//             _regionController.text = viewModel.step1Model.region ?? '';
//             return Column(
//               children: [
//                 // Step Indicator
//                 StepIndicator(currentStep: 1, totalSteps: 4),

//                 // Form Content
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: ScreenUnitUtil.getSpacing(24),
//                       vertical: ScreenUnitUtil.getSpacing(16),
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                     Text(
//                       'Profile & Account Information',
//                       style: TextStyle(
//                         fontSize: ScreenUnitUtil.getFontSize(24),
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(8)),
//                     Text(
//                       'Please provide your basic information',
//                       style: TextStyle(
//                         fontSize: ScreenUnitUtil.getFontSize(14),
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(24)),

//                     // Name (Required)
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Name *',
//                         hintText: 'Enter your first name',
//                         prefixIcon: Icon(Icons.person_outline),
//                       ),
//                       onChanged: viewModel.updateStep1Name,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your name';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Surname (Required)
//                     TextFormField(
//                       controller: _surnameController,
//                       decoration: InputDecoration(
//                         labelText: 'Surname *',
//                         hintText: 'Enter your surname',
//                         prefixIcon: Icon(Icons.person_outline),
//                       ),
//                       onChanged: viewModel.updateStep1Surname,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your surname';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Email (Required)
//                     TextFormField(
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: InputDecoration(
//                         labelText: 'Email *',
//                         hintText: 'Enter your email',
//                         prefixIcon: Icon(Icons.email),
//                       ),
//                       onChanged: viewModel.updateStep1Email,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Password (Required in registration, optional in edit)
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         labelText: widget.isEditMode ? 'Password (leave blank to keep current)' : 'Password *',
//                         hintText: widget.isEditMode ? 'Enter new password (optional)' : 'Enter your password (min 8 characters)',
//                         prefixIcon: Icon(Icons.lock_outline),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
//                           onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                         ),
//                       ),
//                       onChanged: viewModel.updateStep1Password,
//                       validator: (value) {
//                         if (!widget.isEditMode) {
//                           // Registration mode - password required
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a password';
//                           }
//                           if (value.length < 8) {
//                             return 'Password must be at least 8 characters';
//                           }
//                         } else {
//                           // Edit mode - password optional, but validate if provided
//                           if (value != null && value.isNotEmpty && value.length < 8) {
//                             return 'Password must be at least 8 characters';
//                           }
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Password Confirmation
//                     TextFormField(
//                       controller: _passwordConfirmationController,
//                       obscureText: _obscurePasswordConfirmation,
//                       decoration: InputDecoration(
//                         labelText: widget.isEditMode ? 'Confirm Password (if changing)' : 'Confirm Password *',
//                         hintText: widget.isEditMode ? 'Re-enter new password' : 'Re-enter your password',
//                         prefixIcon: Icon(Icons.lock_outline),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscurePasswordConfirmation ? Icons.visibility : Icons.visibility_off),
//                           onPressed: () => setState(() => _obscurePasswordConfirmation = !_obscurePasswordConfirmation),
//                         ),
//                       ),
//                       onChanged: viewModel.updateStep1PasswordConfirmation,
//                       validator: (value) {
//                         if (!widget.isEditMode) {
//                           // Registration mode - password confirmation required
//                           if (value == null || value.isEmpty) {
//                             return 'Please confirm your password';
//                           }
//                           if (value != _passwordController.text) {
//                             return 'Passwords do not match';
//                           }
//                         } else {
//                           // Edit mode - only validate if password is being changed
//                           if (_passwordController.text.isNotEmpty) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password';
//                             }
//                             if (value != _passwordController.text) {
//                               return 'Passwords do not match';
//                             }
//                           }
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Date of Birth
//                     TextFormField(
//                       controller: _dobController,
//                       decoration: InputDecoration(
//                         labelText: 'Date of Birth',
//                         hintText: 'YYYY-MM-DD',
//                         prefixIcon: Icon(Icons.calendar_today_outlined),
//                       ),
//                       onTap: () async {
//                         final date = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime.now(),
//                         );
//                         if (date != null) {
//                           _dobController.text = DateFormat('yyyy-MM-dd').format(date);
//                           viewModel.updateStep1Dob(_dobController.text);
//                         }
//                       },
//                       onChanged: viewModel.updateStep1Dob,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Phone Number
//                     TextFormField(
//                       controller: _telNoController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number',
//                         hintText: '+44123456789',
//                         prefixIcon: Icon(Icons.phone_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1TelNo,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // WhatsApp Number
//                     TextFormField(
//                       controller: _whatsappNoController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         labelText: 'WhatsApp Number',
//                         hintText: '+44987654321',
//                         prefixIcon: Icon(Icons.chat_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1WhatsappNo,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Address
//                     TextFormField(
//                       controller: _addressController,
//                       decoration: InputDecoration(
//                         labelText: 'Address',
//                         hintText: 'Enter your address',
//                         prefixIcon: Icon(Icons.home_outlined),
//                       ),
//                       maxLines: 2,
//                       onChanged: viewModel.updateStep1Address,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Map Location Button
//                     OutlinedButton.icon(
//                       onPressed: () async {
//                         final result = await Navigator.pushNamed(
//                           context,
//                           RouteNames.addressPicker,
//                           arguments: {
//                             'latitude': viewModel.step1Model.latitude,
//                             'longitude': viewModel.step1Model.longitude,
//                           },
//                         );
//                         if (result != null && result is Map<String, dynamic>) {
//                           viewModel.updateStep1Location(
//                             result['latitude'] as double?,
//                             result['longitude'] as double?,
//                           );
//                         }
//                       },
//                       icon: Icon(Icons.map_outlined),
//                       label: Text('Mark Your Home Location on Map'),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(8)),
//                     if (viewModel.step1Model.latitude != null && viewModel.step1Model.longitude != null)
//                       Text(
//                         'Location: ${viewModel.step1Model.latitude!.toStringAsFixed(6)}, ${viewModel.step1Model.longitude!.toStringAsFixed(6)}',
//                         style: TextStyle(
//                           fontSize: ScreenUnitUtil.getFontSize(12),
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Country
//                     TextFormField(
//                       controller: _countryController,
//                       decoration: InputDecoration(
//                         labelText: 'Country',
//                         hintText: 'Enter your country',
//                         prefixIcon: Icon(Icons.public_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1Country,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     TextFormField(
//                       controller: _regionController,
//                       decoration: InputDecoration(
//                         labelText: 'Region',
//                         hintText: 'Enter your region',
//                         prefixIcon: Icon(Icons.location_city_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1Region,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     TextFormField(
//                       controller: _districtController,
//                       decoration: InputDecoration(
//                         labelText: 'District',
//                         hintText: 'Enter your district',
//                         prefixIcon: Icon(Icons.location_city_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1District,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // City
//                     TextFormField(
//                       controller: _cityController,
//                       decoration: InputDecoration(
//                         labelText: 'City',
//                         hintText: 'Enter your city',
//                         prefixIcon: Icon(Icons.location_city_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1City,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Post Code
//                     TextFormField(
//                       controller: _postCodeController,
//                       decoration: InputDecoration(
//                         labelText: 'Post Code',
//                         hintText: 'Enter your post code',
//                         prefixIcon: Icon(Icons.markunread_mailbox_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1PostCode,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // National Insurance Number
//                     TextFormField(
//                       controller: _natInsuranceNoController,
//                       decoration: InputDecoration(
//                         labelText: 'National Insurance Number',
//                         hintText: 'AB123456C',
//                         prefixIcon: Icon(Icons.badge_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1NatInsuranceNo,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Nationality
//                     TextFormField(
//                       controller: _nationalityController,
//                       decoration: InputDecoration(
//                         labelText: 'Nationality',
//                         hintText: 'Enter your nationality',
//                         prefixIcon: Icon(Icons.flag_outlined),
//                       ),
//                       onChanged: viewModel.updateStep1Nationality,
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Right to Work UK
//                     SwitchListTile(
//                       title: Text('Right to Work in UK'),
//                       value: viewModel.step1Model.rightToWorkUk ?? false,
//                       onChanged: (value) => viewModel.updateStep1RightToWorkUk(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(8)),

//                     // Gender Dropdown
//                     DropdownButtonFormField<String>(
//                       value: viewModel.step1Model.gender,
//                       decoration: InputDecoration(
//                         labelText: 'Gender',
//                         prefixIcon: Icon(Icons.person_outline),
//                       ),
//                       items: ['male', 'female', 'other', 'prefer_not_to_say']
//                           .map((gender) => DropdownMenuItem(value: gender, child: Text(gender.toUpperCase())))
//                           .toList(),
//                       onChanged: (value) => viewModel.updateStep1Gender(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Marital Status Dropdown
//                     DropdownButtonFormField<String>(
//                       value: viewModel.step1Model.maritalStatus,
//                       decoration: InputDecoration(
//                         labelText: 'Marital Status',
//                         prefixIcon: Icon(Icons.favorite_outline),
//                       ),
//                       items: ['single', 'married', 'divorced', 'widowed']
//                           .map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase())))
//                           .toList(),
//                       onChanged: (value) => viewModel.updateStep1MaritalStatus(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Need Work Permit
//                     SwitchListTile(
//                       title: Text('Need Work Permit'),
//                       value: viewModel.step1Model.needWorkPermit ?? false,
//                       onChanged: (value) => viewModel.updateStep1NeedWorkPermit(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(8)),

//                     // Work Permit Expiry (if need_work_permit is true)
//                     if (viewModel.step1Model.needWorkPermit == true)
//                       TextFormField(
//                         controller: _workPermitExpiryController,
//                         decoration: InputDecoration(
//                           labelText: 'Work Permit Expiry *',
//                           hintText: 'YYYY-MM-DD',
//                           prefixIcon: Icon(Icons.calendar_today_outlined),
//                         ),
//                         onTap: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime.now(),
//                             lastDate: DateTime.now().add(Duration(days: 365 * 10)),
//                           );
//                           if (date != null) {
//                             _workPermitExpiryController.text = DateFormat('yyyy-MM-dd').format(date);
//                             viewModel.updateStep1WorkPermitExpiry(_workPermitExpiryController.text);
//                           }
//                         },
//                         onChanged: viewModel.updateStep1WorkPermitExpiry,
//                       ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Student Visa Hours Per Week
//                     TextFormField(
//                       controller: _studentVisaHoursController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Student Visa Hours Per Week',
//                         hintText: '0-168',
//                         prefixIcon: Icon(Icons.access_time_outlined),
//                       ),
//                       onChanged: (value) {
//                         if (value.isNotEmpty) {
//                           viewModel.updateStep1StudentVisaHoursPerWeek(int.tryParse(value));
//                         } else {
//                           viewModel.updateStep1StudentVisaHoursPerWeek(null);
//                         }
//                       },
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // Prefer Contact Dropdown
//                     DropdownButtonFormField<String>(
//                       value: viewModel.step1Model.preferContact,
//                       decoration: InputDecoration(
//                         labelText: 'Preferred Contact Method',
//                         prefixIcon: Icon(Icons.contact_mail_outlined),
//                       ),
//                       items: ['email', 'sms', 'both']
//                           .map((method) => DropdownMenuItem(value: method, child: Text(method.toUpperCase())))
//                           .toList(),
//                       onChanged: (value) => viewModel.updateStep1PreferContact(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(16)),

//                     // User Type Dropdown
//                     DropdownButtonFormField<String>(
//                       value: viewModel.step1Model.userType,
//                       decoration: InputDecoration(
//                         labelText: 'User Type',
//                         prefixIcon: Icon(Icons.work_outline),
//                       ),
//                       items: ['merchandisers', 'support_staff', 'drivers', 'team_leaders']
//                           .map((type) => DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' ').toUpperCase())))
//                           .toList(),
//                       onChanged: (value) => viewModel.updateStep1UserType(value),
//                     ),
//                     SizedBox(height: ScreenUnitUtil.getSpacing(24)),

//                     // Error Message
//                     if (viewModel.errorMessage != null)
//                       Container(
//                         padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.errorContainer,
//                           borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
//                             SizedBox(width: ScreenUnitUtil.getSpacing(8)),
//                             Expanded(
//                               child: Text(
//                                 viewModel.errorMessage!,
//                                 style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                           SizedBox(height: ScreenUnitUtil.getSpacing(24)),

//                           // Next/Update Button
//                           PrimaryButton(
//                             text: widget.isEditMode ? 'Update' : 'Next',
//                             isLoading: viewModel.isStepLoading || viewModel.isLoadingProfile,
//                             onPressed: () => _handleSubmit(viewModel),
//                           ),
//                           SizedBox(height: ScreenUnitUtil.getSpacing(16)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _handleSubmit(SignUpViewModel viewModel) async {
//     if (_formKey.currentState?.validate() ?? false) {
//       final success = await viewModel.submitStep1();
//       if (success && mounted) {
//         if (widget.isEditMode) {
//           // In edit mode, go back to profile edit screen
//           Navigator.pop(context, true); // Return true to indicate update success
//           ToastMessage.showSuccess('Profile updated successfully!', context);
//         } else {
//           // In registration mode, go to next step
//           viewModel.goToStep(2);
//           Navigator.pushReplacementNamed(
//             context,
//             RouteNames.signUpStep2,
//             arguments: {'isEditMode': false},
//           );
//         }
//       } else if (mounted && viewModel.errorMessage != null) {
//         ToastMessage.showError(viewModel.errorMessage!, context);
//       }
//     }
//   }
// }

import 'dart:async';
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

/// Text input formatter for Date of Birth (DD/MM/YYYY)
class DateOfBirthFormatter extends TextInputFormatter {
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

/// Text input formatter for Phone Number with +44 prefix (editable)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // If text is empty, allow it (don't force +44)
    if (text.isEmpty) {
      return newValue;
    }

    // If user starts typing digits in an empty field, auto-add +44
    if (oldValue.text.isEmpty && text.isNotEmpty) {
      // Check if user is typing digits (not a + sign)
      if (text[0] != '+' && RegExp(r'^\d').hasMatch(text)) {
        // User started with a digit, add +44 prefix
        String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
        text = '+44 $digitsOnly';
        return newValue.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }

    // If user is editing existing text, allow full editing
    // User can delete or modify +44, or use a different country code
    // Just clean up formatting (remove extra spaces)
    if (text.startsWith('+')) {
      // Has country code, clean up spaces but keep the code editable
      String cleaned = text.replaceAll(RegExp(r'\s+'), ' ');
      // Ensure space after country code if it's +44
      if (cleaned.startsWith('+44') &&
          cleaned.length > 3 &&
          cleaned[3] != ' ') {
        cleaned = '+44 ${cleaned.substring(3).trim()}';
      }
      return newValue.copyWith(text: cleaned, selection: newValue.selection);
    }

    // No + prefix - user might be typing their own format
    // Allow it but clean up extra spaces
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ');
    return newValue.copyWith(text: cleaned, selection: newValue.selection);
  }
}

/// Step 1: Profile & Account Information Screen
class SignUpStep1Screen extends StatefulWidget {
  final bool isEditMode;

  const SignUpStep1Screen({super.key, this.isEditMode = false});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _dobController = TextEditingController();
  final _telNoController = TextEditingController();
  final _whatsappNoController = TextEditingController();
  final _addressController = TextEditingController();

  final _countryController = TextEditingController();
  final _regionController = TextEditingController();
  final _districtController = TextEditingController();

  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _natInsuranceNoController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _workPermitExpiryController = TextEditingController();
  final _studentVisaHoursController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  bool _isOnStudentVisa = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _dobController.dispose();
    _telNoController.dispose();
    _whatsappNoController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    _natInsuranceNoController.dispose();
    _nationalityController.dispose();
    _workPermitExpiryController.dispose();
    _studentVisaHoursController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(1);
      viewModel.setEditMode(widget.isEditMode);

      // ✅ In edit mode, keep password blank unless user types a new one
      if (widget.isEditMode) {
        _passwordController.clear();
        _passwordConfirmationController.clear();
      }

      // Fetch custom fields to determine if Step 5 should be shown
      await viewModel.fetchCustomFields();
      await viewModel.loadProfileData();

      if (!mounted) return;

      final step1Model = viewModel.step1Model;
      _nameController.text = step1Model.name;
      _surnameController.text = step1Model.surname;
      _emailController.text = step1Model.email;

      if (step1Model.dob != null) {
        // Convert YYYY-MM-DD to DD/MM/YYYY for display
        try {
          final dateParts = step1Model.dob!.split('-');
          if (dateParts.length == 3) {
            _dobController.text =
                '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
          } else {
            _dobController.text = step1Model.dob!;
          }
        } catch (e) {
          _dobController.text = step1Model.dob!;
        }
      }
      if (step1Model.telNo != null && step1Model.telNo!.isNotEmpty) {
        String telNo = step1Model.telNo!;
        // If doesn't start with +44, add it
        if (!telNo.startsWith('+44')) {
          // Remove any existing + or country code
          telNo = telNo.replaceAll(RegExp(r'^\+?\d{0,2}'), '');
          telNo = telNo.replaceAll(RegExp(r'[^\d]'), '');
          _telNoController.text = '+44 $telNo';
        } else {
          _telNoController.text = telNo;
        }
      } else {
        // Initialize empty field with +44
        _telNoController.text = '+44 ';
      }
      if (step1Model.whatsappNo != null && step1Model.whatsappNo!.isNotEmpty) {
        String whatsappNo = step1Model.whatsappNo!;
        // If doesn't start with +44, add it
        if (!whatsappNo.startsWith('+44')) {
          // Remove any existing + or country code
          whatsappNo = whatsappNo.replaceAll(RegExp(r'^\+?\d{0,2}'), '');
          whatsappNo = whatsappNo.replaceAll(RegExp(r'[^\d]'), '');
          _whatsappNoController.text = '+44 $whatsappNo';
        } else {
          _whatsappNoController.text = whatsappNo;
        }
      } else {
        // Initialize empty field with +44
        _whatsappNoController.text = '+44 ';
      }
      if (step1Model.address != null)
        _addressController.text = step1Model.address!;
      if (step1Model.country != null)
        _countryController.text = step1Model.country!;
      if (step1Model.region != null)
        _regionController.text = step1Model.region!;
      if (step1Model.district != null)
        _districtController.text = step1Model.district!;
      if (step1Model.city != null) _cityController.text = step1Model.city!;
      if (step1Model.postCode != null)
        _postCodeController.text = step1Model.postCode!;
      if (step1Model.natInsuranceNo != null)
        _natInsuranceNoController.text = step1Model.natInsuranceNo!;
      if (step1Model.nationality != null)
        _nationalityController.text = step1Model.nationality!;
      if (step1Model.workPermitExpiry != null)
        _workPermitExpiryController.text = step1Model.workPermitExpiry!;
      if (step1Model.studentVisaHoursPerWeek != null) {
        _studentVisaHoursController.text = step1Model.studentVisaHoursPerWeek
            .toString();
      }

      _isOnStudentVisa =
          step1Model.studentVisaHoursPerWeek != null &&
              step1Model.studentVisaHoursPerWeek! > 0;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Information',
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
            // Keep read-only fields synced
            _countryController.text = viewModel.step1Model.country ?? '';
            _regionController.text = viewModel.step1Model.region ?? '';
            _districtController.text = viewModel.step1Model.district ?? '';

            return Column(
              children: [
                StepIndicator(
                  currentStep: 1,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile & Account Information',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(24),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                          Text(
                            'Please provide your basic information',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(14),
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            onChanged: viewModel.updateStep1Name,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your name';
                              if (value.length > 255)
                                return 'Name must be maximum 255 characters';
                              if (value.trim().isEmpty)
                                return 'Name cannot be only spaces';
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Surname
                          TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              labelText: 'Surname *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            onChanged: viewModel.updateStep1Surname,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your surname';
                              if (value.length > 255)
                                return 'Surname must be maximum 255 characters';
                              if (value.trim().isEmpty)
                                return 'Surname cannot be only spaces';
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: const Icon(Icons.email_outlined),
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
                            onChanged: viewModel.updateStep1Email,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your email';
                              if (value.length > 255)
                                return 'Email must be maximum 255 characters';
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // ✅ Password (optional in edit mode)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: widget.isEditMode
                                  ? 'Password (leave blank to keep current)'
                                  : 'Password *',
                              hintText:
                                  'Must have uppercase, lowercase & number',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
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
                            onChanged: viewModel.updateStep1Password,
                            validator: (value) {
                              final v = value ?? '';
                              if (!widget.isEditMode) {
                                if (v.isEmpty) return 'Please enter a password';
                                if (v.length < 8)
                                  return 'Password must be at least 8 characters';
                                if (v.length > 128)
                                  return 'Password must be maximum 128 characters';
                                // Check for uppercase letter
                                if (!RegExp(r'[A-Z]').hasMatch(v))
                                  return 'Password must contain at least one uppercase letter';
                                // Check for lowercase letter
                                if (!RegExp(r'[a-z]').hasMatch(v))
                                  return 'Password must contain at least one lowercase letter';
                                // Check for number
                                if (!RegExp(r'[0-9]').hasMatch(v))
                                  return 'Password must contain at least one number';
                              } else {
                                if (v.isNotEmpty) {
                                  if (v.length < 8)
                                    return 'Password must be at least 8 characters';
                                  if (v.length > 128)
                                    return 'Password must be maximum 128 characters';
                                  // Check for uppercase letter
                                  if (!RegExp(r'[A-Z]').hasMatch(v))
                                    return 'Password must contain at least one uppercase letter';
                                  // Check for lowercase letter
                                  if (!RegExp(r'[a-z]').hasMatch(v))
                                    return 'Password must contain at least one lowercase letter';
                                  // Check for number
                                  if (!RegExp(r'[0-9]').hasMatch(v))
                                    return 'Password must contain at least one number';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // ✅ Confirm password (only required if password typed in edit mode)
                          TextFormField(
                            controller: _passwordConfirmationController,
                            obscureText: _obscurePasswordConfirmation,
                            decoration: InputDecoration(
                              labelText: widget.isEditMode
                                  ? 'Confirm Password (if changing)'
                                  : 'Confirm Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordConfirmation
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePasswordConfirmation =
                                      !_obscurePasswordConfirmation,
                                ),
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
                            onChanged:
                                viewModel.updateStep1PasswordConfirmation,
                            validator: (value) {
                              final confirm = value ?? '';
                              final pass = _passwordController.text;

                              if (!widget.isEditMode) {
                                if (confirm.isEmpty)
                                  return 'Please confirm your password';
                                if (confirm != pass)
                                  return 'Passwords do not match';
                              } else {
                                if (pass.isNotEmpty) {
                                  if (confirm.isEmpty)
                                    return 'Please confirm your password';
                                  if (confirm != pass)
                                    return 'Passwords do not match';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // DOB (with auto-formatting and calendar picker)
                          TextFormField(
                            controller: _dobController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Date of Birth (DD/MM/YYYY) *',
                              hintText: 'DD/MM/YYYY or tap calendar icon',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
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
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () async {
                                  // Show calendar picker
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dobController.text.isNotEmpty
                                        ? (() {
                                            try {
                                              final parts = _dobController.text
                                                  .split('/');
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
                                            return DateTime.now().subtract(
                                              const Duration(days: 365 * 25),
                                            );
                                          })()
                                        : DateTime.now().subtract(
                                            const Duration(days: 365 * 25),
                                          ),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    // Format as DD/MM/YYYY
                                    _dobController.text =
                                        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                    // Convert to YYYY-MM-DD for backend
                                    final dateStr =
                                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                    viewModel.updateStep1Dob(dateStr);
                                  }
                                },
                              ),
                            ),
                            inputFormatters: [
                              DateOfBirthFormatter(),
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
                                        year >= 1900 &&
                                        year <= DateTime.now().year) {
                                      final dateStr =
                                          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                                      viewModel.updateStep1Dob(dateStr);
                                    }
                                  } catch (e) {
                                    // Invalid date format
                                  }
                                }
                              } else {
                                viewModel.updateStep1Dob(null);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your date of birth';
                              if (value.length != 10)
                                return 'Please enter a complete date (DD/MM/YYYY)';
                              final parts = value.split('/');
                              if (parts.length != 3)
                                return 'Invalid date format. Use DD/MM/YYYY';
                              try {
                                final day = int.parse(parts[0]);
                                final month = int.parse(parts[1]);
                                final year = int.parse(parts[2]);

                                if (day < 1 || day > 31)
                                  return 'Day must be between 1 and 31';
                                if (month < 1 || month > 12)
                                  return 'Month must be between 1 and 12';
                                if (year < 1900 || year > DateTime.now().year)
                                  return 'Year must be between 1900 and ${DateTime.now().year}';

                                final date = DateTime(year, month, day);
                                if (date.year != year ||
                                    date.month != month ||
                                    date.day != day)
                                  return 'Invalid date';

                                if (date.isAfter(DateTime.now()))
                                  return 'Date of birth cannot be in the future';
                              } catch (e) {
                                return 'Invalid date format';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Phone
                          TextFormField(
                            controller: _telNoController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Telephone Number *',
                              hintText: '+44 1234567890',
                              prefixIcon: const Icon(Icons.phone_outlined),
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
                              PhoneNumberFormatter(),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onTap: () {
                              // If field is empty, set +44 when user taps
                              if (_telNoController.text.isEmpty) {
                                _telNoController.text = '+44 ';
                                _telNoController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _telNoController.text.length,
                                      ),
                                    );
                              }
                            },
                            onChanged: (value) {
                              viewModel.updateStep1TelNo(value);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your telephone number';
                              }
                                // Remove spaces, dashes, and parentheses for validation
                                final cleaned = value.replaceAll(
                                  RegExp(r'[\s\-\(\)]'),
                                  '',
                                );
                                // Should start with + and country code
                                if (!cleaned.startsWith('+'))
                                  return 'Phone number must start with country code (e.g., +44)';
                                // Check if it contains only digits and + at start
                                if (!RegExp(r'^\+\d+$').hasMatch(cleaned))
                                  return 'Phone number must contain only digits after the country code';
                                // Extract country code and number
                                final match = RegExp(
                                  r'^\+\d{1,3}(.+)$',
                                ).firstMatch(cleaned);
                                if (match == null)
                                  return 'Phone number must have a valid country code and number';
                                final numberPart = match.group(1) ?? '';
                                // Check if number part has valid length (minimum 7 digits)
                                if (numberPart.length < 7)
                                  return 'Phone number must be at least 7 digits after country code';
                                // Check if total length is maximum 15 digits (country code + number)
                                if (cleaned.length > 15)
                                  return 'Phone number including country code must be maximum 15 digits (currently ${cleaned.length} digits)';
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // WhatsApp
                          TextFormField(
                            controller: _whatsappNoController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'WhatsApp Number *',
                              hintText: '+44 1234567890',
                              prefixIcon: const Icon(Icons.chat_outlined),
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
                              PhoneNumberFormatter(),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onTap: () {
                              // If field is empty, set +44 when user taps
                              if (_whatsappNoController.text.isEmpty) {
                                _whatsappNoController.text = '+44 ';
                                _whatsappNoController
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _whatsappNoController.text.length,
                                  ),
                                );
                              }
                            },
                            onChanged: (value) {
                              viewModel.updateStep1WhatsappNo(value);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your WhatsApp number';
                              }
                                // Remove spaces, dashes, and parentheses for validation
                                final cleaned = value.replaceAll(
                                  RegExp(r'[\s\-\(\)]'),
                                  '',
                                );
                                // Should start with + and country code
                                if (!cleaned.startsWith('+'))
                                  return 'WhatsApp number must start with country code (e.g., +44)';
                                // Check if it contains only digits and + at start
                                if (!RegExp(r'^\+\d+$').hasMatch(cleaned))
                                  return 'WhatsApp number must contain only digits after the country code';
                                // Extract country code and number
                                final match = RegExp(
                                  r'^\+\d{1,3}(.+)$',
                                ).firstMatch(cleaned);
                                if (match == null)
                                  return 'WhatsApp number must have a valid country code and number';
                                final numberPart = match.group(1) ?? '';
                                // Check if number part has valid length (minimum 7 digits)
                                if (numberPart.length < 7)
                                  return 'WhatsApp number must be at least 7 digits after country code';
                                // Check if total length is maximum 15 digits (country code + number)
                                if (cleaned.length > 15)
                                  return 'WhatsApp number including country code must be maximum 15 digits (currently ${cleaned.length} digits)';
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                            minLines: 1,
                            maxLines:
                                null, // Allow unlimited lines to show complete address
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(500),
                            ],
                            onChanged: viewModel.updateStep1Address,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your address';
                              }
                              if (value.length > 500) {
                                return 'Address must be maximum 500 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'Address cannot be only spaces';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Mark Location on Map Button
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                RouteNames.addressPicker,
                                arguments: {
                                  'latitude': viewModel.step1Model.latitude,
                                  'longitude': viewModel.step1Model.longitude,
                                },
                              );
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                final latitude = result['latitude'] as double?;
                                final longitude =
                                    result['longitude'] as double?;
                                final address = result['address'] as String?;

                                if (latitude != null && longitude != null) {
                                  viewModel.updateStep1Location(
                                    latitude,
                                    longitude,
                                  );
                                }

                                // Save address if available and show in address field
                                if (address != null && address.isNotEmpty) {
                                  _addressController.text = address;
                                  viewModel.updateStep1Address(address);
                                }
                              }
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Mark Your Location on Map *'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: ScreenUnitUtil.getSpacing(12),
                                horizontal: ScreenUnitUtil.getSpacing(16),
                              ),
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(8)),

                          if (viewModel.step1Model.latitude == null ||
                              viewModel.step1Model.longitude == null)
                            Padding(
                              padding: EdgeInsets.only(
                                left: ScreenUnitUtil.getSpacing(4),
                                right: ScreenUnitUtil.getSpacing(4),
                                bottom: ScreenUnitUtil.getSpacing(12),
                              ),
                              child: Text(
                                'Marking your location on the map is required',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: ScreenUnitUtil.getFontSize(12),
                                ),
                              ),
                            ),

                          // Display selected location coordinates
                          if (viewModel.step1Model.latitude != null &&
                              viewModel.step1Model.longitude != null)
                            Container(
                              padding: EdgeInsets.all(
                                ScreenUnitUtil.getSpacing(12),
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: ScreenUnitUtil.getFontSize(20),
                                  ),
                                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                                  Expanded(
                                    child: Text(
                                      'Location is saved',
                                      style: TextStyle(
                                        fontSize: ScreenUnitUtil.getFontSize(
                                          12,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Post Code (API + Loader)
                          TextFormField(
                            controller: _postCodeController,
                            decoration: InputDecoration(
                              labelText: 'Post Code *',
                              hintText: 'SW1A 1AA',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                              suffixIcon: viewModel.isPostcodeLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onChanged: (value) {
                              viewModel.fetchPostcodeData(
                                value,
                              ); // ✅ Debounced API call
                              viewModel.updateStep1PostCode(value);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your post code';
                              }
                              // UK postcode format validation
                              final ukPostcodePattern = RegExp(
                                r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
                                caseSensitive: false,
                              );
                              if (!ukPostcodePattern.hasMatch(value.trim())) {
                                return 'Please enter a valid UK postcode';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Country
                          TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(
                              labelText: 'Country *',
                              prefixIcon: Icon(Icons.public_outlined),
                            ),
                            onChanged: viewModel.updateStep1Country,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your country';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Region
                          TextFormField(
                            controller: _regionController,
                            decoration: const InputDecoration(
                              labelText: 'Region *',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                            onChanged: viewModel.updateStep1Region,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your region';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // District
                          TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'District *',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            onChanged: viewModel.updateStep1District,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your district';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // City
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            onChanged: viewModel.updateStep1City,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your city';
                              }
                              if (value.length > 100) {
                                return 'City must be maximum 100 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'City cannot be only spaces';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Nat Insurance
                          TextFormField(
                            controller: _natInsuranceNoController,
                            decoration: const InputDecoration(
                              labelText: 'National Insurance Number *',
                              hintText: 'AB123456C',
                              prefixIcon: Icon(Icons.security_outlined),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            onChanged: viewModel.updateStep1NatInsuranceNo,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your National Insurance number';
                              }
                              // UK National Insurance format: 2 letters, 6 digits, 1 letter
                              final niPattern = RegExp(
                                r'^[A-Z]{2}[0-9]{6}[A-Z]{1}$',
                                caseSensitive: false,
                              );
                              if (!niPattern.hasMatch(
                                value.replaceAll(' ', ''),
                              )) {
                                return 'Please enter a valid NI number (e.g., AB123456C)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Nationality
                          TextFormField(
                            controller: _nationalityController,
                            decoration: const InputDecoration(
                              labelText: 'Nationality *',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            onChanged: viewModel.updateStep1Nationality,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your nationality';
                              }
                              if (value.length > 100) {
                                return 'Nationality must be maximum 100 characters';
                              }
                              if (value.trim().isEmpty) {
                                return 'Nationality cannot be only spaces';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Right to Work UK
                          SwitchListTile(
                            title: const Text('Right to Work in UK'),
                            value: viewModel.step1Model.rightToWorkUk ?? false,
                            onChanged: viewModel.updateStep1RightToWorkUk,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Gender
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items:
                                const [
                                      {'value': 'male', 'label': 'Male'},
                                      {'value': 'female', 'label': 'Female'},
                                      {'value': 'other', 'label': 'Other'},
                                      {
                                        'value': 'prefer_not_to_say',
                                        'label': 'Prefer not to say',
                                      },
                                    ]
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g['value'],
                                        child: Text(g['label']!),
                                      ),
                                    )
                                    .toList(),
                            onChanged: viewModel.updateStep1Gender,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Marital status
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.maritalStatus,
                            decoration: const InputDecoration(
                              labelText: 'Marital Status *',
                              prefixIcon: Icon(Icons.family_restroom_outlined),
                            ),
                            items:
                                const [
                                      {'value': 'single', 'label': 'Single'},
                                      {'value': 'married', 'label': 'Married'},
                                      {
                                        'value': 'divorced',
                                        'label': 'Divorced',
                                      },
                                      {'value': 'widowed', 'label': 'Widowed'},
                                      {
                                        'value': 'prefer_not_to_say',
                                        'label': 'Prefer not to say',
                                      },
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s['value'],
                                        child: Text(s['label']!),
                                      ),
                                    )
                                    .toList(),
                            onChanged: viewModel.updateStep1MaritalStatus,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your marital status';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Need Work Permit
                          SwitchListTile(
                            title: const Text('Need Work Permit'),
                            value: viewModel.step1Model.needWorkPermit ?? false,
                            onChanged: viewModel.updateStep1NeedWorkPermit,
                          ),

                          if (viewModel.step1Model.needWorkPermit ?? false) ...[
                            SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                            TextFormField(
                              controller: _workPermitExpiryController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Work Permit Expiry (YYYY-MM-DD)',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 10),
                                  ),
                                );
                                if (date != null) {
                                  _workPermitExpiryController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                  viewModel.updateStep1WorkPermitExpiry(
                                    _workPermitExpiryController.text,
                                  );
                                }
                              },
                              validator: (value) {
                                if (viewModel.step1Model.needWorkPermit ==
                                        true &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Please select your work permit expiry date';
                                }
                                return null;
                              },
                            ),
                          ],
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Student visa question
                          SwitchListTile(
                            title: const Text('Are you on a student visa?'),
                            value: _isOnStudentVisa,
                            onChanged: (value) {
                              setState(() {
                                _isOnStudentVisa = value;
                              });
                              if (!value) {
                                _studentVisaHoursController.clear();
                                viewModel.updateStep1StudentVisaHoursPerWeek(
                                  null,
                                );
                              }
                            },
                          ),

                          if (_isOnStudentVisa) ...[
                            SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                            // Student Visa Hours
                            TextFormField(
                              controller: _studentVisaHoursController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Student Visa Hours Per Week *',
                                hintText: '0-168',
                                prefixIcon: Icon(Icons.access_time_outlined),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  viewModel.updateStep1StudentVisaHoursPerWeek(
                                    int.tryParse(value),
                                  );
                                } else {
                                  viewModel.updateStep1StudentVisaHoursPerWeek(
                                    null,
                                  );
                                }
                              },
                              validator: (value) {
                                if (!_isOnStudentVisa) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your student visa hours per week';
                                }
                                final hours = int.tryParse(value);
                                if (hours == null) {
                                  return 'Please enter a valid number of hours';
                                }
                                if (hours < 0 || hours > 168) {
                                  return 'Hours must be between 0 and 168';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                          ],

                          // Prefer contact
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.preferContact,
                            decoration: const InputDecoration(
                              labelText: 'Preferred Contact Method *',
                              prefixIcon: Icon(Icons.contact_mail_outlined),
                            ),
                            items:
                                const [
                                      {'value': 'email', 'label': 'Email'},
                                      {'value': 'sms', 'label': 'SMS'},
                                      {'value': 'both', 'label': 'Both'},
                                    ]
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m['value'],
                                        child: Text(m['label']!),
                                      ),
                                    )
                                    .toList(),
                            onChanged: viewModel.updateStep1PreferContact,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a preferred contact method';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // User type
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.userType,
                            decoration: const InputDecoration(
                              labelText: 'User Type *',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            items:
                                const [
                                      {
                                        'value': 'merchandisers',
                                        'label': 'Merchandisers',
                                      },
                                      {
                                        'value': 'support_staff',
                                        'label': 'Support Staff',
                                      },
                                      {'value': 'drivers', 'label': 'Drivers'},
                                      {
                                        'value': 'team_leaders',
                                        'label': 'Team Leaders',
                                      },
                                    ]
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t['value'],
                                        child: Text(t['label']!),
                                      ),
                                    )
                                    .toList(),
                            onChanged: viewModel.updateStep1UserType,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a user type';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                          // Error message
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

                          PrimaryButton(
                            text: widget.isEditMode ? 'Update' : 'Next',
                            isLoading:
                                viewModel.isStepLoading ||
                                viewModel.isLoadingProfile ||
                                viewModel.isPostcodeLoading,
                            onPressed: () => _handleSubmit(viewModel),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
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

    final success = await viewModel.submitStep1();

    if (!mounted) return;

    if (success) {
      if (widget.isEditMode) {
        Navigator.pop(context, true);
        ToastMessage.showSuccess('Profile updated successfully!', context);
      } else {
        viewModel.goToStep(2);
        Navigator.pushReplacementNamed(
          context,
          RouteNames.signUpStep2,
          arguments: {'isEditMode': false},
        );
        ToastMessage.showSuccess('Profile saved successfully!', context);
      }
    } else if (viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}
