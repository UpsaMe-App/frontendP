import 'package:flutter/material.dart';
import '../services/directory_service.dart';
import '../models/directory_models.dart';
import 'careers_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _directoryService = DirectoryService.instance;
  List<Faculty> _faculties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    setState(() => _isLoading = true);
    
    final faculties = await _directoryService.getFaculties();
    
    if (mounted) {
      setState(() {
        _faculties = faculties;
        _isLoading = false;
      });
    }
  }

  void _navigateToCareers(Faculty faculty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareersScreen(faculty: faculty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio Académico'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _faculties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay facultades disponibles',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faculties.length,
                  itemBuilder: (context, index) {
                    final faculty = _faculties[index];
                    return _buildFacultyCard(faculty);
                  },
                ),
    );
  }

  Widget _buildFacultyCard(Faculty faculty) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E3F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.domain,
            color: Color(0xFF1B5E3F),
            size: 28,
          ),
        ),
        title: Text(
          faculty.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            faculty.slug,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToCareers(faculty),
      ),
    );
  }
}
