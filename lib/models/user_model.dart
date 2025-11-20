class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? career;
  final int? semester;
  final String? profilePhotoUrl;
  final String? avatarId;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.career,
    this.semester,
    this.profilePhotoUrl,
    this.avatarId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    career: json['career'] as String?,
    semester: json['semester'] as int?,
    profilePhotoUrl: json['profilePhotoUrl'] as String?,
    avatarId: json['avatarId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'career': career,
    'semester': semester,
    'profilePhotoUrl': profilePhotoUrl,
    'avatarId': avatarId,
  };

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? career,
    int? semester,
    String? profilePhotoUrl,
    String? avatarId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}
