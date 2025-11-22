class Faculty {
  final String id;
  final String name;
  final String slug;

  Faculty({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class Career {
  final String id;
  final String name;
  final String slug;
  final String facultyId;

  Career({
    required this.id,
    required this.name,
    required this.slug,
    required this.facultyId,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      facultyId: json['facultyId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'facultyId': facultyId,
    };
  }
}

class DirectoryUser {
  final String id;
  final String fullName;
  final String? email;
  final String? career;
  final String? profilePhotoUrl;

  DirectoryUser({
    required this.id,
    required this.fullName,
    this.email,
    this.career,
    this.profilePhotoUrl,
  });

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String?,
      career: json['career'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}
