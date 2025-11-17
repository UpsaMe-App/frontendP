import 'dart:convert';

import '../services/api_client.dart';
import '../models/post_models.dart';

class SubjectsService {
  SubjectsService._private();
  static final SubjectsService instance = SubjectsService._private();

  Future<List<Subject>> fetchSubjects({String? careerId, int page = 1, int pageSize = 50}) async {
    final query = <String, String>{'page': page.toString(), 'pageSize': pageSize.toString()};
    if (careerId != null) query['careerId'] = careerId;
    final resp = await ApiClient.instance.get('/directory/subjects', query);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error cargando subjects: ${resp.statusCode}');
  }
}
