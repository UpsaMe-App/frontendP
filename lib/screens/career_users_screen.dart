import 'package:flutter/material.dart';
import '../services/directory_service.dart';
import '../models/directory_models.dart';
import 'user_profile_screen.dart';

class CareerUsersScreen extends StatefulWidget {
  final Career career;
  
  const CareerUsersScreen({super.key, required this.career});

  @override
  State<CareerUsersScreen> createState() => _CareerUsersScreenState();
}

class _CareerUsersScreenState extends State<CareerUsersScreen> {
  final _directoryService = DirectoryService.instance;
  List<DirectoryUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final users = await _directoryService.getCareerUsers(widget.career.id);
    
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.career.name),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay usuarios en esta carrera',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _buildUserCard(user);
                  },
                ),
    );
  }

  Widget _buildUserCard(DirectoryUser user) {
    // Verificar si tiene foto válida
    final hasValidPhoto = user.profilePhotoUrl != null && 
                          user.profilePhotoUrl!.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFEFEFEF),
          backgroundImage: hasValidPhoto 
              ? NetworkImage(user.profilePhotoUrl!) 
              : null,
          child: hasValidPhoto
              ? null
              : Text(
                  user.fullName.isNotEmpty 
                      ? user.fullName[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E3F),
                  ),
                ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: user.career != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  user.career!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: user.id),
            ),
          );
        },
      ),
    );
  }
}
