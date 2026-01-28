import 'package:flutter/foundation.dart';
import '../models/login_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for Login screen following MVVM pattern
class LoginViewModel extends ChangeNotifier {
  LoginModel _loginModel = LoginModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  LoginModel get loginModel => _loginModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
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
      final requestBody = _loginModel.toJson();
      
      // Make API call to login endpoint
      final response = await ApiClient.post(
        ApiEndpoints.login,
        body: requestBody,
      );
      
      _isLoading = false;
      
      if (response.isSuccess) {
        // Extract token and employee data from response
        final token = response.getField<String>('token');
        final employeeData = response.getField<Map<String, dynamic>>('employee');
        
        if (token != null && token.isNotEmpty) {
          // Save token
          final tokenSaved = await AuthService.saveToken(token);
          
          // Save employee ID if available
          if (employeeData != null) {
            final employeeId = employeeData['id']?.toString();
            if (employeeId != null) {
              await AuthService.saveEmployeeId(employeeId);
            }
          }
          
          if (tokenSaved) {
            notifyListeners();
            return true;
          } else {
            _errorMessage = 'Failed to save authentication data. Please try again.';
            notifyListeners();
            return false;
          }
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
    notifyListeners();
  }
}

