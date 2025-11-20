import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/subjects_service.dart';
import '../services/auth_service.dart';
import '../models/post_models.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'edit_post_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _postsService = PostsService.instance;
  final _subjectsService = SubjectsService.instance;
  final _authService = AuthService.instance;
  final _searchController = TextEditingController();
  
  List<Post> _posts = [];
  List<Subject> _subjects = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  int? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _subjectsService.getSubjects();
    if (mounted) {
      setState(() {
        _subjects = subjects;
      });
    }
  }

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un término de búsqueda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Buscar por materia
    final posts = await _postsService.searchPostsBySubject(
      _searchController.text.trim(),
      page: 1,
      pageSize: 50,
    );

    if (mounted) {
      setState(() {
        // Filtrar por rol si está seleccionado
        _posts = _selectedRole != null
            ? posts.where((p) => p.role == _selectedRole).toList()
            : posts;
        _isLoading = false;
      });
    }
  }

  void _filterByRole(int? role) {
    setState(() {
      _selectedRole = role;
    });
    if (_hasSearched) {
      _search();
    }
  }

  Future<void> _navigateToDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.id),
      ),
    );
    if (_hasSearched) {
      _search();
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por materia...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E3F)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _posts = [];
                                _hasSearched = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1B5E3F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1B5E3F), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _search(),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                
                // Filtros de rol
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilter(null, 'Todos'),
                      const SizedBox(width: 8),
                      _buildRoleFilter(1, '🤝 Ofrezco ayuda'),
                      const SizedBox(width: 8),
                      _buildRoleFilter(2, '🆘 Necesito ayuda'),
                      const SizedBox(width: 8),
                      _buildRoleFilter(3, '💬 Comentario'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Busca publicaciones por materia',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Escribe el nombre de una materia',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No se encontraron resultados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Intenta con otro término',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              final isMyPost = _authService.currentUser?.id == post.user?.id;
                              
                              return PostCard(
                                post: post,
                                onTap: () => _navigateToDetail(post),
                                onEdit: isMyPost ? () => _editPost(post, index) : null,
                                onDelete: isMyPost ? () => _deletePost(post.id, index) : null,
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _search,
        backgroundColor: const Color(0xFF1B5E3F),
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildRoleFilter(int? role, String label) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _filterByRole(selected ? role : null);
      },
      selectedColor: const Color(0xFF1B5E3F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1B5E3F),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1B5E3F) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1B5E3F) : Colors.grey[300]!,
        ),
      ),
    );
  }
}
