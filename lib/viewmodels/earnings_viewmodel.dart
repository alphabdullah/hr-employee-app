import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for Earnings screen
class EarningsViewModel extends ChangeNotifier {
  EarningsModel? _earnings;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  EarningsModel? get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch earnings data from API
  Future<bool> fetchEarnings({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _earnings != null) {
      return true;
    }

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

      debugPrint('Fetching earnings from ${ApiEndpoints.getMyEarnings}...');
      final response = await ApiClient.get(
        ApiEndpoints.getMyEarnings,
        token: token,
      );

      _isLoading = false;

      if (response.isSuccess) {
        try {
          _earnings = EarningsModel.fromJson(response.data);
          debugPrint('Earnings fetched successfully: ${_earnings!.perJob.length} jobs');
          notifyListeners();
          return true;
        } catch (e) {
          debugPrint('Failed to parse earnings data: $e');
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
