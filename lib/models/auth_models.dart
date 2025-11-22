class LoginDto {
  final String email;
  final String password;
  LoginDto({required this.email, required this.password});
}

class RegisterDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? career;
  final int? semester;
  final String? phone;

  RegisterDto({required this.email, required this.password, required this.firstName, required this.lastName, this.career, this.semester, this.phone});
}

class TokenResponseDto {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAtUtc;
  TokenResponseDto({this.accessToken, this.refreshToken, this.expiresAtUtc});
}

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? careerId;
  final String? career;
  final int? semester;
  final String? profilePhotoUrl;
  final String? phoneNumber;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.careerId,
    this.career,
    this.semester,
    this.profilePhotoUrl,
    this.phoneNumber,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final fullName = json['fullName'] as String? ?? '';
    final nameParts = fullName.split(' ');
    
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? (nameParts.isNotEmpty ? nameParts[0] : ''),
      lastName: json['lastName'] as String? ?? (nameParts.length > 1 ? nameParts.skip(1).join(' ') : ''),
      careerId: json['careerId'] as String?,
      career: json['career'] as String?,
      semester: json['semester'] as int?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      phoneNumber: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'careerId': careerId,
      'career': career,
      'semester': semester,
      'profilePhotoUrl': profilePhotoUrl,
      'phone': phoneNumber,
    };
  }

  String get fullName => '$firstName $lastName';
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? careerId;
  final String? career;
  final int? semester;
  final String? profilePhotoUrl;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.careerId,
    this.career,
    this.semester,
    this.profilePhotoUrl,
    this.phoneNumber,
  });

  // ✅ Getter para fullName
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    // Manejar fullName que viene del backend
    String firstName = '';
    String lastName = '';
    
    if (json.containsKey('firstName') && json.containsKey('lastName')) {
      firstName = json['firstName'] as String? ?? '';
      lastName = json['lastName'] as String? ?? '';
    } else if (json.containsKey('fullName')) {
      final fullName = json['fullName'] as String? ?? '';
      final parts = fullName.split(' ');
      firstName = parts.isNotEmpty ? parts[0] : '';
      lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    }

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: firstName,
      lastName: lastName,
      careerId: json['careerId'] as String?,
      career: json['career'] as String?,
      semester: json['semester'] as int?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
    );
  }
}
