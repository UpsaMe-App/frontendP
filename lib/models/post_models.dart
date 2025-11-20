class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  User({required this.id, required this.firstName, required this.lastName, this.profilePhotoUrl});

  factory User.fromJson(Map<String, dynamic> j) {
    final fullName = j['fullName'] as String?;
    final nameParts = fullName?.split(' ') ?? [];
    
    return User(
      id: j['id'] as String,
      firstName: j['firstName'] as String? ?? (nameParts.isNotEmpty ? nameParts[0] : ''),
      lastName: j['lastName'] as String? ?? (nameParts.length > 1 ? nameParts.skip(1).join(' ') : ''),
      profilePhotoUrl: j['profilePhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'profilePhotoUrl': profilePhotoUrl,
      };
}

class Subject {
  final String id;
  final String name;
  final String? code;

  Subject({required this.id, required this.name, this.code});

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    code: j['code'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}

class PostReply {
  final String id;
  final String content;
  final String? createdAtUtc;
  final User? user;

  PostReply({required this.id, required this.content, this.createdAtUtc, this.user});

  factory PostReply.fromJson(Map<String, dynamic> j) => PostReply(
    id: j['id'] as String,
    content: j['content'] as String,
    createdAtUtc: j['createdAtUtc'] as String?,
    user: j['user'] != null ? User.fromJson(j['user'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAtUtc': createdAtUtc,
        'user': user?.toJson(),
      };
}

class Post {
  final String id;
  final String content;
  final String? title;
  final int role;
  final String? createdAtUtc;
  final User? user;
  final Subject? subject;
  List<PostReply>? replies;

  Post({required this.id, required this.content, this.title, required this.role, this.createdAtUtc, this.user, this.subject, this.replies});

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id: j['id'] as String,
    content: j['content'] as String,
    title: j['title'] as String?,
    role: j['role'] as int? ?? 0,
    createdAtUtc: j['createdAtUtc'] as String?,
    user: j['user'] != null ? User.fromJson(j['user'] as Map<String, dynamic>) : null,
    subject: j['subject'] != null ? Subject.fromJson(j['subject'] as Map<String, dynamic>) : null,
    replies: j['replies'] != null
    ? (j['replies'] as List<dynamic>).map((e) => PostReply.fromJson(e as Map<String, dynamic>)).toList()
    : null,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'title': title,
        'role': role,
        'createdAtUtc': createdAtUtc,
        'user': user?.toJson(),
        'subject': subject?.toJson(),
        'replies': replies?.map((r) => r.toJson()).toList(),
      };
}
