/// Model class for Forgot Password data
class ForgotPasswordModel {
  final String email;
  
  ForgotPasswordModel({
    required this.email,
  });
  
  /// Create empty ForgotPasswordModel
  factory ForgotPasswordModel.empty() {
    return ForgotPasswordModel(
      email: '',
    );
  }
  
  /// Create ForgotPasswordModel from JSON
  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      email: json['email'] ?? '',
    );
  }
  
  /// Convert ForgotPasswordModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
  
  /// Copy with method for immutability
  ForgotPasswordModel copyWith({
    String? email,
  }) {
    return ForgotPasswordModel(
      email: email ?? this.email,
    );
  }
}

