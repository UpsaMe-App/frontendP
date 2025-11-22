import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/directory_models.dart';

class DirectoryService {
  DirectoryService._private();
  static final DirectoryService instance = DirectoryService._private();
  factory DirectoryService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /directory/faculties - Obtiene todas las facultades
  /// Versión Map para Register
  Future<List<Map<String, dynamic>>> getFacultiesMap() async {
    try {
      debugPrint('📡 GET /directory/faculties (Map version)');
      final response = await _apiClient.get('/directory/faculties');
      
      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Facultades recibidas: ${data.length}');
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      
      debugPrint('❌ Get faculties failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Get faculties error: $e');
      return [];
    }
  }

  /// GET /directory/faculties - Obtiene todas las facultades
  /// Versión tipada para DirectoryScreen
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
  /// Versión Map para Register
  Future<List<Map<String, dynamic>>> getCareersMap(String facultyId) async {
    try {
      debugPrint('📡 GET /directory/faculties/$facultyId/careers (Map version)');
      final response = await _apiClient.get('/directory/faculties/$facultyId/careers');
      
      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Carreras recibidas: ${data.length}');
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      
      debugPrint('❌ Get careers failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Get careers error: $e');
      return [];
    }
  }

  /// GET /directory/faculties/{facultyId}/careers - Obtiene carreras de una facultad
  /// Versión tipada para CareersScreen
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
  Future<List<DirectoryUser>> getCareerUsers(String careerId) async {
    try {
      final response = await _apiClient.get('/directory/careers/$careerId/users');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DirectoryUser.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get career users failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get career users error: $e');
      return [];
    }
  }
}
