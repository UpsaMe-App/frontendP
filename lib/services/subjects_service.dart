import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/post_models.dart';
import 'api_client.dart';

class SubjectsService {
  SubjectsService._private();
  static final SubjectsService instance = SubjectsService._private();
  factory SubjectsService() => instance;

  final _apiClient = ApiClient.instance;

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
      return [];
    } catch (e) {
      debugPrint('Get subjects error: $e');
      return [];
    }
  }

  Future<List<Subject>> searchSubjects(String query) async {
    try {
      final response = await _apiClient.get('/directory/subjects/search', {'q': query});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Search subjects error: $e');
      return [];
    }
  }
}
