class User {
  final String id;
  final String fullName;
  final String? email;
  final String? profilePhotoUrl;
  final String? careerId;

  User({
    required this.id,
    required this.fullName,
    this.email,
    this.profilePhotoUrl,
    this.careerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      careerId: json['careerId'] as String?,
    );
  }
}

class Subject {
  final String id;
  final String name;
  final String? code;
  final String? slug;

  Subject({
    required this.id,
    required this.name,
    this.code,
    this.slug,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      slug: json['slug'] as String?,
    );
  }
}

class Post {
  final String id;
  final int role;
  final String? title;
  final String content;
  final User? user;
  final Subject? subject;
  final int? capacity;
  final int? maxCapacity;
  final String? calendlyUrl;
  final int? capacityUsed;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;
  final int? repliesCount;
  final List<PostReply>? replies; // ✅ Agregado

  Post({
    required this.id,
    required this.role,
    this.title,
    required this.content,
    this.user,
    this.subject,
    this.capacity,
    this.maxCapacity,
    this.calendlyUrl,
    this.capacityUsed,
    required this.createdAtUtc,
    this.updatedAtUtc,
    this.repliesCount,
    this.replies, // ✅ Agregado
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      role: json['role'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      subject: json['subject'] != null ? Subject.fromJson(json['subject'] as Map<String, dynamic>) : null,
      capacity: json['capacity'] as int?,
      maxCapacity: json['maxCapacity'] as int?,
      calendlyUrl: json['calendlyUrl'] as String?,
      capacityUsed: json['capacityUsed'] as int?,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] != null ? DateTime.parse(json['updatedAtUtc'] as String) : null,
      repliesCount: json['repliesCount'] as int? ?? 0,
      replies: json['replies'] != null 
          ? (json['replies'] as List).map((r) => PostReply.fromJson(r as Map<String, dynamic>)).toList()
          : null, // ✅ Agregado
    );
  }
}

class PostReply {
  final String id;
  final String content;
  final DateTime createdAtUtc;
  final String userId;
  final User? user;

  PostReply({
    required this.id,
    required this.content,
    required this.createdAtUtc,
    required this.userId,
    this.user,
  });

  factory PostReply.fromJson(Map<String, dynamic> json) {
    return PostReply(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}
