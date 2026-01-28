/// Model class for Employee Profile data
class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String residentialAddress;
  final String? profileImageUrl;
  final List<String> skills;
  final String status;
  final String role;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.residentialAddress,
    this.profileImageUrl,
    required this.skills,
    required this.status,
    required this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.empty() {
    return ProfileModel(
      id: 0,
      name: '',
      email: '',
      phoneNumber: '',
      residentialAddress: '',
      profileImageUrl: null,
      skills: const [],
      status: '',
      role: '',
      emailVerifiedAt: null,
      createdAt: '',
      updatedAt: '',
    );
  }

  /// Create ProfileModel from API JSON response
  /// Expected format: { "employee": { ... } }
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle nested employee object
    final employeeData = json['employee'] ?? json;
    
    // Handle profile_image - can be null or a string URL
    final profileImage = employeeData['profile_image'];
    final String? profileImageUrl;
    if (profileImage == null || profileImage == 'null' || profileImage.toString().isEmpty) {
      profileImageUrl = null;
    } else {
      profileImageUrl = profileImage.toString();
    }
    
    return ProfileModel(
      id: employeeData['id'] ?? 0,
      name: employeeData['full_name'] ?? '',
      email: employeeData['email'] ?? '',
      phoneNumber: employeeData['phone_number'] ?? '',
      residentialAddress: employeeData['residential_address'] ?? '',
      profileImageUrl: profileImageUrl,
      skills: List<String>.from(employeeData['skills'] ?? []),
      status: employeeData['status'] ?? '',
      role: employeeData['role'] ?? '',
      emailVerifiedAt: employeeData['email_verified_at'],
      createdAt: employeeData['created_at'] ?? '',
      updatedAt: employeeData['updated_at'] ?? '',
    );
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? residentialAddress,
    String? profileImageUrl,
    List<String>? skills,
    String? status,
    String? role,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skills: skills ?? this.skills,
      status: status ?? this.status,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert ProfileModel to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'employee': {
        'id': id,
        'full_name': name,
        'email': email,
        'phone_number': phoneNumber,
        'residential_address': residentialAddress,
        'profile_image': profileImageUrl,
        'skills': skills,
        'status': status,
        'role': role,
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      },
    };
  }
}

