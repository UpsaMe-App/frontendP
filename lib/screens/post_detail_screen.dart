import 'package:flutter/material.dart';
import '../models/post_models.dart';
import '../services/posts_service.dart';
import '../services/auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _postsService = PostsService.instance;
  final _authService = AuthService.instance;
  final _replyController = TextEditingController();
  
  Post? _post;
  List<PostReply> _replies = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    setState(() => _isLoading = true);
    
    // Aquí deberías tener un método para obtener el detalle completo
    // Por ahora, obtenemos todos los posts y filtramos
    final posts = await _postsService.getPosts(pageSize: 100);
    final post = posts.firstWhere((p) => p.id == widget.postId, orElse: () => posts.first);
    
    if (mounted) {
      setState(() {
        _post = post;
        _replies = post.replies ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    final newReply = await _postsService.addReply(
      widget.postId,
      _replyController.text.trim(),
    );
    
    setState(() => _isSubmitting = false);
    
    if (newReply != null && mounted) {
      setState(() {
        _replies.insert(0, newReply);
        _replyController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Respuesta enviada'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al enviar respuesta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Publicación'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Publicación no encontrada'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPostHeader(),
                            const SizedBox(height: 16),
                            _buildPostContent(),
                            const SizedBox(height: 24),
                            _buildRepliesSection(),
                          ],
                        ),
                      ),
                    ),
                    _buildReplyInput(),
                  ],
                ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEFEFEF),
          backgroundImage: _post!.user?.profilePhotoUrl != null
              ? NetworkImage(_post!.user!.profilePhotoUrl!)
              : null,
          child: _post!.user?.profilePhotoUrl == null
              ? Text(
                  _post!.user?.fullName.isNotEmpty == true 
                      ? _post!.user!.fullName[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E3F),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post!.user?.fullName ?? 'Usuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(_post!.createdAtUtc),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_post!.title != null && _post!.title!.isNotEmpty) ...[
          Text(
            _post!.title!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        Text(
          _post!.content,
          style: const TextStyle(fontSize: 16),
        ),
        
        if (_post!.subject != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.book, size: 18, color: Color(0xFF1B5E3F)),
                const SizedBox(width: 8),
                Text(
                  _post!.subject!.name,
                  style: const TextStyle(
                    color: Color(0xFF1B5E3F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (_post!.role == 1 && _post!.capacity != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people, size: 18),
              const SizedBox(width: 8),
              Text('Cupos: ${_post!.capacity}/${_post!.maxCapacity ?? 0}'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRepliesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Respuestas (${_replies.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_replies.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No hay respuestas aún'),
            ),
          )
        else
          ..._replies.map((reply) => _buildReplyCard(reply)),
      ],
    );
  }

  Widget _buildReplyCard(PostReply reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFEFEFEF),
                  backgroundImage: reply.user?.profilePhotoUrl != null
                      ? NetworkImage(reply.user!.profilePhotoUrl!)
                      : null,
                  child: reply.user?.profilePhotoUrl == null
                      ? Text(
                          reply.user?.fullName.isNotEmpty == true
                              ? reply.user!.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.user?.fullName ?? 'Usuario',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(reply.createdAtUtc),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.content),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Escribe una respuesta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSubmitting ? null : _submitReply,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: const Color(0xFF1B5E3F),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }
}
