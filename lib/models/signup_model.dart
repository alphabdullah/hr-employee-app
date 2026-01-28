/// Model class for SignUp data
class SignUpModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String residentialAddress;
  final List<String> skills;
  final String password;
  final String confirmPassword;
  
  SignUpModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.residentialAddress,
    required this.skills,
    required this.password,
    required this.confirmPassword,
  });
  
  /// Create empty SignUpModel
  factory SignUpModel.empty() {
    return SignUpModel(
      fullName: '',
      email: '',
      phoneNumber: '',
      residentialAddress: '',
      skills: [],
      password: '',
      confirmPassword: '',
    );
  }
  
  /// Create SignUpModel from JSON
  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      residentialAddress: json['residentialAddress'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }
  
  /// Convert SignUpModel to JSON for API request
  /// Note: API expects snake_case field names
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'residential_address': residentialAddress,
      'skills': skills,
      'password': password,
    };
  }

  /// Convert SignUpModel to JSON for internal use (camelCase)
  Map<String, dynamic> toJsonInternal() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'residentialAddress': residentialAddress,
      'skills': skills,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
  
  /// Copy with method for immutability
  SignUpModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? residentialAddress,
    List<String>? skills,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      skills: skills ?? this.skills,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

