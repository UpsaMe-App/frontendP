import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/auth_service.dart';
import '../models/post_models.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'edit_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postsService = PostsService.instance;
  final _authService = AuthService.instance;
  final _scrollController = ScrollController();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    final posts = await _postsService.getPosts(page: 1, pageSize: _pageSize);
    
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
        _hasMore = posts.length >= _pageSize;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);

    final newPosts = await _postsService.getPosts(
      page: _currentPage + 1,
      pageSize: _pageSize,
    );
    
    if (mounted) {
      setState(() {
        _currentPage++;
        _posts.addAll(newPosts);
        _isLoading = false;
        _hasMore = newPosts.length >= _pageSize;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  Future<void> _navigateToDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.id),
      ),
    );
    _refreshPosts();
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
    final currentUserId = _authService.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E3F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_rounded,
                size: 24,
                color: Color(0xFF1B5E3F),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Inicio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refreshPosts,
              tooltip: 'Actualizar',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E3F).withOpacity(0.1),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: _isLoading && _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5E3F)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando publicaciones...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _posts.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refreshPosts,
                  color: const Color(0xFF1B5E3F),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.post_add_rounded,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay publicaciones aún',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sé el primero en compartir algo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _refreshPosts,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Actualizar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E3F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshPosts,
                  color: const Color(0xFF1B5E3F),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _posts.length) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5E3F)),
                          ),
                        );
                      }
                      
                      final post = _posts[index];
                      final isMyPost = currentUserId != null && post.user?.id == currentUserId;
                      
                      return PostCard(
                        post: post,
                        onTap: () => _navigateToDetail(post),
                        onEdit: isMyPost ? () => _editPost(post, index) : null,
                        onDelete: isMyPost ? () => _deletePost(post.id, index) : null,
                      );
                    },
                  ),
                ),
    );
  }
}
