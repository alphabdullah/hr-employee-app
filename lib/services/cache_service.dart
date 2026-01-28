import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Service for persisting data to disk
/// Provides methods to save and load cached data using SharedPreferences
class CacheService {
  // Cache keys
  static const String _profileCacheKey = 'cached_profile';
  static const String _applicationsCacheKey = 'cached_applications';
  static const String _skillsCacheKey = 'cached_skills';
  static const String _profileCacheTimestampKey = 'profile_cache_timestamp';
  static const String _applicationsCacheTimestampKey = 'applications_cache_timestamp';
  static const String _skillsCacheTimestampKey = 'skills_cache_timestamp';
  
  // Chat messages cache (per chat ID)
  static String _chatMessagesCacheKey(String chatId) => 'cached_chat_messages_$chatId';
  static String _chatMessagesCacheTimestampKey(String chatId) => 'chat_messages_cache_timestamp_$chatId';

  // Cache expiration time (24 hours in milliseconds)
  static const int _cacheExpirationMs = 24 * 60 * 60 * 1000;

  /// Save profile data to cache
  static Future<bool> saveProfile(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileCacheKey, jsonEncode(profileData));
      await prefs.setInt(_profileCacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load profile data from cache
  static Future<Map<String, dynamic>?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_profileCacheKey);
      
      if (cachedData == null) {
        return null;
      }

      // Check if cache is expired
      final timestamp = prefs.getInt(_profileCacheTimestampKey);
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > _cacheExpirationMs) {
          // Cache expired, clear it
          await clearProfile();
          return null;
        }
      }

      return jsonDecode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear profile cache
  static Future<bool> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileCacheKey);
      await prefs.remove(_profileCacheTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save applications data to cache
  static Future<bool> saveApplications(List<Map<String, dynamic>> applications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_applicationsCacheKey, jsonEncode(applications));
      await prefs.setInt(_applicationsCacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load applications data from cache
  static Future<List<Map<String, dynamic>>?> loadApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_applicationsCacheKey);
      
      if (cachedData == null) {
        return null;
      }

      // Check if cache is expired
      final timestamp = prefs.getInt(_applicationsCacheTimestampKey);
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > _cacheExpirationMs) {
          // Cache expired, clear it
          await clearApplications();
          return null;
        }
      }

      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Clear applications cache
  static Future<bool> clearApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_applicationsCacheKey);
      await prefs.remove(_applicationsCacheTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save skills list to cache
  static Future<bool> saveSkills(List<String> skills) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_skillsCacheKey, skills);
      await prefs.setInt(_skillsCacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load skills list from cache
  static Future<List<String>?> loadSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSkills = prefs.getStringList(_skillsCacheKey);
      
      if (cachedSkills == null || cachedSkills.isEmpty) {
        return null;
      }

      // Check if cache is expired (skills change less frequently, so longer cache)
      final timestamp = prefs.getInt(_skillsCacheTimestampKey);
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        // Skills cache expires after 7 days (they change less frequently)
        if (age > (7 * 24 * 60 * 60 * 1000)) {
          await clearSkills();
          return null;
        }
      }

      return cachedSkills;
    } catch (e) {
      return null;
    }
  }

  /// Clear skills cache
  static Future<bool> clearSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_skillsCacheKey);
      await prefs.remove(_skillsCacheTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save chat messages to cache (per chat ID)
  static Future<bool> saveChatMessages(String chatId, List<Map<String, dynamic>> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chatMessagesCacheKey(chatId), jsonEncode(messages));
      await prefs.setInt(_chatMessagesCacheTimestampKey(chatId), DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load chat messages from cache (per chat ID)
  static Future<List<Map<String, dynamic>>?> loadChatMessages(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_chatMessagesCacheKey(chatId));
      
      if (cachedData == null) {
        return null;
      }

      // Check if cache is expired (messages should be fresh, so shorter cache - 1 hour)
      final timestamp = prefs.getInt(_chatMessagesCacheTimestampKey(chatId));
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        // Messages cache expires after 1 hour
        if (age > (60 * 60 * 1000)) {
          await clearChatMessages(chatId);
          return null;
        }
      }

      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Clear chat messages cache for a specific chat
  static Future<bool> clearChatMessages(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatMessagesCacheKey(chatId));
      await prefs.remove(_chatMessagesCacheTimestampKey(chatId));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all chat messages caches
  static Future<bool> clearAllChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final chatMessageKeys = keys.where((key) => 
        key.startsWith('cached_chat_messages_') || 
        key.startsWith('chat_messages_cache_timestamp_')
      ).toList();
      
      for (final key in chatMessageKeys) {
        await prefs.remove(key);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all caches (useful for logout)
  static Future<bool> clearAll() async {
    try {
      await clearProfile();
      await clearApplications();
      await clearSkills();
      await clearAllChatMessages();
      return true;
    } catch (e) {
      return false;
    }
  }
}
