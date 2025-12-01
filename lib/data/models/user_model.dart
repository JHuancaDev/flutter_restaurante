class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final String? authProvider;
  final bool? emailVerified;
  final String? photoUrl;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.authProvider,
    this.emailVerified,
    this.photoUrl,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      authProvider: json['auth_provider'],
      emailVerified: json['email_verified'],
      photoUrl: json['photo_url'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'auth_provider': authProvider,
      'email_verified': emailVerified,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    String? authProvider,
    bool? emailVerified,
    String? photoUrl,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
      emailVerified: emailVerified ?? this.emailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}