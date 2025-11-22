import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/post_models.dart';

class SubjectsService {
  SubjectsService._private();
  static final SubjectsService instance = SubjectsService._private();
  factory SubjectsService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /directory/subjects/search?q={query} - Busca materias por nombre
  Future<List<Subject>> searchSubjects(String query) async {
    try {
      final response = await _apiClient.get('/directory/subjects/search', {'q': query});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final allSubjects = data.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
        
        // Deduplicar por nombre
        final uniqueSubjects = <String, Subject>{};
        for (var subject in allSubjects) {
          if (!uniqueSubjects.containsKey(subject.name)) {
            uniqueSubjects[subject.name] = subject;
          }
        }
        
        return uniqueSubjects.values.toList();
      }
      
      debugPrint('Search subjects failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Search subjects error: $e');
      return [];
    }
  }

  /// GET /directory/subjects - Obtiene todas las materias
  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _apiClient.get('/directory/subjects');
      
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

  /// GET /directory/subjects?careerId={id} - Obtiene materias de una carrera
  Future<List<Subject>> getSubjectsByCareerId(String careerId) async {
    try {
      final response = await _apiClient.get('/directory/subjects', {'careerId': careerId});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get subjects by career failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get subjects by career error: $e');
      return [];
    }
  }
}
