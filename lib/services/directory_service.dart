import 'dart:convert';

import '../services/api_client.dart';

class Faculty {
  final String id;
  final String name;
  final String slug;

  Faculty({required this.id, required this.name, required this.slug});

  factory Faculty.fromJson(Map<String, dynamic> j) => Faculty(id: j['id'] as String, name: j['name'] as String? ?? '', slug: j['slug'] as String? ?? '');
}

class Career {
  final String id;
  final String name;
  final String slug;
  final String facultyId;

  Career({required this.id, required this.name, required this.slug, required this.facultyId});

  factory Career.fromJson(Map<String, dynamic> j) => Career(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        slug: j['slug'] as String? ?? '',
        facultyId: j['facultyId'] as String? ?? '',
      );
}

class DirectoryService {
  DirectoryService._private();
  static final DirectoryService instance = DirectoryService._private();

  Future<List<Faculty>> fetchFaculties() async {
    final resp = await ApiClient.instance.get('/directory/faculties');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Faculty.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error cargando faculties: ${resp.statusCode}');
  }

  Future<List<Career>> fetchCareers({String? facultyId}) async {
    final query = <String, String>{};
    if (facultyId != null) query['facultyId'] = facultyId;
    final resp = await ApiClient.instance.get('/directory/careers', query);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Career.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error cargando careers: ${resp.statusCode}');
  }
}
