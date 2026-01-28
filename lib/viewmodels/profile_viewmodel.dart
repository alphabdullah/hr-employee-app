import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

/// ViewModel for Profile screen following MVVM pattern
class ProfileViewModel extends ChangeNotifier {
  ProfileModel _profile = ProfileModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImageFile;
  bool _isLoadingSkills = false;
  List<String> _availableSkills = [];
  bool _hasLoadedProfile = false; // Track if profile has been loaded at least once

  ProfileModel get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoadingSkills => _isLoadingSkills;
  List<String> get availableSkills => _availableSkills;
  File? get selectedImageFile => _selectedImageFile;
  
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
      // Get authentication token
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
          // Fallback to empty list if API returns empty
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
      // Get authentication token
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

  /// Load profile data from API
  /// 
  /// [forceRefresh] - If true, always fetch from API. If false and data exists, show cached data and refresh in background.
  Future<void> loadProfile({bool forceRefresh = false}) async {
    // Try to load from disk cache first (if not forcing refresh)
    if (!forceRefresh && _profile.name.isEmpty) {
      final cachedProfile = await CacheService.loadProfile();
      if (cachedProfile != null) {
        try {
          _profile = ProfileModel.fromJson(cachedProfile);
          _hasLoadedProfile = true;
          _errorMessage = null;
          notifyListeners();
          // Continue to refresh in background
        } catch (e) {
          debugPrint('Failed to parse cached profile: $e');
        }
      }
    }
    
    // If we have cached data (in-memory or disk) and not forcing refresh, refresh in background
    if (!forceRefresh && _hasLoadedProfile && _profile.name.isNotEmpty) {
      // Show cached data immediately (already in state)
      // Refresh in background without blocking UI
      _refreshProfileInBackground();
      return;
    }
    
    // First time loading or force refresh - show loading indicator
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Call profile API endpoint
      final response = await ApiClient.get(
        ApiEndpoints.getProfile,
        token: token,
      );

      _isLoading = false;
      _hasLoadedProfile = true;

      if (response.isSuccess) {
        // Parse employee data from response
        final employeeData = response.getField<Map<String, dynamic>>('employee');
        
        if (employeeData != null) {
          // Create ProfileModel from API response
          _profile = ProfileModel.fromJson({'employee': employeeData});
          // Clear selected image file when loading from API (API data takes precedence)
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        } else {
          // Try parsing the entire response as employee data
          _profile = ProfileModel.fromJson(response.data);
          // Clear selected image file when loading from API
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        }
      } else {
        _errorMessage = response.message;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load profile. Please try again.';
      notifyListeners();
    }
  }

  /// Refresh profile in background without showing loading indicator
  Future<void> _refreshProfileInBackground() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        return;
      }

      // Call profile API endpoint silently
      final response = await ApiClient.get(
        ApiEndpoints.getProfile,
        token: token,
      );

      if (response.isSuccess) {
        // Parse employee data from response
        final employeeData = response.getField<Map<String, dynamic>>('employee');
        
        if (employeeData != null) {
          // Update profile with fresh data from API
          _profile = ProfileModel.fromJson({'employee': employeeData});
          // Clear selected image file when loading from API
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        } else {
          // Try parsing the entire response as employee data
          _profile = ProfileModel.fromJson(response.data);
          // Clear selected image file when loading from API
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        }
        
        // Update UI with fresh data
        notifyListeners();
      }
    } catch (e) {
      // Silently fail background refresh
      debugPrint('Background profile refresh failed: $e');
    }
  }

  /// Update name
  void updateName(String name) {
    _profile = _profile.copyWith(name: name);
    _errorMessage = null;
    notifyListeners();
  }

  /// Update email
  void updateEmail(String email) {
    _profile = _profile.copyWith(email: email);
    _errorMessage = null;
    notifyListeners();
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber) {
    _profile = _profile.copyWith(phoneNumber: phoneNumber);
    _errorMessage = null;
    notifyListeners();
  }

  /// Update residential address
  void updateResidentialAddress(String address) {
    _profile = _profile.copyWith(residentialAddress: address);
    _errorMessage = null;
    notifyListeners();
  }

  /// Add skill
  void addSkill(String skill) {
    if (_profile.skills.length >= 8) return;
    if (_profile.skills.contains(skill)) return;
    final updated = List<String>.from(_profile.skills)..add(skill);
    _profile = _profile.copyWith(skills: updated);
    notifyListeners();
  }

  /// Remove skill
  void removeSkill(String skill) {
    final updated = List<String>.from(_profile.skills)..remove(skill);
    _profile = _profile.copyWith(skills: updated);
    notifyListeners();
  }

  /// Update profile image
  void updateProfileImage(File? imageFile) {
    _selectedImageFile = imageFile;
    // In a real app, you would upload the image and get a URL
    // For now, we'll store the file path temporarily
    if (imageFile != null) {
      _profile = _profile.copyWith(profileImageUrl: imageFile.path);
    } else {
      _profile = _profile.copyWith(profileImageUrl: null);
    }
    notifyListeners();
  }

  /// Remove profile image
  void removeProfileImage() {
    _selectedImageFile = null;
    _profile = _profile.copyWith(profileImageUrl: null);
    notifyListeners();
  }

  /// Validate form
  String? _validate() {
    if (_profile.name.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (_profile.email.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_profile.email)) {
      return 'Please enter a valid email address';
    }
    if (_profile.phoneNumber.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (_profile.residentialAddress.trim().isEmpty) {
      return 'Please enter your residential address';
    }
    if (_profile.skills.isEmpty) {
      return 'Please add at least one skill';
    }
    if (_profile.skills.length > 8) {
      return 'Maximum 8 skills allowed';
    }
    return null;
  }

  /// Save profile using PUT request to API
  Future<bool> saveProfile() async {
    final error = _validate();
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      ApiResponse response;

      // Check if there's a selected image file to upload
      bool hasImageToUpload = false;
      if (_selectedImageFile != null) {
        try {
          hasImageToUpload = await _selectedImageFile!.exists() && 
                             _selectedImageFile!.path.isNotEmpty;
        } catch (e) {
          // File check failed, assume no image
          hasImageToUpload = false;
        }
      }
      
      if (hasImageToUpload) {
        // Use multipart/form-data for file upload
        // Convert skills array to JSON string as required by API
        final skillsJson = jsonEncode(_profile.skills);
        
        // Prepare form fields
        final fields = {
          'full_name': _profile.name,
          'email': _profile.email,
          'phone_number': _profile.phoneNumber,
          'residential_address': _profile.residentialAddress,
          'skills': skillsJson,
        };

        // Call profile update API endpoint with multipart/form-data
        response = await ApiClient.putMultipart(
          ApiEndpoints.updateProfileWithImage,
          fields: fields,
          fileField: 'profile_image',
          file: _selectedImageFile,
          token: token,
        );
      } else {
        // Use regular JSON PUT request (no image)
        final requestBody = {
          'full_name': _profile.name,
          'email': _profile.email,
          'phone_number': _profile.phoneNumber,
          'residential_address': _profile.residentialAddress,
          'skills': _profile.skills,
        };

        // Call profile update API endpoint
        response = await ApiClient.put(
          ApiEndpoints.updateProfile,
          body: requestBody,
          token: token,
        );
      }

      _isLoading = false;

      if (response.isSuccess) {
        // Parse updated employee data from response
        final employeeData = response.getField<Map<String, dynamic>>('employee');
        
        if (employeeData != null) {
          // Update profile with new data from API (including profile_image)
          _profile = ProfileModel.fromJson({'employee': employeeData});
          // Clear selected image file after successful save (API data is now the source of truth)
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        } else {
          // Try parsing the entire response as employee data
          _profile = ProfileModel.fromJson(response.data);
          // Clear selected image file after successful save
          _selectedImageFile = null;
          _errorMessage = null;
          
          // Save to cache
          await CacheService.saveProfile(_profile.toJson());
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

