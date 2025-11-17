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
