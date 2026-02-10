import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/login_model.dart';
import '../models/registration_progress_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for Login screen following MVVM pattern
class LoginViewModel extends ChangeNotifier {
  LoginModel _loginModel = LoginModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  RegistrationProgressModel? _registrationProgress;
  Map<String, dynamic>? _userData;
  
  // Getters
  LoginModel get loginModel => _loginModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegistrationProgressModel? get registrationProgress => _registrationProgress;
  Map<String, dynamic>? get userData => _userData;
  
  /// Update email
  void updateEmail(String email) {
    _loginModel = _loginModel.copyWith(email: email);
    _errorMessage = null; // Clear error when user types
    notifyListeners();
  }
  
  /// Update password
  void updatePassword(String password) {
    _loginModel = _loginModel.copyWith(password: password);
    _errorMessage = null; // Clear error when user types
    notifyListeners();
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate login form
  String? _validateForm() {
    if (_loginModel.email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_isValidEmail(_loginModel.email)) {
      return 'Please enter a valid email address';
    }
    if (_loginModel.password.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
  
  /// Perform login
  Future<bool> login() async {
    // Validate form
    final validationError = _validateForm();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }
    
    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Prepare request body
      final requestBody = Map<String, dynamic>.from(_loginModel.toJson());

      // Add FCM device token for push notifications
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          requestBody['fcm_token'] = fcmToken;
        }
      } catch (e) {
        debugPrint('[LoginViewModel] Could not get FCM token: $e');
      }

      // Make API call to login endpoint
      final response = await ApiClient.post(
        ApiEndpoints.login,
        body: requestBody,
      );
      
      _isLoading = false;
      
      if (response.isSuccess) {
        // Extract token, user data, and registration progress from response
        final token = response.getField<String>('token');
        final userData = response.getField<Map<String, dynamic>>('user');
        final registrationProgressData = response.getField<Map<String, dynamic>>('registration_progress');

        debugPrint('[LoginViewModel] Login response token: $token');

        if (token != null && token.isNotEmpty) {
          final userStatus = userData?['status']?.toString().toLowerCase().trim();

          // Save token ALWAYS - needed for API calls even when status is pending
          final tokenSaved = await AuthService.saveToken(token);
          
          if (!tokenSaved) {
            _errorMessage = 'Failed to save authentication data. Please try again.';
            notifyListeners();
            return false;
          }
          
          // Save employee ID ALWAYS - needed for API calls
          if (userData != null) {
            final employeeId = userData['id']?.toString();
            if (employeeId != null) {
              await AuthService.saveEmployeeId(employeeId);
            }
          }
          
          // Store user data and registration progress in memory
          _userData = userData;
          
          // Parse registration progress
          if (registrationProgressData != null) {
            try {
              _registrationProgress = RegistrationProgressModel.fromJson(registrationProgressData);
            } catch (e) {
              debugPrint('Failed to parse registration progress: $e');
              _registrationProgress = RegistrationProgressModel.empty();
            }
          } else {
            _registrationProgress = RegistrationProgressModel.empty();
          }

          // SPECIAL CASE: If status is 'pending', DO NOT save status/progress to SharedPreferences
          // But token and employee ID are already saved above for API calls
          if (userStatus == 'pending') {
            // Clear any existing saved status/progress (but keep token and employee ID)
            await AuthService.clearUserStatus();
            await AuthService.clearRegistrationProgress();
            
            debugPrint('[LoginViewModel] Status is pending - token and employee ID saved, but status/progress not persisted');
            notifyListeners();
            return true;
          }

          // Normal flow: Save user status and registration progress to SharedPreferences
          if (userData != null && userStatus != null) {
            await AuthService.saveUserStatus(userStatus);
          }
          
          // Save registration progress
          if (_registrationProgress != null) {
            await AuthService.saveRegistrationProgress(_registrationProgress!);
          }
          
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Invalid response from server. Please try again.';
          notifyListeners();
          return false;
        }
      } else {
        // Handle error response
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Reset form
  void reset() {
    _loginModel = LoginModel.empty();
    _isLoading = false;
    _errorMessage = null;
    _registrationProgress = null;
    _userData = null;
    notifyListeners();
  }
}

