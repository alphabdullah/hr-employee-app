import 'package:flutter/foundation.dart';
import '../models/signup_model.dart';
import '../services/api_service.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

/// ViewModel for SignUp screen following MVVM pattern
class SignUpViewModel extends ChangeNotifier {
  SignUpModel _signUpModel = SignUpModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoadingSkills = false;
  List<String> _availableSkills = [];
  
  // Getters
  SignUpModel get signUpModel => _signUpModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoadingSkills => _isLoadingSkills;
  List<String> get availableSkills => _availableSkills;
  
  /// Load available skills from API
  Future<void> loadSkills() async {
    // Try to load from cache first
    if (_availableSkills.isEmpty) {
      final cachedSkills = await CacheService.loadSkills();
      if (cachedSkills != null && cachedSkills.isNotEmpty) {
        _availableSkills = cachedSkills;
        notifyListeners();
        // Continue to refresh in background
      }
    }
    
    // If already loaded from cache, refresh in background
    if (_availableSkills.isNotEmpty) {
      _refreshSkillsInBackground();
      return;
    }
    
    _isLoadingSkills = true;
    notifyListeners();
    
    try {
      // Try to get token (skills endpoint might require auth)
      final token = await AuthService.getToken();
      
      // Call skills API endpoint
      final response = await ApiClient.get(
        ApiEndpoints.getAllSkills,
        queryParameters: {'per_page': '100'}, // Get more skills
        token: token, // Pass token if available, null if not authenticated
      );
      
      _isLoadingSkills = false;
      
      if (response.isSuccess) {
        // Parse skills array from response
        // Response might be: { "skills": [...] } or { "data": [...] }
        List<Map<String, dynamic>>? skillsList = 
            response.getList<Map<String, dynamic>>('skills') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (skillsList != null && skillsList.isNotEmpty) {
          // Extract skill names from the list
          _availableSkills = skillsList
              .map((skill) {
                // Handle different possible field names: 'name', 'skill', 'title'
                return skill['name']?.toString() ?? 
                       skill['skill']?.toString() ?? 
                       skill['title']?.toString();
              })
              .where((name) => name != null && name.isNotEmpty)
              .cast<String>()
              .toList();
          
          // Sort alphabetically
          _availableSkills.sort();
          
          // Save to cache
          await CacheService.saveSkills(_availableSkills);
        } else {
          // Fallback to empty list or default skills if API returns empty
          _availableSkills = [];
        }
      } else {
        // If API fails, use empty list (skills will be empty)
        _availableSkills = [];
        debugPrint('Failed to load skills: ${response.message}');
      }
      
      notifyListeners();
    } catch (e) {
      _isLoadingSkills = false;
      _availableSkills = [];
      debugPrint('Error loading skills: $e');
      notifyListeners();
    }
  }

  /// Refresh skills in background without showing loading indicator
  Future<void> _refreshSkillsInBackground() async {
    try {
      // Try to get token
      final token = await AuthService.getToken();
      
      // Call skills API endpoint silently
      final response = await ApiClient.get(
        ApiEndpoints.getAllSkills,
        queryParameters: {'per_page': '100'},
        token: token,
      );
      
      if (response.isSuccess) {
        List<Map<String, dynamic>>? skillsList = 
            response.getList<Map<String, dynamic>>('skills') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (skillsList != null && skillsList.isNotEmpty) {
          _availableSkills = skillsList
              .map((skill) {
                return skill['name']?.toString() ?? 
                       skill['skill']?.toString() ?? 
                       skill['title']?.toString();
              })
              .where((name) => name != null && name.isNotEmpty)
              .cast<String>()
              .toList();
          
          _availableSkills.sort();
          
          // Save to cache
          await CacheService.saveSkills(_availableSkills);
          
          // Update UI with fresh data
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail background refresh
      debugPrint('Background skills refresh failed: $e');
    }
  }
  
  /// Update full name
  void updateFullName(String fullName) {
    _signUpModel = _signUpModel.copyWith(fullName: fullName);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Update email
  void updateEmail(String email) {
    _signUpModel = _signUpModel.copyWith(email: email);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Update phone number
  void updatePhoneNumber(String phoneNumber) {
    _signUpModel = _signUpModel.copyWith(phoneNumber: phoneNumber);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Update residential address
  void updateResidentialAddress(String address) {
    _signUpModel = _signUpModel.copyWith(residentialAddress: address);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Add skill
  void addSkill(String skill) {
    if (!_signUpModel.skills.contains(skill) && _signUpModel.skills.length < 8) {
      final updatedSkills = List<String>.from(_signUpModel.skills)..add(skill);
      _signUpModel = _signUpModel.copyWith(skills: updatedSkills);
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// Remove skill
  void removeSkill(String skill) {
    final updatedSkills = List<String>.from(_signUpModel.skills)..remove(skill);
    _signUpModel = _signUpModel.copyWith(skills: updatedSkills);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Update password
  void updatePassword(String password) {
    _signUpModel = _signUpModel.copyWith(password: password);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Update confirm password
  void updateConfirmPassword(String confirmPassword) {
    _signUpModel = _signUpModel.copyWith(confirmPassword: confirmPassword);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Validate password according to rules
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    
    if (password.length > 8) {
      return 'Password must be maximum 8 characters';
    }
    
    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    
    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least 1 lowercase letter';
    }
    
    // Check for numeric digit
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least 1 numeric digit';
    }
    
    // Check for special character (@$!%*?&#)
    if (!RegExp(r'[@$!%*?&#]').hasMatch(password)) {
      return 'Password must contain at least 1 special character (@!%*?&#)';
    }
    
    return null;
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate phone number format (basic validation)
  bool _isValidPhoneNumber(String phone) {
    // Remove spaces, dashes, and parentheses
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Check if it contains only digits and has reasonable length (7-15 digits)
    return RegExp(r'^\d{7,15}$').hasMatch(cleaned);
  }
  
  /// Validate signup form
  String? _validateForm() {
    if (_signUpModel.fullName.isEmpty) {
      return 'Please enter your full name';
    }
    if (_signUpModel.fullName.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    
    if (_signUpModel.email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!_isValidEmail(_signUpModel.email)) {
      return 'Please enter a valid email address';
    }
    
    if (_signUpModel.phoneNumber.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!_isValidPhoneNumber(_signUpModel.phoneNumber)) {
      return 'Please enter a valid phone number';
    }
    
    if (_signUpModel.residentialAddress.isEmpty) {
      return 'Please enter your residential address';
    }
    if (_signUpModel.residentialAddress.length < 10) {
      return 'Please enter a complete residential address';
    }
    
    if (_signUpModel.skills.isEmpty) {
      return 'Please select at least one skill';
    }
    if (_signUpModel.skills.length > 8) {
      return 'Maximum 8 skills allowed';
    }
    
    // Validate password
    final passwordError = _validatePassword(_signUpModel.password);
    if (passwordError != null) {
      return passwordError;
    }
    
    // Validate confirm password
    if (_signUpModel.confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (_signUpModel.password != _signUpModel.confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Perform signup
  Future<bool> signUp() async {
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
      // Prepare request body (API expects snake_case)
      final requestBody = _signUpModel.toJson();
      
      // Make API call to register endpoint
      final response = await ApiService.post(
        ApiEndpoints.register,
        body: requestBody,
      );
      
      _isLoading = false;
      
      if (response.success) {
        // Registration successful
        notifyListeners();
        return true;
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
    _signUpModel = SignUpModel.empty();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

