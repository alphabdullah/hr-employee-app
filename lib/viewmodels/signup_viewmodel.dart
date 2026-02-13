import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/register_flow_models.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for multi-step SignUp screen following MVVM pattern
class SignUpViewModel extends ChangeNotifier {
  // Step tracking
  int _currentStep = 1; // 1, 2, 3, 4, or 5
  String? _registrationToken; // Token from Step 1 response

  // Edit mode flag
  bool _isEditMode = false;

  // Step models
  RegisterStep1Model _step1Model = RegisterStep1Model.empty();
  RegisterStep2Model _step2Model = RegisterStep2Model.empty();
  RegisterStep3Model _step3Model = RegisterStep3Model.empty();
  RegisterStep4Model _step4Model = RegisterStep4Model.empty();
  RegisterStep5Model _step5Model = RegisterStep5Model.empty();
  RegisterStep5P46Model _step5P46Model = RegisterStep5P46Model.empty();
  final Map<int, String> _customFieldDocumentUrls = {};

  // Custom fields
  List<CustomFieldModel> _customFields = [];
  bool _hasCustomFields = false;
  bool _isLoadingCustomFields = false;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  bool _isStepLoading = false; // Loading state for individual step submission
  bool _isLoadingProfile = false; // Loading state for profile data
  bool _hasLoadedMeData = false;

  bool _isPostcodeLoading = false;
  bool get isPostcodeLoading => _isPostcodeLoading;

  // Agreement status tracking
  bool _declarationAgreed = false;
  bool _termsConditionsAgreed = false;

  // Getters
  int get currentStep => _currentStep;
  String? get registrationToken => _registrationToken;
  bool get isEditMode => _isEditMode;
  RegisterStep1Model get step1Model => _step1Model;
  RegisterStep2Model get step2Model => _step2Model;
  RegisterStep3Model get step3Model => _step3Model;
  RegisterStep4Model get step4Model => _step4Model;
  RegisterStep5Model get step5Model => _step5Model;
  RegisterStep5P46Model get step5P46Model => _step5P46Model;
  List<CustomFieldModel> get customFields => _customFields;
  bool get hasCustomFields => _hasCustomFields;
  bool get isLoadingCustomFields => _isLoadingCustomFields;
  String? getDocumentUrl(int fieldId) => _customFieldDocumentUrls[fieldId];
  void clearDocumentUrl(int fieldId) {
    if (_customFieldDocumentUrls.containsKey(fieldId)) {
      _customFieldDocumentUrls.remove(fieldId);
      notifyListeners();
    }
  }
  bool get isLoading => _isLoading;
  bool get isStepLoading => _isStepLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get errorMessage => _errorMessage;
  bool get canGoNext {
    if (_hasCustomFields) {
      // Steps: 1-4 (profile, compliance, availability, bank),
      // 5 (P46), 6 (custom fields if enabled)
      return _currentStep < 6;
    }
    // Steps: 1-4 plus P46 as final step
    return _currentStep < 5;
  }

  bool get canGoBack => _currentStep > 1;
  bool get declarationAgreed => _declarationAgreed;
  bool get termsConditionsAgreed => _termsConditionsAgreed;

  // ---------------------------------------------------------------------------
  // STEP 5 P46 helpers (shared setters used by Step 5 screen)
  // ---------------------------------------------------------------------------

  void updateStep5P46NatInsuranceNo(String? value) {
    _step5P46Model = _step5P46Model.copyWith(natInsuranceNo: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46Title(String? value) {
    _step5P46Model = _step5P46Model.copyWith(title: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46Surname(String? value) {
    _step5P46Model = _step5P46Model.copyWith(surname: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46FirstName(String? value) {
    _step5P46Model = _step5P46Model.copyWith(firstName: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46Gender(String? value) {
    _step5P46Model = _step5P46Model.copyWith(gender: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46Dob(String? value) {
    _step5P46Model = _step5P46Model.copyWith(dob: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46Postcode(String? value) {
    _step5P46Model = _step5P46Model.copyWith(postcode: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46HouseFlatNumber(String? value) {
    _step5P46Model = _step5P46Model.copyWith(houseFlatNumber: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46RestOfAddress(String? value) {
    _step5P46Model = _step5P46Model.copyWith(restOfAddress: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46OptionAbc(String? value) {
    _step5P46Model = _step5P46Model.copyWith(optionAbc: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep5P46OptionD(bool? value) {
    _step5P46Model = _step5P46Model.copyWith(optionD: value);
    _errorMessage = null;
    notifyListeners();
  }

  /// Set declaration agreement status
  void setDeclarationAgreed(bool value) {
    _declarationAgreed = value;
    notifyListeners();
  }

  /// Set terms & conditions agreement status
  void setTermsConditionsAgreed(bool value) {
    _termsConditionsAgreed = value;
    notifyListeners();
  }

  /// Set edit mode
  void setEditMode(bool value) {
    _isEditMode = value;
    if (value) {
      // In edit mode, use auth token instead of registration token
      _registrationToken = null;
    }
    notifyListeners();
  }

  /// Navigate to next step
  void nextStep() {
    final maxStep = _hasCustomFields ? 5 : 4;
    if (_currentStep < maxStep) {
      _currentStep++;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    final maxStep = _hasCustomFields ? 6 : 5;
    if (step >= 1 && step <= maxStep) {
      _currentStep = step;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ============================================================================
  // STEP 1: Profile & Account Updates
  // ============================================================================

  void updateStep1Name(String value) {
    _step1Model = _step1Model.copyWith(name: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Surname(String value) {
    _step1Model = _step1Model.copyWith(surname: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Email(String value) {
    _step1Model = _step1Model.copyWith(email: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Password(String value) {
    _step1Model = _step1Model.copyWith(password: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1PasswordConfirmation(String value) {
    _step1Model = _step1Model.copyWith(passwordConfirmation: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Dob(String? value) {
    _step1Model = _step1Model.copyWith(dob: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1TelNo(String? value) {
    _step1Model = _step1Model.copyWith(telNo: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1WhatsappNo(String? value) {
    _step1Model = _step1Model.copyWith(whatsappNo: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Address(String? value) {
    _step1Model = _step1Model.copyWith(address: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Country(String? value) {
    _step1Model = _step1Model.copyWith(country: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1City(String? value) {
    _step1Model = _step1Model.copyWith(city: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Location(double? latitude, double? longitude) {
    _step1Model = _step1Model.copyWith(
      latitude: latitude,
      longitude: longitude,
    );
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1PostCode(String? value) {
    _step1Model = _step1Model.copyWith(postCode: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1NatInsuranceNo(String? value) {
    _step1Model = _step1Model.copyWith(natInsuranceNo: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Nationality(String? value) {
    _step1Model = _step1Model.copyWith(nationality: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1RightToWorkUk(bool? value) {
    _step1Model = _step1Model.copyWith(rightToWorkUk: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1Gender(String? value) {
    _step1Model = _step1Model.copyWith(gender: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1MaritalStatus(String? value) {
    _step1Model = _step1Model.copyWith(maritalStatus: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1NeedWorkPermit(bool? value) {
    _step1Model = _step1Model.copyWith(needWorkPermit: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1WorkPermitExpiry(String? value) {
    _step1Model = _step1Model.copyWith(workPermitExpiry: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1StudentVisaHoursPerWeek(int? value) {
    _step1Model = _step1Model.copyWith(studentVisaHoursPerWeek: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1PreferContact(String? value) {
    _step1Model = _step1Model.copyWith(preferContact: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1UserType(String? value) {
    _step1Model = _step1Model.copyWith(userType: value);
    _errorMessage = null;
    notifyListeners();
  }

  // New update methods
  void updateStep1Region(String? value) {
    _step1Model = _step1Model.copyWith(region: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep1District(String? value) {
    _step1Model = _step1Model.copyWith(district: value);
    _errorMessage = null;
    notifyListeners();
  }

  // Debounce timer for postcode lookup
  Timer? _debounceTimer;

  /// Fetch postcode data from postcodes.io API
  Future<void> fetchPostcodeData(String postcode) async {
    // Cancel existing debounce
    _debounceTimer?.cancel();

    // Debounce: wait 500ms after typing stops
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (postcode.isEmpty) {
        // Clear fields if postcode is cleared
        updateStep1Country(null);
        updateStep1Region(null);
        updateStep1District(null);
        return;
      }

      _isPostcodeLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        final url = 'https://api.postcodes.io/postcodes/$postcode';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final result = data['result'] as Map<String, dynamic>?;

          if (result != null) {
            updateStep1Country(result['country'] as String?);
            updateStep1Region(result['region'] as String?);
            updateStep1District(
              result['admin_district'] as String?,
            ); // Suggest district, user can edit
          } else {
            _errorMessage = 'No data found for this postcode.';
          }
        } else {
          _errorMessage = 'Invalid postcode. Please try again.';
        }
      } catch (e) {
        _errorMessage = 'Network error during postcode lookup: ${e.toString()}';
      } finally {
        _isPostcodeLoading = false;
        notifyListeners();
      }
    });
  }

  /// Validate Step 1
  String? validateStep1() {
    if (_step1Model.name.isEmpty) {
      return 'Please enter your name';
    }
    if (_step1Model.name.length > 255) {
      return 'Name must be maximum 255 characters';
    }

    if (_step1Model.surname.isEmpty) {
      return 'Please enter your surname';
    }
    if (_step1Model.surname.length > 255) {
      return 'Surname must be maximum 255 characters';
    }

    if (_step1Model.email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_step1Model.email)) {
      return 'Please enter a valid email address';
    }

    if (_step1Model.telNo == null || _step1Model.telNo!.trim().isEmpty) {
      return 'Please enter your telephone number';
    }

    if (_step1Model.whatsappNo == null || _step1Model.whatsappNo!.trim().isEmpty) {
      return 'Please enter your WhatsApp number';
    }

    if (_step1Model.postCode == null || _step1Model.postCode!.trim().isEmpty) {
      return 'Please enter your post code';
    }

    if (_step1Model.natInsuranceNo == null ||
        _step1Model.natInsuranceNo!.trim().isEmpty) {
      return 'Please enter your National Insurance number';
    }

    if (_step1Model.nationality == null ||
        _step1Model.nationality!.trim().isEmpty) {
      return 'Please enter your nationality';
    }

    // Password validation - only required in registration mode, optional in edit mode
    if (!_isEditMode) {
      if (_step1Model.password.isEmpty) {
        return 'Please enter a password';
      }
      if (_step1Model.password.length < 8) {
        return 'Password must be at least 8 characters';
      }

      if (_step1Model.passwordConfirmation.isEmpty) {
        return 'Please confirm your password';
      }
      if (_step1Model.password != _step1Model.passwordConfirmation) {
        return 'Passwords do not match';
      }
    } else {
      // In edit mode, if password is provided, validate it
      if (_step1Model.password.isNotEmpty) {
        if (_step1Model.password.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (_step1Model.passwordConfirmation.isNotEmpty &&
            _step1Model.password != _step1Model.passwordConfirmation) {
          return 'Passwords do not match';
        }
        // If password is provided, confirmation is required
        if (_step1Model.passwordConfirmation.isEmpty) {
          return 'Please confirm your password';
        }
      }
    }

    // Require location mark
    if (_step1Model.latitude == null || _step1Model.longitude == null) {
      return 'Please mark your location on the map';
    }

    if (_step1Model.latitude! < -90 || _step1Model.latitude! > 90) {
      return 'Latitude must be between -90 and 90';
    }
    if (_step1Model.longitude! < -180 || _step1Model.longitude! > 180) {
      return 'Longitude must be between -180 and 180';
    }

    // City required
    if (_step1Model.city == null || _step1Model.city!.trim().isEmpty) {
      return 'Please enter your city';
    }

    // If student visa hours are provided, validate range
    if (_step1Model.studentVisaHoursPerWeek != null &&
        (_step1Model.studentVisaHoursPerWeek! < 0 ||
            _step1Model.studentVisaHoursPerWeek! > 168)) {
      return 'Student visa hours must be between 0 and 168';
    }

    // If user needs work permit, expiry date is required
    if (_step1Model.needWorkPermit == true &&
        (_step1Model.workPermitExpiry == null ||
            _step1Model.workPermitExpiry!.isEmpty)) {
      return 'Please select your work permit expiry date';
    }

    return null;
  }

  /// Submit Step 1 - Create account & profile (or update if in edit mode)
  Future<bool> submitStep1() async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep1();
    }

    final validationError = validateStep1();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step1Model.toJson();
      debugPrint('Submitting Step 1: $payload');
      final response = await ApiClient.post(
        ApiEndpoints.registerStep1,
        body: payload,
      );
      debugPrint('Step 1 response: ${response.statusCode} ${response.data}');

      _isStepLoading = false;

      if (response.isSuccess) {
        // Extract token from response
        _registrationToken = response.getField<String>('token');
        if (_registrationToken == null || _registrationToken!.isEmpty) {
          _errorMessage = 'Registration successful but no token received';
          notifyListeners();
          return false;
        }

        // Save token temporarily (will be used for steps 2-4)
        // Don't save to AuthService yet - user hasn't fully registered
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ============================================================================
  // STEP 2: Compliance Updates
  // ============================================================================

  void updateStep2IsDriver(bool? value) {
    _step2Model = _step2Model.copyWith(isDriver: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2DrivingLicenseNo(String? value) {
    _step2Model = _step2Model.copyWith(drivingLicenseNo: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2DrivingLicenseDate(String? value) {
    _step2Model = _step2Model.copyWith(drivingLicenseDate: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2OwnCar(bool? value) {
    _step2Model = _step2Model.copyWith(ownCar: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2CriminalRecord(bool? value) {
    _step2Model = _step2Model.copyWith(criminalRecord: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2CriminalRecordType(String? value) {
    _step2Model = _step2Model.copyWith(criminalRecordType: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2Cscs(bool? value) {
    _step2Model = _step2Model.copyWith(cscs: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2Sia(bool? value) {
    _step2Model = _step2Model.copyWith(sia: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2Mhe(bool? value) {
    _step2Model = _step2Model.copyWith(mhe: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2Cis(bool? value) {
    _step2Model = _step2Model.copyWith(cis: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2FirstAid(bool? value) {
    _step2Model = _step2Model.copyWith(firstAid: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2OtherCardText(String? value) {
    _step2Model = _step2Model.copyWith(otherCardText: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2RegisteredDisabled(bool? value) {
    _step2Model = _step2Model.copyWith(registeredDisabled: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2DisabilityAdjustmentsText(String? value) {
    _step2Model = _step2Model.copyWith(disabilityAdjustmentsText: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep2DisabilityDetailsText(String? value) {
    _step2Model = _step2Model.copyWith(disabilityDetailsText: value);
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate Step 2
  String? validateStep2() {
    if (_step2Model.isDriver == true) {
      if (_step2Model.drivingLicenseNo == null ||
          _step2Model.drivingLicenseNo!.isEmpty) {
        return 'Driving license number is required when driver is selected';
      }
      if (_step2Model.drivingLicenseNo!.length > 100) {
        return 'Driving license number must be maximum 100 characters';
      }
      if (_step2Model.drivingLicenseDate == null ||
          _step2Model.drivingLicenseDate!.isEmpty) {
        return 'Driving license date is required when driver is selected';
      }
    }

    if (_step2Model.criminalRecord == true) {
      if (_step2Model.criminalRecordType == null ||
          _step2Model.criminalRecordType!.isEmpty) {
        return 'Criminal record type is required when criminal record is selected';
      }
      if (_step2Model.criminalRecordType != 'spent' &&
          _step2Model.criminalRecordType != 'unspent') {
        return 'Criminal record type must be "spent" or "unspent"';
      }
    }

    if (_step2Model.registeredDisabled == true) {
      if (_step2Model.disabilityAdjustmentsText == null ||
          _step2Model.disabilityAdjustmentsText!.isEmpty) {
        return 'Disability adjustments text is required when registered disabled is selected';
      }
      if (_step2Model.disabilityDetailsText == null ||
          _step2Model.disabilityDetailsText!.isEmpty) {
        return 'Disability details text is required when registered disabled is selected';
      }
    }

    if (_step2Model.otherCardText != null &&
        _step2Model.otherCardText!.length > 255) {
      return 'Other card text must be maximum 255 characters';
    }

    return null;
  }

  /// Submit Step 2 - Compliance (or update if in edit mode)
  Future<bool> submitStep2() async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep2();
    }

    // Use registration token if available, otherwise try auth token (for logged-in users completing steps)
    String? tokenToUse = _registrationToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      tokenToUse = await AuthService.getToken();
      if (tokenToUse == null || tokenToUse.isEmpty) {
        _errorMessage = 'Please complete Step 1 first or login';
        notifyListeners();
        return false;
      }
    }

    final validationError = validateStep2();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step2Model.toJson();
      debugPrint('Submitting Step 2: $payload');
      final response = await ApiClient.post(
        ApiEndpoints.registerStep2,
        token: tokenToUse,
        body: payload,
      );
      debugPrint('Step 2 response: ${response.statusCode} ${response.data}');

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // STEP 3: Availability Updates
  // ============================================================================

  void updateStep3DayDays(List<String> days) {
    _step3Model = _step3Model.copyWith(dayDays: days);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep3NightDays(List<String> days) {
    _step3Model = _step3Model.copyWith(nightDays: days);
    _errorMessage = null;
    notifyListeners();
  }

  void toggleStep3DayDay(String day) {
    final currentDays = List<String>.from(_step3Model.dayDays);
    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
    }
    updateStep3DayDays(currentDays);
  }

  void toggleStep3NightDay(String day) {
    final currentDays = List<String>.from(_step3Model.nightDays);
    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
    }
    updateStep3NightDays(currentDays);
  }

  /// Submit Step 3 - Availability (or update if in edit mode)
  Future<bool> submitStep3() async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep3();
    }

    String? tokenToUse = _registrationToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      tokenToUse = await AuthService.getToken();
      if (tokenToUse == null || tokenToUse.isEmpty) {
        _errorMessage = 'Please complete Step 1 first';
        notifyListeners();
        return false;
      }
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step3Model.toJson();
      debugPrint('Submitting Step 3: $payload');
      final response = await ApiClient.post(
        ApiEndpoints.registerStep3,
        token: tokenToUse,
        body: payload,
      );
      debugPrint('Step 3 response: ${response.statusCode} ${response.data}');

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // STEP 4: Bank Details Updates
  // ============================================================================

  void updateStep4AccountHolder(String? value) {
    _step4Model = _step4Model.copyWith(accountHolder: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep4BankName(String? value) {
    _step4Model = _step4Model.copyWith(bankName: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep4BankTown(String? value) {
    _step4Model = _step4Model.copyWith(bankTown: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep4AccountNumber(String? value) {
    _step4Model = _step4Model.copyWith(accountNumber: value);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStep4SortCode(String? value) {
    _step4Model = _step4Model.copyWith(sortCode: value);
    _errorMessage = null;
    notifyListeners();
  }

  /// Submit Step 4 - Bank Details (Final Step) (or update if in edit mode)
  Future<bool> submitStep4() async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep4();
    }

    // Use registration token if available, otherwise try auth token (for logged-in users completing steps)
    String? tokenToUse = _registrationToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      tokenToUse = await AuthService.getToken();
      if (tokenToUse == null || tokenToUse.isEmpty) {
        _errorMessage = 'Please complete Step 1 first or login';
        notifyListeners();
        return false;
      }
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step4Model.toJson();
      debugPrint('Submitting Step 4: $payload');
      final response = await ApiClient.post(
        ApiEndpoints.registerStep4,
        token: tokenToUse,
        body: payload,
      );
      debugPrint('Step 4 response: ${response.statusCode} ${response.data}');

      _isStepLoading = false;

      if (response.isSuccess) {
        // Don't complete registration here - let Step 4 screen check for custom fields
        // and navigate accordingly. The registration will be completed in Step 5 if it exists,
        // or in Step 4 screen if no custom fields exist.
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // STEP 5: P46 Tax Details & STEP 6: Custom Fields
  // ============================================================================

  // ---------------------------
  // P46 (register/step-5) data
  // ---------------------------

  /// Submit Step 5 - P46 Tax Details (Employee without a P45)
  Future<bool> submitStep5P46() async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep5P46();
    }

    // Use registration token if available, otherwise try auth token
    String? tokenToUse = _registrationToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      tokenToUse = await AuthService.getToken();
      if (tokenToUse == null || tokenToUse.isEmpty) {
        _errorMessage = 'Please complete Step 1 first or login';
        notifyListeners();
        return false;
      }
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step5P46Model.toJson();
      debugPrint('Submitting Step 5 (P46): $payload');

      final response = await ApiClient.post(
        ApiEndpoints.registerStep5,
        token: tokenToUse,
        body: payload,
      );
      debugPrint(
        'Step 5 (P46) response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Step 5 - P46 Tax Details (Edit Mode)
  Future<bool> updateStep5P46() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      _errorMessage = 'Please login to update tax details';
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step5P46Model.toJson();
      debugPrint('Updating Step 5 (P46): $payload');

      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep5,
        token: token,
        body: payload,
      );
      debugPrint(
        'Update Step 5 (P46) response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------
  // Custom fields (Profile extra)
  // ---------------------------

  /// Fetch custom fields from API
  Future<void> fetchCustomFields({bool forceRefresh = false}) async {
    // Don't fetch again if already loaded and has fields (unless force refresh)
    if (!forceRefresh && _customFields.isNotEmpty && _hasCustomFields) {
      debugPrint(
        'Custom fields already loaded (${_customFields.length} fields), skipping fetch',
      );
      return;
    }

    _isLoadingCustomFields = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token - use registration token if available, otherwise try auth token
      String? tokenToUse = _registrationToken;
      if (tokenToUse == null || tokenToUse.isEmpty) {
        tokenToUse = await AuthService.getToken();
      }

      final url = ApiEndpoints.buildUrl(ApiEndpoints.getCustomFields);
      debugPrint('Fetching custom fields from: $url');
      debugPrint(
        'Using token: ${tokenToUse != null ? "Yes (${tokenToUse.substring(0, 20)}...)" : "No"}',
      );

      final response = await ApiClient.get(
        ApiEndpoints.getCustomFields,
        token: tokenToUse,
      );
      debugPrint('Custom fields response status: ${response.statusCode}');
      debugPrint('Custom fields response isSuccess: ${response.isSuccess}');
      debugPrint('Custom fields response data: ${response.data}');
      debugPrint(
        'Custom fields response data type: ${response.data.runtimeType}',
      );

      _isLoadingCustomFields = false;

      if (response.isSuccess) {
        final data = response.data;
        List<dynamic> fieldsList = [];

        // Handle response structure - data is always a Map<String, dynamic>
        // Response format: {"profile_fields": [...]} or {"data": {"profile_fields": [...]}}
        debugPrint('Response data type: ${data.runtimeType}');
        debugPrint('Response data keys: ${data.keys.toList()}');
        debugPrint('Full response data: $data');

        // Check if response is wrapped in 'data' key
        Map<String, dynamic> dataToUse = data;
        if (data.containsKey('data') && data['data'] is Map) {
          dataToUse = data['data'] as Map<String, dynamic>;
          debugPrint(
            'Response wrapped in data key, unwrapped keys: ${dataToUse.keys.toList()}',
          );
        }

        final profileFieldsValue = dataToUse['profile_fields'];
        debugPrint('profile_fields value: $profileFieldsValue');
        debugPrint('profile_fields type: ${profileFieldsValue.runtimeType}');

        if (profileFieldsValue is List) {
          fieldsList = profileFieldsValue;
          debugPrint('Found ${fieldsList.length} custom fields');
          if (fieldsList.isNotEmpty) {
            debugPrint('First field: ${fieldsList[0]}');
          }
        } else {
          debugPrint(
            'profile_fields is not a List, it is: ${profileFieldsValue.runtimeType}',
          );
          debugPrint('profile_fields value: $profileFieldsValue');
        }

        // Sort fields by sort_order
        try {
          _customFields = fieldsList.map((field) {
            try {
              debugPrint('Parsing field: $field');
              final parsedField = CustomFieldModel.fromJson(
                field as Map<String, dynamic>,
              );
              debugPrint(
                'Parsed field - id: ${parsedField.id}, label: ${parsedField.label}, type: ${parsedField.type}',
              );
              return parsedField;
            } catch (e) {
              debugPrint('Error parsing field: $e, field data: $field');
              rethrow;
            }
          }).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          _hasCustomFields = _customFields.isNotEmpty;
          debugPrint(
            '✅ Custom fields loaded successfully: ${_customFields.length} fields',
          );
          debugPrint('✅ hasCustomFields flag: $_hasCustomFields');
          if (_customFields.isNotEmpty) {
            debugPrint(
              '✅ Field labels: ${_customFields.map((f) => f.label).join(", ")}',
            );
          }
          _errorMessage = null;
          notifyListeners();
        } catch (e) {
          debugPrint('❌ Error processing custom fields: $e');
          _customFields = [];
          _hasCustomFields = false;
          _errorMessage = null;
          notifyListeners();
        }
      } else {
        // If API returns error or empty, assume no custom fields
        debugPrint(
          'API returned error or not success. Message: ${response.message}',
        );
        _customFields = [];
        _hasCustomFields = false;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _isLoadingCustomFields = false;
      // On error, assume no custom fields (don't block registration)
      _customFields = [];
      _hasCustomFields = false;
      debugPrint('Error fetching custom fields: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  void updateStep5Field(int fieldId, dynamic value) {
    _step5Model.setFieldValue(fieldId, value);
    _errorMessage = null;
    notifyListeners();
  }

  /// Submit Step 5 - Custom Fields (Final Step if custom fields exist)
  Future<bool> submitStep5({Map<int, File>? files}) async {
    // If in edit mode, use update method instead
    if (_isEditMode) {
      return await updateStep5(files: files);
    }

    // Use registration token if available, otherwise try auth token
    String? tokenToUse = _registrationToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      tokenToUse = await AuthService.getToken();
      if (tokenToUse == null || tokenToUse.isEmpty) {
        _errorMessage = 'Please complete Step 1 first or login';
        notifyListeners();
        return false;
      }
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step5Model.toJson();
      debugPrint('Submitting Step 5: $payload');

      // Convert files map from field ID to field name format (fields[<id>])
      Map<String, File>? filesForApi;
      if (files != null && files.isNotEmpty) {
        filesForApi = {};
        for (var entry in files.entries) {
          filesForApi['fields[${entry.key}]'] = entry.value;
        }
      }

      // Separate text fields from file fields
      // Get list of document field IDs to exclude from text payload
      final documentFieldIds = _customFields
          .where((f) => f.type.toLowerCase() == 'document')
          .map((f) => f.id)
          .toSet();

      final formFields = <String, String>{};
      for (var entry in payload.entries) {
        // Extract field ID from key format "fields[<id>]"
        final match = RegExp(r'fields\[(\d+)\]').firstMatch(entry.key);
        if (match != null) {
          final fieldId = int.parse(match.group(1)!);
          // Skip document fields (they'll be added as files)
          if (!documentFieldIds.contains(fieldId) &&
              (filesForApi == null || !filesForApi.containsKey(entry.key))) {
            formFields[entry.key] = entry.value.toString();
          }
        }
      }

      // Always use multipart POST (API expects form-data)
      final response = await ApiClient.postMultipart(
        ApiEndpoints.profileExtra,
        token: tokenToUse,
        fields: formFields,
        files: filesForApi,
      );
      debugPrint('Step 5 response: ${response.statusCode} ${response.data}');

      _isStepLoading = false;

      if (response.isSuccess) {
        // Registration complete - save token to AuthService if we used registration token
        if (_registrationToken != null && _registrationToken!.isNotEmpty) {
          await AuthService.saveToken(_registrationToken!);
        }
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Step 5 - Custom Fields (for edit mode)
  Future<bool> updateStep5({Map<int, File>? files}) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      _errorMessage = 'Please login to update custom fields';
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _step5Model.toJson();
      debugPrint('Updating Step 5: $payload');

      // Convert files map from field ID to field name format (fields[<id>])
      Map<String, File>? filesForApi;
      if (files != null && files.isNotEmpty) {
        filesForApi = {};
        for (var entry in files.entries) {
          filesForApi['fields[${entry.key}]'] = entry.value;
        }
      }

      // Separate text fields from file fields
      // Get list of document field IDs to exclude from text payload
      final documentFieldIds = _customFields
          .where((f) => f.type.toLowerCase() == 'document')
          .map((f) => f.id)
          .toSet();

      final formFields = <String, String>{};
      for (var entry in payload.entries) {
        // Extract field ID from key format "fields[<id>]"
        final match = RegExp(r'fields\[(\d+)\]').firstMatch(entry.key);
        if (match != null) {
          final fieldId = int.parse(match.group(1)!);
          // Skip document fields (they'll be added as files)
          if (!documentFieldIds.contains(fieldId) &&
              (filesForApi == null || !filesForApi.containsKey(entry.key))) {
            formFields[entry.key] = entry.value.toString();
          }
        }
      }

      // Always use multipart POST (API expects form-data, only POST is supported)
      final response = await ApiClient.postMultipart(
        ApiEndpoints.profileExtra,
        token: token,
        fields: formFields,
        files: filesForApi,
      );
      debugPrint(
        'Update Step 5 response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // Profile Loading for Edit Mode
  // ============================================================================

  /// Load profile data from /api/me endpoint to pre-fill all step forms
  /// This should be called whenever we need to display existing data (edit mode or completing registration)
  Future<void> loadProfileData() async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    if (_hasLoadedMeData) {
      _isLoadingProfile = false;
      notifyListeners();
      return;
    }

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _isLoadingProfile = false;
        notifyListeners();
        return;
      }

      // Call /api/me endpoint
      debugPrint('Loading /api/me data...');
      final response = await ApiClient.get(ApiEndpoints.getMe, token: token);

      _isLoadingProfile = false;

      if (response.isSuccess) {
        debugPrint('/api/me response: ${response.data}');

        // Full raw data map for additional sections (registration_step5, profile_extra, etc.)
        final rawData = response.data;

        // Parse nested structure from /api/me
        final profileData = response.getField<Map<String, dynamic>>('profile');
        final complianceData = response.getField<Map<String, dynamic>>(
          'compliance',
        );
        final availabilityData = response.getField<Map<String, dynamic>>(
          'availability',
        );
        final bankDetailData = response.getField<Map<String, dynamic>>(
          'bank_detail',
        );
        final email = response.getField<String>('email') ?? '';
        final name = response.getField<String>('name') ?? '';

        // Populate Step 1 model from profile object
        if (profileData != null) {
          _step1Model = RegisterStep1Model(
            name: profileData['name'] ?? name.split(' ').first,
            surname:
                profileData['surname'] ??
                (name.split(' ').length > 1
                    ? name.split(' ').skip(1).join(' ')
                    : ''),
            email: email,
            password: '', // Don't pre-fill password
            passwordConfirmation: '',
            dob: profileData['dob']?.toString().split('T').first,
            telNo: profileData['tel_no'],
            whatsappNo: profileData['whatsapp_no'],
            address: profileData['address'],
            country: profileData['country'],
            city: profileData['city'],
            latitude: profileData['latitude'] != null
                ? double.tryParse(profileData['latitude'].toString())
                : null,
            longitude: profileData['longitude'] != null
                ? double.tryParse(profileData['longitude'].toString())
                : null,
            postCode: profileData['post_code'],
            natInsuranceNo: profileData['nat_insurance_no'],
            nationality: profileData['nationality'],
            rightToWorkUk: profileData['right_to_work_uk'],
            gender: profileData['gender'],
            maritalStatus: profileData['marital_status'],
            needWorkPermit: profileData['need_work_permit'],
            workPermitExpiry: profileData['work_permit_expiry']
                ?.toString()
                .split('T')
                .first,
            studentVisaHoursPerWeek: profileData['student_visa_hours_per_week'],
            preferContact: profileData['prefer_contact'],
            userType: profileData['user_type'],
          );
        }

        // Populate Step 2 model from compliance object
        if (complianceData != null) {
          _step2Model = RegisterStep2Model(
            isDriver: complianceData['is_driver'],
            drivingLicenseNo: complianceData['driving_license_no'],
            drivingLicenseDate: complianceData['driving_license_date']
                ?.toString()
                .split('T')
                .first,
            ownCar: complianceData['own_car'],
            criminalRecord: complianceData['criminal_record'],
            criminalRecordType: complianceData['criminal_record_type'],
            cscs: complianceData['cscs'] ?? false,
            sia: complianceData['sia'] ?? false,
            mhe: complianceData['mhe'] ?? false,
            cis: complianceData['cis'] ?? false,
            firstAid: complianceData['first_aid'] ?? false,
            otherCardText: complianceData['other_card_text'],
            registeredDisabled: complianceData['registered_disabled'],
            disabilityAdjustmentsText:
                complianceData['disability_adjustments_text'],
            disabilityDetailsText: complianceData['disability_details_text'],
          );
        }

        // Populate Step 3 model from availability object
        if (availabilityData != null) {
          _step3Model = RegisterStep3Model(
            dayDays: List<String>.from(availabilityData['day_days'] ?? []),
            nightDays: List<String>.from(availabilityData['night_days'] ?? []),
          );
        }

        // Populate Step 4 model from bank_detail object
        if (bankDetailData != null) {
          _step4Model = RegisterStep4Model(
            accountHolder: bankDetailData['account_holder'],
            bankName: bankDetailData['bank_name'],
            bankTown: bankDetailData['bank_town'],
            accountNumber: bankDetailData['account_number'],
            sortCode: bankDetailData['sort_code'],
          );
        }

        // Populate Step 5 (P46) model from registration_step5 object
        final registrationStep5Data =
            rawData['registration_step5'] as Map<String, dynamic>?;
        if (registrationStep5Data != null) {
          debugPrint('Parsing registration_step5: $registrationStep5Data');
          _step5P46Model = RegisterStep5P46Model(
            natInsuranceNo: registrationStep5Data['nat_insurance_no'],
            title: registrationStep5Data['title'],
            surname: registrationStep5Data['surname'],
            firstName: registrationStep5Data['first_name'],
            gender: registrationStep5Data['gender'],
            dob: registrationStep5Data['dob']
                ?.toString()
                .split('T')
                .first,
            postcode: registrationStep5Data['postcode'],
            houseFlatNumber: registrationStep5Data['house_flat_number'],
            restOfAddress: registrationStep5Data['rest_of_address'],
            optionAbc: registrationStep5Data['option_abc'],
            optionD: registrationStep5Data['option_d'] as bool?,
          );
        }

        // Populate Step 6 (custom fields) values from profile_extra array
        final profileExtraData = rawData['profile_extra'];
        if (profileExtraData is List) {
          debugPrint('Parsing profile_extra: $profileExtraData');
          // Reset custom field values map
          _step5Model = RegisterStep5Model.empty();
          _customFieldDocumentUrls.clear();

          for (final item in profileExtraData) {
            if (item is! Map<String, dynamic>) continue;

            final fieldId = item['field_id'];
            if (fieldId is! int) continue;

            final type = (item['type'] as String?)?.toLowerCase() ?? '';
            if (type == 'text') {
              final value = item['value']?.toString();
              if (value != null && value.isNotEmpty) {
                _step5Model.setFieldValue(fieldId, value);
              }
            } else if (type == 'document') {
              // For document fields, store file name for display purposes
              final fileName = item['file_name']?.toString();
              if (fileName != null && fileName.isNotEmpty) {
                _step5Model.setFieldValue(fieldId, fileName);
              }
              final fileUrl = item['file_url']?.toString();
              if (fileUrl != null && fileUrl.isNotEmpty) {
                _customFieldDocumentUrls[fieldId] = fileUrl;
              } else {
                _customFieldDocumentUrls.remove(fieldId);
              }
            }
          }
        }

        _errorMessage = null;
        _hasLoadedMeData = true;
        debugPrint('Profile data loaded successfully');
      } else {
        _errorMessage = response.message;
        debugPrint('Failed to load profile data: ${response.message}');
      }

      notifyListeners();
    } catch (e) {
      _isLoadingProfile = false;
      _errorMessage = 'Failed to load profile data. Please try again.';
      debugPrint('Error loading profile data: $e');
      notifyListeners();
    }
  }

  Future<void> refreshProfileData() async {
    _hasLoadedMeData = false;
    await loadProfileData();
  }

  // ============================================================================
  // Update Methods for Edit Mode (PUT endpoints)
  // ============================================================================

  /// Update Step 1 - Profile (Edit Mode)
  Future<bool> updateStep1() async {
    if (!_isEditMode) {
      return await submitStep1();
    }

    final validationError = validateStep1();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isStepLoading = false;
        notifyListeners();
        return false;
      }

      // Build JSON - only include password if provided
      final jsonBody = _step1Model.toJson(
        includePassword: _step1Model.password.isNotEmpty,
      );

      debugPrint('Updating Step 1 (edit mode): $jsonBody');
      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep1,
        token: token,
        body: jsonBody,
      );
      debugPrint(
        'Update Step 1 response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        // Reload profile data to get latest from server
        await loadProfileData();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Step 2 - Compliance (Edit Mode)
  Future<bool> updateStep2() async {
    if (!_isEditMode) {
      return await submitStep2();
    }

    final validationError = validateStep2();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isStepLoading = false;
        notifyListeners();
        return false;
      }

      final payload = _step2Model.toJson();
      debugPrint('Updating Step 2 (edit mode): $payload');
      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep2,
        token: token,
        body: payload,
      );
      debugPrint(
        'Update Step 2 response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        // Reload profile data to get latest from server
        await loadProfileData();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Step 3 - Availability (Edit Mode)
  Future<bool> updateStep3() async {
    if (!_isEditMode) {
      return await submitStep3();
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isStepLoading = false;
        notifyListeners();
        return false;
      }

      final payload = _step3Model.toJson();
      debugPrint('Updating Step 3 (edit mode): $payload');
      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep3,
        token: token,
        body: payload,
      );
      debugPrint(
        'Update Step 3 response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        // Reload profile data to get latest from server
        await loadProfileData();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Step 4 - Bank Details (Edit Mode)
  Future<bool> updateStep4() async {
    if (!_isEditMode) {
      return await submitStep4();
    }

    _isStepLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isStepLoading = false;
        notifyListeners();
        return false;
      }

      final payload = _step4Model.toJson();
      debugPrint('Updating Step 4 (edit mode): $payload');
      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep4,
        token: token,
        body: payload,
      );
      debugPrint(
        'Update Step 4 response: ${response.statusCode} ${response.data}',
      );

      _isStepLoading = false;

      if (response.isSuccess) {
        _errorMessage = null;
        // Reload profile data to get latest from server
        await loadProfileData();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isStepLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // General Methods
  // ============================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all registration data
  void reset() {
    _currentStep = 1;
    _registrationToken = null;
    _isEditMode = false;
    _step1Model = RegisterStep1Model.empty();
    _step2Model = RegisterStep2Model.empty();
    _step3Model = RegisterStep3Model.empty();
    _step4Model = RegisterStep4Model.empty();
    _step5Model = RegisterStep5Model.empty();
    _step5P46Model = RegisterStep5P46Model.empty();
    _customFields = [];
    _hasCustomFields = false;
    _isLoadingCustomFields = false;
    _declarationAgreed = false;
    _termsConditionsAgreed = false;
    _isLoading = false;
    _isStepLoading = false;
    _isLoadingProfile = false;
    _errorMessage = null;
    _hasLoadedMeData = false;
    _isPostcodeLoading = false;
    notifyListeners();
  }
}
