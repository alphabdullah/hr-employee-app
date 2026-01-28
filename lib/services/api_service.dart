import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// API Service for making HTTP requests
class ApiService {
  /// Base headers for JSON requests
  static Map<String, String> get _baseHeaders => {
        'Content-Type': ApiContentType.json,
        'Accept': ApiContentType.json,
      };

  /// Headers with authorization token
  static Map<String, String> _headersWithAuth(String? token) {
    final headers = Map<String, String>.from(_baseHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Make a GET request
  static Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final url = ApiEndpoints.buildUrlWithQuery(
        endpoint,
        queryParameters: queryParameters,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: _headersWithAuth(token),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Make a POST request
  static Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = ApiEndpoints.buildUrl(endpoint);

      final response = await http.post(
        Uri.parse(url),
        headers: _headersWithAuth(token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Make a PUT request
  static Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = ApiEndpoints.buildUrl(endpoint);

      final response = await http.put(
        Uri.parse(url),
        headers: _headersWithAuth(token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Make a PATCH request
  static Future<ApiResponse> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = ApiEndpoints.buildUrl(endpoint);

      final response = await http.patch(
        Uri.parse(url),
        headers: _headersWithAuth(token),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Make a DELETE request
  static Future<ApiResponse> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = ApiEndpoints.buildUrl(endpoint);

      final response = await http.delete(
        Uri.parse(url),
        headers: _headersWithAuth(token),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Handle HTTP response
  static ApiResponse _handleResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;
      final responseBody = response.body;

      // Parse JSON if response has body
      Map<String, dynamic>? data;
      if (responseBody.isNotEmpty) {
        try {
          data = jsonDecode(responseBody) as Map<String, dynamic>;
        } catch (e) {
          // If JSON parsing fails, return raw body
          return ApiResponse(
            success: statusCode >= 200 && statusCode < 300,
            statusCode: statusCode,
            data: {'message': responseBody},
            message: responseBody,
          );
        }
      }

      // Check if request was successful
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse(
          success: true,
          statusCode: statusCode,
          data: data ?? {},
          message: data?['message'] ?? 'Success',
        );
      } else {
        // Handle error response
        String errorMessage = 'An error occurred';
        
        if (data != null) {
          // Try to extract error message from common error formats
          if (data.containsKey('message')) {
            errorMessage = data['message'].toString();
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          } else if (data.containsKey('errors')) {
            // Handle Laravel validation errors format
            final errors = data['errors'];
            if (errors is Map) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        }

        return ApiResponse(
          success: false,
          statusCode: statusCode,
          data: data ?? {},
          message: errorMessage,
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: ${e.toString()}');
    }
  }
}

/// API Response model
class ApiResponse {
  final bool success;
  final int statusCode;
  final Map<String, dynamic> data;
  final String message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  /// Create error response
  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      statusCode: 0,
      data: {},
      message: message,
    );
  }

  /// Get specific field from data
  T? getField<T>(String key) {
    return data[key] as T?;
  }
}
