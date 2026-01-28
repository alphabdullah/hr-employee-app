import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';

/// Authentication Service for managing user authentication state
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _employeeIdKey = 'employee_id';
  static const String _isLoggedInKey = 'is_logged_in';

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
      await prefs.remove(_tokenKey);
      await prefs.remove(_employeeIdKey);
      await prefs.setBool(_isLoggedInKey, false);
      // Clear all cached data on logout
      await CacheService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_employeeIdKey);
      await prefs.remove(_isLoggedInKey);
      // Clear all cached data
      await CacheService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
