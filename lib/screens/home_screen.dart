import 'package:flutter/material.dart';
import '../models/post_models.dart';
import '../services/posts_service.dart';
import 'post_detail_screen.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Post> _posts = [];
  int _page = 1;
  final int _pageSize = 20;
  bool _loading = false;
  bool _hasMore = true;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios desde PostsService (modo mock actualiza postsNotifier)
    PostsService.instance.postsNotifier.addListener(_onPostsUpdated);
    _loadMore();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels > _scrollCtrl.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    PostsService.instance.postsNotifier.removeListener(_onPostsUpdated);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onPostsUpdated() {
    final updated = PostsService.instance.postsNotifier.value;
    setState(() {
      _posts.clear();
      _posts.addAll(updated);
      // ajustamos paginado simple
      _hasMore = false;
      _page = 1;
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    try {
      final fetched = await PostsService.instance.fetchPosts(page: _page, pageSize: _pageSize);
      setState(() {
        _posts.addAll(fetched);
        _page++;
        if (fetched.length < _pageSize) _hasMore = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando posts: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _posts.isEmpty && !_loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feed_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No hay publicaciones', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Sé el primero en compartir', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= _posts.length) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator()));
                  }
                  final p = _posts[i];
                  return PostCard(
                    post: p,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id))),
                  );
                },
              ),
      ),
    );
  }
}
