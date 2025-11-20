import 'package:flutter/material.dart';
import '../services/directory_service.dart';
import '../models/directory_models.dart';
import 'career_users_screen.dart';

class CareersScreen extends StatefulWidget {
  final Faculty faculty;
  
  const CareersScreen({super.key, required this.faculty});

  @override
  State<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends State<CareersScreen> {
  final _directoryService = DirectoryService.instance;
  List<Career> _careers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  Future<void> _loadCareers() async {
    setState(() => _isLoading = true);
    
    final careers = await _directoryService.getCareers(widget.faculty.id);
    
    if (mounted) {
      setState(() {
        _careers = careers;
        _isLoading = false;
      });
    }
  }

  void _navigateToUsers(Career career) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareerUsersScreen(career: career),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.faculty.name),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _careers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay carreras en esta facultad',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _careers.length,
                  itemBuilder: (context, index) {
                    final career = _careers[index];
                    return _buildCareerCard(career);
                  },
                ),
    );
  }

  Widget _buildCareerCard(Career career) {
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
            color: const Color(0xFF2D8659).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.school,
            color: Color(0xFF2D8659),
            size: 28,
          ),
        ),
        title: Text(
          career.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            career.slug,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToUsers(career),
      ),
    );
  }
}
