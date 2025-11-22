import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/post_models.dart';

class PostsService {
  PostsService._private();
  static final PostsService instance = PostsService._private();
  factory PostsService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /posts - Feed general (puede filtrar por role)
  /// Backend: role = Helper(1), Student(2), Comment(3)
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

  /// POST /posts/helper - Crear post de Ayudante
  Future<Post?> createHelperPost({
    required String title,
    required String content,
    required String subjectId,
    required int capacity,
    required int maxCapacity,
    required String calendlyUrl,
  }) async {
    try {
      final body = {
        'title': title,
        'content': content,
        'subjectId': subjectId,
        'capacity': capacity,
        'maxCapacity': maxCapacity,
        'calendlyUrl': calendlyUrl,
      };

      final response = await _apiClient.post('/posts/helper', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data as Map<String, dynamic>);
      }
      
      debugPrint('Create helper post failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Create helper post error: $e');
      return null;
    }
  }

  /// POST /posts/student - Crear post de Estudiante
  Future<Post?> createStudentPost({
    required String title,
    required String content,
    required String subjectId,
  }) async {
    try {
      final body = {
        'title': title,
        'content': content,
        'subjectId': subjectId,
      };

      final response = await _apiClient.post('/posts/student', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data as Map<String, dynamic>);
      }
      
      debugPrint('Create student post failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Create student post error: $e');
      return null;
    }
  }

  /// POST /posts/comment - Crear comentario
  Future<Post?> createCommentPost({
    required String title,
    required String content,
  }) async {
    try {
      final body = {
        'title': title,
        'content': content,
      };

      final response = await _apiClient.post('/posts/comment', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data as Map<String, dynamic>);
      }
      
      debugPrint('Create comment post failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Create comment post error: $e');
      return null;
    }
  }

  /// POST /posts/{postId}/replies - Agregar respuesta
  Future<PostReply?> addReply(String postId, String content) async {
    try {
      final response = await _apiClient.post('/posts/$postId/replies', {
        'content': content,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PostReply.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Add reply error: $e');
      return null;
    }
  }

  /// GET /posts/search-by-subject - Buscar por materia
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

  /// PUT /posts/{id} - Editar post (solo el dueño)
  Future<Post?> updatePost(String postId, {String? title, String? content}) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;

      final response = await _apiClient.put('/posts/$postId', body);

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

  /// DELETE /posts/{id} - Eliminar post (soft delete, solo el dueño)
  Future<bool> deletePost(String postId) async {
    try {
      final response = await _apiClient.delete('/posts/$postId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete post error: $e');
      return false;
    }
  }

  /// GET /posts/mine - Obtener MIS posts
  Future<List<Post>> getMyPosts({int page = 1, int pageSize = 50}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get('/posts/mine', queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get my posts error: $e');
      return [];
    }
  }
}
