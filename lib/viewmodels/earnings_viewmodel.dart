import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/earnings_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for Earnings screen
class EarningsViewModel extends ChangeNotifier {
  WeeklyEarningsModel? _earnings;
  DateTime _selectedWeekStart = alignToSaturday(DateTime.now());
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  WeeklyEarningsModel? get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedWeekStart => _selectedWeekStart;

  static DateTime alignToSaturday(DateTime date) {
    final trimmed = DateTime(date.year, date.month, date.day);
    int offset = (trimmed.weekday - DateTime.saturday) % 7;
    if (offset < 0) offset += 7;
    return trimmed.subtract(Duration(days: offset));
  }

  /// Fetch earnings data from API (weekly totals)
  Future<bool> fetchEarnings({
    bool forceRefresh = false,
    DateTime? requestedDate,
  }) async {
    final targetDate = requestedDate ?? DateTime.now();
    final weekStart = alignToSaturday(targetDate);
    if (!forceRefresh && _earnings != null && _selectedWeekStart == weekStart) {
      return true;
    }

    _selectedWeekStart = weekStart;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final weekStartParam = DateFormat('yyyy-MM-dd').format(weekStart);
      debugPrint('Fetching weekly earnings for week_start=$weekStartParam');
      final response = await ApiClient.get(
        ApiEndpoints.weeklyEarnings,
        token: token,
        queryParameters: {'week_start': weekStartParam},
      );

      _isLoading = false;
      if (response.isSuccess) {
        try {
          _earnings = WeeklyEarningsModel.fromJson(response.data);
          notifyListeners();
          return true;
        } catch (e) {
          debugPrint('Failed to parse weekly earnings: $e');
          _errorMessage = 'Failed to parse earnings data. Please try again.';
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching earnings: $e');
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

  /// Reset viewmodel
  void reset() {
    _earnings = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
