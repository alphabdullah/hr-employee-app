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
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Step 1: Profile & Account Information Screen
class SignUpStep1Screen extends StatefulWidget {
  final bool isEditMode;

  const SignUpStep1Screen({
    super.key,
    this.isEditMode = false,
  });

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

      await viewModel.loadProfileData();

      if (!mounted) return;

      final step1Model = viewModel.step1Model;
      _nameController.text = step1Model.name;
      _surnameController.text = step1Model.surname;
      _emailController.text = step1Model.email;

      if (step1Model.dob != null) _dobController.text = step1Model.dob!;
      if (step1Model.telNo != null) _telNoController.text = step1Model.telNo!;
      if (step1Model.whatsappNo != null) _whatsappNoController.text = step1Model.whatsappNo!;
      if (step1Model.address != null) _addressController.text = step1Model.address!;
      if (step1Model.country != null) _countryController.text = step1Model.country!;
      if (step1Model.region != null) _regionController.text = step1Model.region!;
      if (step1Model.district != null) _districtController.text = step1Model.district!;
      if (step1Model.city != null) _cityController.text = step1Model.city!;
      if (step1Model.postCode != null) _postCodeController.text = step1Model.postCode!;
      if (step1Model.natInsuranceNo != null) _natInsuranceNoController.text = step1Model.natInsuranceNo!;
      if (step1Model.nationality != null) _nationalityController.text = step1Model.nationality!;
      if (step1Model.workPermitExpiry != null) _workPermitExpiryController.text = step1Model.workPermitExpiry!;
      if (step1Model.studentVisaHoursPerWeek != null) {
        _studentVisaHoursController.text = step1Model.studentVisaHoursPerWeek.toString();
      }

      setState(() {});
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
            // Keep read-only fields synced
            _countryController.text = viewModel.step1Model.country ?? '';
            _regionController.text = viewModel.step1Model.region ?? '';

            return Column(
              children: [
                StepIndicator(currentStep: 1, totalSteps: 4),

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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              if (value == null || value.isEmpty) return 'Please enter your name';
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
                              if (value == null || value.isEmpty) return 'Please enter your surname';
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            onChanged: viewModel.updateStep1Email,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            onChanged: viewModel.updateStep1Password,
                            validator: (value) {
                              final v = value ?? '';
                              if (!widget.isEditMode) {
                                if (v.isEmpty) return 'Please enter a password';
                                if (v.length < 8) return 'Password must be at least 8 characters';
                              } else {
                                if (v.isNotEmpty && v.length < 8) return 'Password must be at least 8 characters';
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
                              labelText: widget.isEditMode ? 'Confirm Password (if changing)' : 'Confirm Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePasswordConfirmation ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(
                                  () => _obscurePasswordConfirmation = !_obscurePasswordConfirmation,
                                ),
                              ),
                            ),
                            onChanged: viewModel.updateStep1PasswordConfirmation,
                            validator: (value) {
                              final confirm = value ?? '';
                              final pass = _passwordController.text;

                              if (!widget.isEditMode) {
                                if (confirm.isEmpty) return 'Please confirm your password';
                                if (confirm != pass) return 'Passwords do not match';
                              } else {
                                if (pass.isNotEmpty) {
                                  if (confirm.isEmpty) return 'Please confirm your password';
                                  if (confirm != pass) return 'Passwords do not match';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // DOB (read-only)
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth (YYYY-MM-DD)',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                _dobController.text = DateFormat('yyyy-MM-dd').format(date);
                                viewModel.updateStep1Dob(_dobController.text);
                              }
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Phone
                          TextFormField(
                            controller: _telNoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telephone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            onChanged: viewModel.updateStep1TelNo,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // WhatsApp
                          TextFormField(
                            controller: _whatsappNoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Number',
                              prefixIcon: Icon(Icons.chat_outlined),
                            ),
                            onChanged: viewModel.updateStep1WhatsappNo,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                            maxLines: 2,
                            onChanged: viewModel.updateStep1Address,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Post Code (API + Loader)
                          TextFormField(
                            controller: _postCodeController,
                            decoration: InputDecoration(
                              labelText: 'Post Code',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              suffixIcon: viewModel.isPostcodeLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              viewModel.fetchPostcodeData(value); // ✅ Debounced API call
                              viewModel.updateStep1PostCode(value);
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Country (read-only)
                          TextFormField(
                            controller: _countryController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              prefixIcon: Icon(Icons.public_outlined),
                              suffixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Region (read-only)
                          TextFormField(
                            controller: _regionController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Region',
                              prefixIcon: Icon(Icons.map_outlined),
                              suffixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // District (editable)
                          TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'District',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            onChanged: viewModel.updateStep1District,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // City
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            onChanged: viewModel.updateStep1City,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Nat Insurance
                          TextFormField(
                            controller: _natInsuranceNoController,
                            decoration: const InputDecoration(
                              labelText: 'National Insurance Number',
                              prefixIcon: Icon(Icons.security_outlined),
                            ),
                            onChanged: viewModel.updateStep1NatInsuranceNo,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Nationality
                          TextFormField(
                            controller: _nationalityController,
                            decoration: const InputDecoration(
                              labelText: 'Nationality',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            onChanged: viewModel.updateStep1Nationality,
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
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: const ['male', 'female', 'other', 'prefer_not_to_say']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: viewModel.updateStep1Gender,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Marital status
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.maritalStatus,
                            decoration: const InputDecoration(
                              labelText: 'Marital Status',
                              prefixIcon: Icon(Icons.family_restroom_outlined),
                            ),
                            items: const ['single', 'married', 'divorced', 'widowed', 'prefer_not_to_say']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: viewModel.updateStep1MaritalStatus,
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
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                                );
                                if (date != null) {
                                  _workPermitExpiryController.text = DateFormat('yyyy-MM-dd').format(date);
                                  viewModel.updateStep1WorkPermitExpiry(_workPermitExpiryController.text);
                                }
                              },
                            ),
                          ],
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Student Visa Hours
                          TextFormField(
                            controller: _studentVisaHoursController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Student Visa Hours Per Week',
                              hintText: '0-168',
                              prefixIcon: Icon(Icons.access_time_outlined),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                viewModel.updateStep1StudentVisaHoursPerWeek(int.tryParse(value));
                              } else {
                                viewModel.updateStep1StudentVisaHoursPerWeek(null);
                              }
                            },
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // Prefer contact
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.preferContact,
                            decoration: const InputDecoration(
                              labelText: 'Preferred Contact Method',
                              prefixIcon: Icon(Icons.contact_mail_outlined),
                            ),
                            items: const ['email', 'sms', 'both']
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: viewModel.updateStep1PreferContact,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                          // User type
                          DropdownButtonFormField<String>(
                            value: viewModel.step1Model.userType,
                            decoration: const InputDecoration(
                              labelText: 'User Type',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            items: const ['merchandisers', 'support_staff', 'drivers', 'team_leaders']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: viewModel.updateStep1UserType,
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                          // Error message
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

                          PrimaryButton(
                            text: widget.isEditMode ? 'Update' : 'Next',
                            isLoading: viewModel.isStepLoading ||
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
