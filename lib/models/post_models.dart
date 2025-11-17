class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  User({required this.id, required this.firstName, required this.lastName, this.profilePhotoUrl});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as String,
    firstName: j['firstName'] as String? ?? '',
    lastName: j['lastName'] as String? ?? '',
    profilePhotoUrl: j['profilePhotoUrl'] as String?,
  );
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
}
