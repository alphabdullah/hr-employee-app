/// Model class for Login data
class LoginModel {
  final String email;
  final String password;
  
  LoginModel({
    required this.email,
    required this.password,
  });
  
  /// Create empty LoginModel
  factory LoginModel.empty() {
    return LoginModel(
      email: '',
      password: '',
    );
  }
  
  /// Create LoginModel from JSON
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
  
  /// Convert LoginModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
  
  /// Copy with method for immutability
  LoginModel copyWith({
    String? email,
    String? password,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

