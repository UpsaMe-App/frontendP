import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/auth_service.dart';
import '../models/post_models.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'edit_post_screen.dart';

class AuthorProfileScreen extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userAvatarUrl;
  const AuthorProfileScreen({super.key, required this.userId, this.userName, this.userAvatarUrl});

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  final _postsService = PostsService.instance;
  final _authService = AuthService.instance;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);
    
    // Cargar todos los posts y filtrar por userId
    final allPosts = await _postsService.getPosts(pageSize: 100);
    
    if (mounted) {
      setState(() {
        _posts = allPosts.where((p) => p.user?.id == widget.userId).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.id),
      ),
    );
    // Recargar posts después de volver
    _loadUserPosts();
  }

  Future<void> _editPost(Post post, int index) async {
    final updatedPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );

    if (updatedPost != null && mounted) {
      setState(() {
        _posts[index] = updatedPost;
      });
    }
  }

  Future<void> _deletePost(String postId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _postsService.deletePost(postId);
      
      if (success && mounted) {
        setState(() {
          _posts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la publicación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final isMe = currentUser?.id == widget.userId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? (isMe ? 'Mi perfil' : 'Perfil')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserPosts,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header del perfil
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundImage: widget.userAvatarUrl != null 
                              ? NetworkImage(widget.userAvatarUrl!) 
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: widget.userAvatarUrl == null 
                              ? const Icon(Icons.person, size: 40) 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Publicaciones: ${_posts.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Lista de posts
                    Expanded(
                      child: _posts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.post_add,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isMe 
                                        ? 'Aún no tienes publicaciones' 
                                        : 'No hay publicaciones de este usuario',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _posts.length,
                              itemBuilder: (ctx, i) {
                                final post = _posts[i];
                                final canEdit = isMe;
                                
                                return PostCard(
                                  post: post,
                                  onTap: () => _navigateToDetail(post),
                                  onEdit: canEdit ? () => _editPost(post, i) : null,
                                  onDelete: canEdit ? () => _deletePost(post.id, i) : null,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
