import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class Avatar {
  final String id;
  final String name;
  final String url;

  Avatar({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class AvatarsService {
  AvatarsService._private();
  static final AvatarsService instance = AvatarsService._private();
  factory AvatarsService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /avatars - Obtiene la lista de avatares disponibles
  Future<List<Avatar>> getAvatars() async {
    try {
      final response = await _apiClient.get('/avatars');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Avatar.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      debugPrint('Get avatars failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get avatars error: $e');
      return [];
    }
  }

  /// GET /users/avatars/options - Obtiene opciones de avatares para usuarios
  Future<List<Avatar>> getAvatarOptions() async {
    try {
      final response = await _apiClient.get('/users/avatars/options');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Avatar.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      debugPrint('Get avatar options failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get avatar options error: $e');
      return [];
    }
  }
}
