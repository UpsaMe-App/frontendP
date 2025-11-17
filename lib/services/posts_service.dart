import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../models/post_models.dart';

class PostsService {
  PostsService._private();
  static final PostsService instance = PostsService._private();

  // Modo mock: lista en memoria usada cuando ApiClient.baseUrl está vacío
  final List<Post> _mockPosts = [];
  final ValueNotifier<List<Post>> postsNotifier = ValueNotifier<List<Post>>([]);

  Future<List<Post>> fetchPosts({int page = 1, int pageSize = 10, int? role, String? facultyId, String? careerId, String? subjectId, String? q}) async {
    // Si no hay baseUrl, usar modo mock
    if (ApiClient.instance.baseUrl.isEmpty) {
      // Simple paginado local
      final start = (page - 1) * pageSize;
      if (start >= _mockPosts.length) return [];
      final end = (start + pageSize) < _mockPosts.length ? (start + pageSize) : _mockPosts.length;
      return _mockPosts.sublist(start, end);
    }

    final query = <String, String>{'page': page.toString(), 'pageSize': pageSize.toString()};
    if (role != null) query['role'] = role.toString();
    if (facultyId != null) query['facultyId'] = facultyId;
    if (careerId != null) query['careerId'] = careerId;
    if (subjectId != null) query['subjectId'] = subjectId;
    if (q != null && q.isNotEmpty) query['q'] = q;
    final resp = await ApiClient.instance.get('/posts', query);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error cargando posts: ${resp.statusCode}');
  }

  Future<Post> fetchPostById(String id) async {
    // Modo mock: buscar en la lista local
    if (ApiClient.instance.baseUrl.isEmpty) {
      final post = _mockPosts.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Post no encontrado'),
      );
      return post;
    }

    final resp = await ApiClient.instance.get('/posts/$id');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Post.fromJson(data);
    }
    throw Exception('Error cargando post: ${resp.statusCode}');
  }

  Future<PostReply> createReply(String postId, String content) async {
    // Modo mock: si no hay baseUrl, creamos una reply simulada
    if (ApiClient.instance.baseUrl.isEmpty) {
      final now = DateTime.now();
      final userProfile = AuthService.instance.getUserProfile();
      final reply = PostReply(
        id: 'mock_reply_${now.millisecondsSinceEpoch}',
        content: content,
        createdAtUtc: now.toIso8601String(),
        user: User(
          id: userProfile?.id ?? 'user_unknown',
          firstName: userProfile?.firstName ?? 'Usuario',
          lastName: userProfile?.lastName ?? '',
          profilePhotoUrl: null,
        ),
      );
      // Buscar el post en _mockPosts y agregar la reply
      for (var post in _mockPosts) {
        if (post.id == postId) {
          post.replies ??= [];
          post.replies!.add(reply);
          postsNotifier.value = List<Post>.from(_mockPosts);
          break;
        }
      }
      return reply;
    }

    final payload = {'content': content};
    final resp = await ApiClient.instance.post('/posts/$postId/replies', payload);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return PostReply.fromJson(data);
    }
    throw Exception('Error creando reply: ${resp.statusCode} ${resp.body}');
  }

  Future<Post> createPost(Map<String, dynamic> payload) async {
    // Modo mock: si no hay baseUrl, agregamos a la lista local
    if (ApiClient.instance.baseUrl.isEmpty) {
      final now = DateTime.now();
      final id = 'mock_${now.millisecondsSinceEpoch}';
      final userProfile = AuthService.instance.getUserProfile();
      final post = Post(
        id: id,
        content: payload['content'] as String? ?? '',
        title: payload['title'] as String?,
        role: payload['role'] as int? ?? 0,
        createdAtUtc: now.toIso8601String(),
        user: User(
          id: userProfile?.id ?? 'user_unknown',
          firstName: userProfile?.firstName ?? 'Usuario',
          lastName: userProfile?.lastName ?? '',
          profilePhotoUrl: null,
        ),
        subject: payload['subjectId'] == null ? null : Subject(id: payload['subjectId'].toString(), name: payload['subjectId'].toString()),
        replies: [],
      );
      _mockPosts.insert(0, post);
      postsNotifier.value = List<Post>.from(_mockPosts);
      return post;
    }

    final resp = await ApiClient.instance.post('/posts', payload);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Post.fromJson(data);
    }
    throw Exception('Error creando post: ${resp.statusCode} ${resp.body}');
  }
}
