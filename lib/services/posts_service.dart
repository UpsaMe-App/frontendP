import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/post_models.dart';
import 'api_client.dart';

class PostsService {
  PostsService._private();
  static final PostsService instance = PostsService._private();
  factory PostsService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /posts - Obtiene posts con filtro opcional por rol
  /// Backend: Helper=1, Student=2, Comment=3
  Future<List<Post>> getPosts({int page = 1, int pageSize = 10, int? role}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (role != null) 'role': role.toString(),
      };

      final response = await _apiClient.get('/posts', queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get posts error: $e');
      return [];
    }
  }

  /// GET /posts/search-by-subject - Busca posts por materia
  Future<List<Post>> searchPostsBySubject(String query, {int page = 1, int pageSize = 10}) async {
    try {
      final queryParams = {
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get('/posts/search-by-subject', queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Search posts error: $e');
      return [];
    }
  }

  /// POST /posts - Crea un nuevo post
  /// Backend espera: Helper=1, Student=2, Comment=3
  Future<Post?> createPost({
    required String content,
    String? title,
    required int role,
    String? subjectId,
    int? capacity,
    String? teacherName,
    List<String>? topics,
  }) async {
    try {
      final body = {
        'role': role,
        'content': content,
        if (title != null && title.isNotEmpty) 'title': title,
        if (subjectId != null) 'subjectId': subjectId,
        if (capacity != null && capacity > 0) 'capacity': capacity,
        if (teacherName != null && teacherName.isNotEmpty) 'teacherName': teacherName,
        if (topics != null && topics.isNotEmpty) 'topics': topics,
      };

      debugPrint('Creating post with body: $body');

      final response = await _apiClient.post('/posts', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data as Map<String, dynamic>);
      }
      
      debugPrint('Create post failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Create post error: $e');
      return null;
    }
  }

  /// POST /posts/{id}/replies - Agrega una respuesta a un post
  Future<PostReply?> addReply(String postId, String content) async {
    try {
      final response = await _apiClient.post('/posts/$postId/replies', {
        'content': content,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PostReply.fromJson(data as Map<String, dynamic>);
      }
      
      debugPrint('Add reply failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Add reply error: $e');
      return null;
    }
  }

  Future<Post?> updatePost({
    required String postId,
    required String content,
    String? title,
    required int role,
    String? subjectId,
  }) async {
    try {
      final response = await _apiClient.put('/posts/$postId', {
        'content': content,
        if (title != null && title.isNotEmpty) 'title': title,
        'role': role,
        if (subjectId != null) 'subjectId': subjectId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Update post error: $e');
      return null;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final response = await _apiClient.delete('/posts/$postId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete post error: $e');
      return false;
    }
  }

  Future<bool> deleteReply(String replyId) async {
    try {
      final response = await _apiClient.delete('/replies/$replyId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete reply error: $e');
      return false;
    }
  }
}
