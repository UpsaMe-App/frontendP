import 'package:flutter/material.dart';

import '../services/directory_service.dart';
import '../services/posts_service.dart';
import '../models/post_models.dart';
import 'post_detail_screen.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedFacultyId;
  String? _selectedCareerId;
  String? _query;
  List<Faculty> _faculties = [];
  List<Career> _careers = [];
  List<Post> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    try {
      final f = await DirectoryService.instance.fetchFaculties();
      setState(() => _faculties = f);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando facultades: $e')));
    }
  }

  Future<void> _loadCareers(String facultyId) async {
    try {
      final c = await DirectoryService.instance.fetchCareers(facultyId: facultyId);
      setState(() => _careers = c);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando carreras: $e')));
    }
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final posts = await PostsService.instance.fetchPosts(page: 1, pageSize: 50, facultyId: _selectedFacultyId, careerId: _selectedCareerId, q: _query);
      setState(() => _results = posts);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error buscando: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(decoration: const InputDecoration(labelText: 'Buscar (texto)'), onChanged: (v) => _query = v),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedFacultyId,
            items: _faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedFacultyId = v;
                _selectedCareerId = null;
                _careers = [];
              });
              if (v != null) _loadCareers(v);
            },
            decoration: const InputDecoration(labelText: 'Facultad'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCareerId,
            items: _careers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _selectedCareerId = v),
            decoration: const InputDecoration(labelText: 'Carrera'),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _search, child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Buscar'))),
          const SizedBox(height: 12),
          Expanded(child: _results.isEmpty ? const Center(child: Text('No hay resultados')) : ListView.builder(itemCount: _results.length, itemBuilder: (context, i) { final p = _results[i]; return PostCard(post: p, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id)))); })),
        ]),
      ),
    );
  }
}
