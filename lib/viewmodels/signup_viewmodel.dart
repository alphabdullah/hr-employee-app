import 'package:flutter/foundation.dart';
import '../models/register_flow_models.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for multi-step SignUp screen following MVVM pattern
class SignUpViewModel extends ChangeNotifier {
  // Step tracking
  int _currentStep = 1; // 1, 2, 3, or 4
  String? _registrationToken; // Token from Step 1 response

  // Edit mode flag
  bool _isEditMode = false;

  // Step models
  RegisterStep1Model _step1Model = RegisterStep1Model.empty();
  RegisterStep2Model _step2Model = RegisterStep2Model.empty();
  RegisterStep3Model _step3Model = RegisterStep3Model.empty();
  RegisterStep4Model _step4Model = RegisterStep4Model.empty();

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  bool _isStepLoading = false; // Loading state for individual step submission
  bool _isLoadingProfile = false; // Loading state for profile data

  // Getters
  int get currentStep => _currentStep;
  String? get registrationToken => _registrationToken;
  bool get isEditMode => _isEditMode;
  RegisterStep1Model get step1Model => _step1Model;
  RegisterStep2Model get step2Model => _step2Model;
  RegisterStep3Model get step3Model => _step3Model;
  RegisterStep4Model get step4Model => _step4Model;
  bool get isLoading => _isLoading;
  bool get isStepLoading => _isStepLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get errorMessage => _errorMessage;
  bool get canGoNext => _currentStep < 4;
  bool get canGoBack => _currentStep > 1;

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
    if (_currentStep < 4) {
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
    if (step >= 1 && step <= 4) {
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
    _step1Model = _step1Model.copyWith(latitude: latitude, longitude: longitude);
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_step1Model.email)) {
      return 'Please enter a valid email address';
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

    if (_step1Model.latitude != null && (_step1Model.latitude! < -90 || _step1Model.latitude! > 90)) {
      return 'Latitude must be between -90 and 90';
    }
    if (_step1Model.longitude != null && (_step1Model.longitude! < -180 || _step1Model.longitude! > 180)) {
      return 'Longitude must be between -180 and 180';
    }

    if (_step1Model.studentVisaHoursPerWeek != null &&
        (_step1Model.studentVisaHoursPerWeek! < 0 || _step1Model.studentVisaHoursPerWeek! > 168)) {
      return 'Student visa hours must be between 0 and 168';
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
      if (_step2Model.drivingLicenseNo == null || _step2Model.drivingLicenseNo!.isEmpty) {
        return 'Driving license number is required when driver is selected';
      }
      if (_step2Model.drivingLicenseNo!.length > 100) {
        return 'Driving license number must be maximum 100 characters';
      }
      if (_step2Model.drivingLicenseDate == null || _step2Model.drivingLicenseDate!.isEmpty) {
        return 'Driving license date is required when driver is selected';
      }
    }

    if (_step2Model.criminalRecord == true) {
      if (_step2Model.criminalRecordType == null || _step2Model.criminalRecordType!.isEmpty) {
        return 'Criminal record type is required when criminal record is selected';
      }
      if (_step2Model.criminalRecordType != 'spent' && _step2Model.criminalRecordType != 'unspent') {
        return 'Criminal record type must be "spent" or "unspent"';
      }
    }

    if (_step2Model.registeredDisabled == true) {
      if (_step2Model.disabilityAdjustmentsText == null || _step2Model.disabilityAdjustmentsText!.isEmpty) {
        return 'Disability adjustments text is required when registered disabled is selected';
      }
      if (_step2Model.disabilityDetailsText == null || _step2Model.disabilityDetailsText!.isEmpty) {
        return 'Disability details text is required when registered disabled is selected';
      }
    }

    if (_step2Model.otherCardText != null && _step2Model.otherCardText!.length > 255) {
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
        // Registration complete - save token to AuthService if we used registration token
        // If we used auth token, it's already saved
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

  // ============================================================================
  // Profile Loading for Edit Mode
  // ============================================================================

  /// Load profile data from /api/me endpoint to pre-fill all step forms
  /// This should be called whenever we need to display existing data (edit mode or completing registration)
  Future<void> loadProfileData() async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _isLoadingProfile = false;
        notifyListeners();
        return;
      }

      // Call /api/me endpoint
      debugPrint('Loading /api/me data...');
      final response = await ApiClient.get(
        ApiEndpoints.getMe,
        token: token,
      );

      _isLoadingProfile = false;

      if (response.isSuccess) {
        debugPrint('/api/me response: ${response.data}');
        
        // Parse nested structure from /api/me
        final profileData = response.getField<Map<String, dynamic>>('profile');
        final complianceData = response.getField<Map<String, dynamic>>('compliance');
        final availabilityData = response.getField<Map<String, dynamic>>('availability');
        final bankDetailData = response.getField<Map<String, dynamic>>('bank_detail');
        final email = response.getField<String>('email') ?? '';
        final name = response.getField<String>('name') ?? '';

        // Populate Step 1 model from profile object
        if (profileData != null) {
          _step1Model = RegisterStep1Model(
            name: profileData['name'] ?? name.split(' ').first,
            surname: profileData['surname'] ?? (name.split(' ').length > 1 ? name.split(' ').skip(1).join(' ') : ''),
            email: email,
            password: '', // Don't pre-fill password
            passwordConfirmation: '',
            dob: profileData['dob']?.toString().split('T').first,
            telNo: profileData['tel_no'],
            whatsappNo: profileData['whatsapp_no'],
            address: profileData['address'],
            country: profileData['country'],
            city: profileData['city'],
            latitude: profileData['latitude'] != null ? double.tryParse(profileData['latitude'].toString()) : null,
            longitude: profileData['longitude'] != null ? double.tryParse(profileData['longitude'].toString()) : null,
            postCode: profileData['post_code'],
            natInsuranceNo: profileData['nat_insurance_no'],
            nationality: profileData['nationality'],
            rightToWorkUk: profileData['right_to_work_uk'],
            gender: profileData['gender'],
            maritalStatus: profileData['marital_status'],
            needWorkPermit: profileData['need_work_permit'],
            workPermitExpiry: profileData['work_permit_expiry']?.toString().split('T').first,
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
            drivingLicenseDate: complianceData['driving_license_date']?.toString().split('T').first,
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
            disabilityAdjustmentsText: complianceData['disability_adjustments_text'],
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

        _errorMessage = null;
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
      final jsonBody = _step1Model.toJson(includePassword: _step1Model.password.isNotEmpty);
      
      debugPrint('Updating Step 1 (edit mode): $jsonBody');
      final response = await ApiClient.put(
        ApiEndpoints.updateProfileStep1,
        token: token,
        body: jsonBody,
      );
      debugPrint('Update Step 1 response: ${response.statusCode} ${response.data}');

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
      debugPrint('Update Step 2 response: ${response.statusCode} ${response.data}');

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
      debugPrint('Update Step 3 response: ${response.statusCode} ${response.data}');

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
      debugPrint('Update Step 4 response: ${response.statusCode} ${response.data}');

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
    _isLoading = false;
    _isStepLoading = false;
    _isLoadingProfile = false;
    _errorMessage = null;
    notifyListeners();
  }
}
