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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading && _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
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
                        'No hay publicaciones aún',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sé el primero en publicar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _posts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
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
    );
  }
}
