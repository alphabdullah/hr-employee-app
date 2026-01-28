import 'package:flutter/foundation.dart';
import '../models/forgot_password_model.dart';

/// ViewModel for Forgot Password screen following MVVM pattern
class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordModel _forgotPasswordModel = ForgotPasswordModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailSent = false;
  
  // Getters
  ForgotPasswordModel get forgotPasswordModel => _forgotPasswordModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmailSent => _isEmailSent;
  
  /// Update email
  void updateEmail(String email) {
    _forgotPasswordModel = _forgotPasswordModel.copyWith(email: email);
    _errorMessage = null; // Clear error when user types
    notifyListeners();
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate form
  String? _validateForm() {
    if (_forgotPasswordModel.email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!_isValidEmail(_forgotPasswordModel.email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Send password reset email
  Future<bool> sendPasswordResetEmail() async {
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock password reset logic - replace with actual API call
      // In real app, check if email exists in database
      if (_forgotPasswordModel.email == 'notfound@example.com') {
        _errorMessage = 'Email address not found. Please check and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Success - email sent
      _isEmailSent = true;
      _isLoading = false;
      notifyListeners();
      return true;
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
    _forgotPasswordModel = ForgotPasswordModel.empty();
    _isLoading = false;
    _errorMessage = null;
    _isEmailSent = false;
    notifyListeners();
  }
}

