import 'package:flutter/material.dart';
import '../services/users_service.dart';
import '../services/posts_service.dart';
import '../models/auth_models.dart';
import '../models/post_models.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _usersService = UsersService.instance;
  final _postsService = PostsService.instance;
  
  AuthUser? _user;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _loadingPosts = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final user = await _usersService.getUserById(widget.userId);
    
    if (user != null && mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
      
      _loadUserPosts();
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() => _loadingPosts = true);
    
    final allPosts = await _postsService.getPosts(pageSize: 100);
    final userPosts = allPosts.where((post) => post.user?.id == widget.userId).toList();
    
    if (mounted) {
      setState(() {
        _userPosts = userPosts;
        _loadingPosts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Usuario no encontrado',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFEFEFEF),
                        backgroundImage: _user!.profilePhotoUrl != null
                            ? NetworkImage(_user!.profilePhotoUrl!)
                            : null,
                        child: _user!.profilePhotoUrl == null
                            ? Text(
                                _user!.firstName.isNotEmpty 
                                    ? _user!.firstName[0].toUpperCase() 
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E3F),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        '${_user!.firstName} ${_user!.lastName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        _user!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.school,
                                'Semestre',
                                _user!.semester?.toString() ?? 'No especificado',
                              ),
                              if (_user!.career != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.book,
                                  'Carrera',
                                  _user!.career!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Publicaciones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E3F),
                            ),
                          ),
                          if (_userPosts.isNotEmpty)
                            Text(
                              '${_userPosts.length}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (_loadingPosts)
                        const Center(child: CircularProgressIndicator())
                      else if (_userPosts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.post_add, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'Este usuario no tiene publicaciones',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._userPosts.map((post) => PostCard(
                          post: post,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(postId: post.id),
                              ),
                            );
                          },
                          onEdit: null,
                          onDelete: null,
                        )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E3F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
