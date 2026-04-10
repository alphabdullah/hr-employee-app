import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cache_service.dart';
import '../models/registration_progress_model.dart';

/// Authentication Service for managing user authentication state
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _employeeIdKey = 'employee_id';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userStatusKey = 'user_status';
  static const String _registrationProgressKey = 'registration_progress';

  /// Save authentication token
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save employee ID
  static Future<bool> saveEmployeeId(String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_employeeIdKey, employeeId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get employee ID
  static Future<String?> getEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_employeeIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  /// Returns true only if both the login flag is true AND a token exists
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      final token = prefs.getString(_tokenKey);
      
      // User is logged in only if flag is true AND token exists
      return isLoggedInFlag && token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear authentication data (logout)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // User requested full local reset on logout.
      await prefs.clear();
      // Keep explicit cache cleanup for any non-SharedPreferences stores.
      await CacheService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save user status
  static Future<bool> saveUserStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatusKey, status);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user status
  static Future<String?> getUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userStatusKey);
    } catch (e) {
      return null;
    }
  }

  /// Save registration progress
  static Future<bool> saveRegistrationProgress(RegistrationProgressModel progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_registrationProgressKey, jsonEncode(progress.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get registration progress
  static Future<RegistrationProgressModel?> getRegistrationProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = prefs.getString(_registrationProgressKey);
      if (progressData == null) return null;
      
      final json = jsonDecode(progressData) as Map<String, dynamic>;
      return RegistrationProgressModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Clear user status
  static Future<bool> clearUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStatusKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear registration progress
  static Future<bool> clearRegistrationProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_registrationProgressKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Full wipe of all local preferences.
      await prefs.clear();
      // Clear all cached data
      await CacheService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
