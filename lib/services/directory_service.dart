import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/directory_models.dart';
import '../models/post_models.dart';

class DirectoryService {
  DirectoryService._private();
  static final DirectoryService instance = DirectoryService._private();
  factory DirectoryService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /directory/faculties - Obtiene todas las facultades
  /// Versión para Register (retorna Map)
  Future<List<Map<String, dynamic>>> getFacultiesMap() async {
    try {
      final response = await _apiClient.get('/directory/faculties');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      
      debugPrint('Get faculties failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get faculties error: $e');
      return [];
    }
  }

  /// GET /directory/faculties - Obtiene todas las facultades
  /// Versión tipada para DirectoryScreen (retorna Faculty)
  Future<List<Faculty>> getFaculties() async {
    try {
      final response = await _apiClient.get('/directory/faculties');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Faculty.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get faculties failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get faculties error: $e');
      return [];
    }
  }

  /// GET /directory/faculties/{facultyId}/careers - Obtiene carreras de una facultad
  /// Versión para Register (retorna Map)
  Future<List<Map<String, dynamic>>> getCareersMap(String facultyId) async {
    try {
      final response = await _apiClient.get('/directory/faculties/$facultyId/careers');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      
      debugPrint('Get careers failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get careers error: $e');
      return [];
    }
  }

  /// GET /directory/faculties/{facultyId}/careers - Obtiene carreras de una facultad
  /// Versión tipada para CareersScreen (retorna Career)
  Future<List<Career>> getCareers(String facultyId) async {
    try {
      final response = await _apiClient.get('/directory/faculties/$facultyId/careers');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Career.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get careers failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get careers error: $e');
      return [];
    }
  }

  /// GET /directory/careers/{careerId}/users - Obtiene usuarios de una carrera
  Future<List<DirectoryUser>> getUsersByCareer(String careerId) async {
    try {
      final response = await _apiClient.get('/directory/careers/$careerId/users');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DirectoryUser.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get users by career failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get users by career error: $e');
      return [];
    }
  }

  /// GET /directory/subjects/search - Busca materias por nombre
  Future<List<Subject>> searchSubjects(String query) async {
    try {
      final response = await _apiClient.get('/directory/subjects/search', {'q': query});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Search subjects failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Search subjects error: $e');
      return [];
    }
  }

  /// GET /directory/subjects - Obtiene materias (opcionalmente filtradas por carrera)
  Future<List<Subject>> getSubjects({String? careerId, int page = 1, int pageSize = 50}) async {
    try {
      final queryParams = {
        if (careerId != null) 'careerId': careerId,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get('/directory/subjects', queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get subjects failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get subjects error: $e');
      return [];
    }
  }
}
