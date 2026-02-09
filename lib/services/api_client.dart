import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// API Client for handling GET and POST requests
/// Provides a clean interface for making HTTP requests and handling responses
class ApiClient {
  /// Base headers for JSON requests
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': ApiContentType.json,
    'Accept': ApiContentType.json,
  };

  /// Get authorization header
  static Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Make a GET request
  ///
  /// [endpoint] - API endpoint path (e.g., '/profile')
  /// [queryParameters] - Optional query parameters as key-value pairs
  /// [token] - Optional authentication token
  ///
  /// Returns [ApiResponse] containing success status, data, and message
  static Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      // Build URL with query parameters
      final url = ApiEndpoints.buildUrlWithQuery(
        endpoint,
        queryParameters: queryParameters,
      );

      // Make GET request
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      );

      // Handle and return response
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        'Network error: Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        'Invalid response format: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a POST request
  ///
  /// [endpoint] - API endpoint path (e.g., '/register')
  /// [body] - Request body as key-value pairs (will be converted to JSON)
  /// [token] - Optional authentication token
  ///
  /// Returns [ApiResponse] containing success status, data, and message
  static Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      // Build URL
      final url = ApiEndpoints.buildUrl(endpoint);

      // Encode body to JSON
      final jsonBody = body != null ? jsonEncode(body) : null;

      // Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: jsonBody,
      );

      // Handle and return response
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        'Network error: Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        'Invalid response format: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a PUT request
  ///
  /// [endpoint] - API endpoint path (e.g., '/profile')
  /// [body] - Request body as key-value pairs (will be converted to JSON)
  /// [token] - Optional authentication token
  ///
  /// Returns [ApiResponse] containing success status, data, and message
  static Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      // Build URL
      final url = ApiEndpoints.buildUrl(endpoint);

      // Encode body to JSON
      final jsonBody = body != null ? jsonEncode(body) : null;

      // Make PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: jsonBody,
      );

      // Handle and return response
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        'Network error: Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        'Invalid response format: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a POST request with multipart/form-data (for file uploads)
  ///
  /// [endpoint] - API endpoint path (e.g., '/register/step-5')
  /// [fields] - Form fields as key-value pairs
  /// [fileField] - Field name for the file (e.g., 'field_1_driving_license')
  /// [file] - File to upload
  /// [token] - Optional authentication token
  ///
  /// Returns [ApiResponse] containing success status, data, and message
  static Future<ApiResponse> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileField,
    File? file,
    Map<String, File>? files, // Multiple files with field names as keys
    String? token,
  }) async {
    try {
      // Build URL
      final url = ApiEndpoints.buildUrl(endpoint);

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = ApiContentType.json;

      // Add form fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Helper function to add a file
      Future<void> addFile(String fieldName, File fileToAdd) async {
        // Verify file exists
        if (!await fileToAdd.exists()) {
          throw Exception('File does not exist: ${fileToAdd.path}');
        }

        final fileLength = await fileToAdd.length();
        if (fileLength == 0) {
          throw Exception('File is empty: ${fileToAdd.path}');
        }

        // Extract filename - handle both Windows (\) and Unix (/) paths
        final pathSeparator = Platform.isWindows ? '\\' : '/';
        final filename = fileToAdd.path.split(pathSeparator).last;

        // Determine content type based on file extension
        http.MediaType? contentType;
        if (filename.contains('.')) {
          final extension = filename.toLowerCase().split('.').last;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              contentType = http.MediaType('image', 'jpeg');
              break;
            case 'png':
              contentType = http.MediaType('image', 'png');
              break;
            case 'pdf':
              contentType = http.MediaType('application', 'pdf');
              break;
            case 'doc':
            case 'docx':
              contentType = http.MediaType('application', 'msword');
              break;
            case 'txt':
              contentType = http.MediaType('text', 'plain');
              break;
            default:
              contentType = http.MediaType('application', 'octet-stream');
          }
        } else {
          contentType = http.MediaType('application', 'octet-stream');
        }

        final multipartFile = await http.MultipartFile.fromPath(
          fieldName,
          fileToAdd.path,
          filename: filename,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      // Add multiple files if provided
      if (files != null && files.isNotEmpty) {
        for (var entry in files.entries) {
          try {
            await addFile(entry.key, entry.value);
          } catch (e) {
            return ApiResponse.error(
              'Failed to attach file ${entry.key}: ${e.toString()}',
              statusCode: 0,
            );
          }
        }
      }
      // Legacy: Add single file if provided (for backward compatibility)
      else if (fileField != null && file != null) {
        try {
          await addFile(fileField, file);
        } catch (e) {
          return ApiResponse.error(
            'Failed to attach file: ${e.toString()}',
            statusCode: 0,
          );
        }
      }

      // Verify file was added if it was supposed to be
      if (((fileField != null && file != null) ||
              (files != null && files.isNotEmpty)) &&
          request.files.isEmpty) {
        return ApiResponse.error(
          'Failed to attach file to request',
          statusCode: 0,
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle and return response
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        'Network error: Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        'Invalid response format: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a PUT request with multipart/form-data (for file uploads)
  ///
  /// [endpoint] - API endpoint path (e.g., '/profile')
  /// [fields] - Form fields as key-value pairs
  /// [fileField] - Field name for the file (e.g., 'profile_image')
  /// [file] - File to upload
  /// [token] - Optional authentication token
  ///
  /// Returns [ApiResponse] containing success status, data, and message
  static Future<ApiResponse> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileField,
    File? file,
    Map<String, File>? files, // Multiple files with field names as keys
    String? token,
  }) async {
    try {
      // Build URL
      final url = ApiEndpoints.buildUrl(endpoint);

      // Create multipart request
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = ApiContentType.json;

      // Add form fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Helper function to add a file
      Future<void> addFile(String fieldName, File fileToAdd) async {
        // Verify file exists
        if (!await fileToAdd.exists()) {
          throw Exception('File does not exist: ${fileToAdd.path}');
        }

        final fileLength = await fileToAdd.length();
        if (fileLength == 0) {
          throw Exception('File is empty: ${fileToAdd.path}');
        }

        // Extract filename - handle both Windows (\) and Unix (/) paths
        final pathSeparator = Platform.isWindows ? '\\' : '/';
        final filename = fileToAdd.path.split(pathSeparator).last;

        // Determine content type based on file extension
        http.MediaType? contentType;
        if (filename.contains('.')) {
          final extension = filename.toLowerCase().split('.').last;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              contentType = http.MediaType('image', 'jpeg');
              break;
            case 'png':
              contentType = http.MediaType('image', 'png');
              break;
            case 'pdf':
              contentType = http.MediaType('application', 'pdf');
              break;
            case 'doc':
            case 'docx':
              contentType = http.MediaType('application', 'msword');
              break;
            case 'txt':
              contentType = http.MediaType('text', 'plain');
              break;
            case 'gif':
              contentType = http.MediaType('image', 'gif');
              break;
            default:
              contentType = http.MediaType('application', 'octet-stream');
          }
        } else {
          contentType = http.MediaType('application', 'octet-stream');
        }

        final multipartFile = await http.MultipartFile.fromPath(
          fieldName,
          fileToAdd.path,
          filename: filename,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      // Add multiple files if provided
      if (files != null && files.isNotEmpty) {
        for (var entry in files.entries) {
          try {
            await addFile(entry.key, entry.value);
          } catch (e) {
            return ApiResponse.error(
              'Failed to attach file ${entry.key}: ${e.toString()}',
              statusCode: 0,
            );
          }
        }
      }
      // Legacy: Add single file if provided (for backward compatibility)
      else if (fileField != null && file != null) {
        try {
          await addFile(fileField, file);
        } catch (e) {
          return ApiResponse.error(
            'Failed to attach file: ${e.toString()}',
            statusCode: 0,
          );
        }
      }

      // Verify file was added if it was supposed to be
      if (((fileField != null && file != null) ||
              (files != null && files.isNotEmpty)) &&
          request.files.isEmpty) {
        return ApiResponse.error(
          'Failed to attach file to request',
          statusCode: 0,
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle and return response
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        'Network error: Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        'Invalid response format: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Handle HTTP response and convert to ApiResponse
  static ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    // Check if response has body
    if (responseBody.isEmpty) {
      // No body - check status code
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.success(
          data: {},
          message: 'Success',
          statusCode: statusCode,
        );
      } else {
        return ApiResponse.error(
          'Request failed with status code: $statusCode',
          statusCode: statusCode,
        );
      }
    }

    // Parse JSON response
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      // Check if request was successful (2xx status codes)
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.success(
          data: data,
          message: _extractMessage(data, isSuccess: true),
          statusCode: statusCode,
        );
      } else {
        // Handle error response
        return ApiResponse.error(
          _extractErrorMessage(data, statusCode),
          statusCode: statusCode,
          data: data,
        );
      }
    } catch (e) {
      // JSON parsing failed - return raw response
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.success(
          data: {'raw': responseBody},
          message: responseBody,
          statusCode: statusCode,
        );
      } else {
        return ApiResponse.error(
          responseBody.isNotEmpty ? responseBody : 'Request failed',
          statusCode: statusCode,
        );
      }
    }
  }

  /// Extract success message from response data
  static String _extractMessage(
    Map<String, dynamic> data, {
    required bool isSuccess,
  }) {
    if (data.containsKey('message')) {
      return data['message'].toString();
    }
    if (data.containsKey('data') && data['data'] is Map) {
      final dataMap = data['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('message')) {
        return dataMap['message'].toString();
      }
    }
    return isSuccess ? 'Success' : 'An error occurred';
  }

  /// Extract error message from response data
  static String _extractErrorMessage(
    Map<String, dynamic> data,
    int statusCode,
  ) {
    // Try different error message formats

    // Format 1: Direct message field
    if (data.containsKey('message')) {
      return data['message'].toString();
    }

    // Format 2: Error field
    if (data.containsKey('error')) {
      final error = data['error'];
      if (error is String) {
        return error;
      } else if (error is Map) {
        return error['message']?.toString() ?? 'An error occurred';
      }
    }

    // Format 3: Laravel validation errors format
    if (data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map) {
        // Get first error from validation errors
        final firstErrorKey = errors.keys.first;
        final firstErrorValue = errors[firstErrorKey];

        if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
          return firstErrorValue.first.toString();
        } else if (firstErrorValue is String) {
          return firstErrorValue;
        }
      }
    }

    // Format 4: Check for common error fields
    if (data.containsKey('error_message')) {
      return data['error_message'].toString();
    }

    if (data.containsKey('errorMessage')) {
      return data['errorMessage'].toString();
    }

    // Default error message based on status code
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You do not have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// API Response model for handling API responses
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

  /// Create success response
  factory ApiResponse.success({
    required Map<String, dynamic> data,
    required String message,
    required int statusCode,
  }) {
    return ApiResponse(
      success: true,
      statusCode: statusCode,
      data: data,
      message: message,
    );
  }

  /// Create error response
  factory ApiResponse.error(
    String message, {
    int statusCode = 0,
    Map<String, dynamic>? data,
  }) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      data: data ?? {},
      message: message,
    );
  }

  /// Check if response is successful
  bool get isSuccess => success;

  /// Check if response has error
  bool get hasError => !success;

  /// Get specific field from response data
  T? getField<T>(String key) {
    if (data.containsKey(key)) {
      return data[key] as T?;
    }
    return null;
  }

  /// Get nested field from response data using dot notation
  /// Example: getNestedField('employee.name')
  T? getNestedField<T>(String path) {
    final keys = path.split('.');
    dynamic value = data;

    for (final key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }

    return value as T?;
  }

  /// Get list from response data
  List<T>? getList<T>(String key) {
    final field = getField<dynamic>(key);
    if (field is List) {
      return field.cast<T>();
    }
    return null;
  }

  /// Convert response to string for debugging
  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
  }
}
