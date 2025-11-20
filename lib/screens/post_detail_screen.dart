import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/auth_service.dart';
import '../models/post_models.dart';
import 'edit_post_screen.dart';

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
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);

    // Cargar todos los posts y buscar el específico
    final posts = await _postsService.getPosts(pageSize: 100);
    final post = posts.where((p) => p.id == widget.postId).firstOrNull;

    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reply = await _postsService.addReply(
      widget.postId,
      _replyController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (reply != null && mounted) {
      _replyController.clear();
      FocusScope.of(context).unfocus();
      
      // Agregar la respuesta a la lista local
      setState(() {
        _post?.replies ??= [];
        _post?.replies?.add(reply);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario agregado'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar comentario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editPost() async {
    if (_post == null) return;

    final updatedPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: _post!),
      ),
    );

    if (updatedPost != null && mounted) {
      setState(() {
        _post = updatedPost;
      });
    }
  }

  Future<void> _deletePost() async {
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
      final success = await _postsService.deletePost(widget.postId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación eliminada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retornar true para indicar que se eliminó
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

  String _getRoleLabel(int role) {
    switch (role) {
      case 1: return '🤝 Ofrezco ayuda';
      case 2: return '🆘 Necesito ayuda';
      case 3: return '💬 Comentario';
      default: return '';
    }
  }

  Color _getRoleColor(int role) {
    switch (role) {
      case 1: return Colors.green;
      case 2: return Colors.red;
      case 3: return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyPost = _authService.currentUser?.id == _post?.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Publicación'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
        actions: [
          if (isMyPost && _post != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _editPost();
                if (value == 'delete') _deletePost();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Borrar')),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Publicación no encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header con usuario
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _post!.user?.profilePhotoUrl != null
                                      ? NetworkImage(_post!.user!.profilePhotoUrl!)
                                      : null,
                                  child: _post!.user?.profilePhotoUrl == null
                                      ? Text(
                                          (_post!.user?.firstName ?? 'U')[0].toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_post!.user?.firstName ?? ''} ${_post!.user?.lastName ?? ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _post!.createdAtUtc?.split('T').first ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Rol badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getRoleColor(_post!.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getRoleColor(_post!.role).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _getRoleLabel(_post!.role),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getRoleColor(_post!.role),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Materia
                            if (_post!.subject != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Chip(
                                  label: Text(_post!.subject!.name),
                                  backgroundColor: const Color(0xFFF1F8F3),
                                ),
                              ),

                            // Título
                            if (_post!.title != null && _post!.title!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _post!.title!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // Contenido
                            Text(
                              _post!.content,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Sección de respuestas
                            Text(
                              'Comentarios (${_post!.replies?.length ?? 0})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lista de respuestas
                            if (_post!.replies != null && _post!.replies!.isNotEmpty)
                              ..._post!.replies!.map((reply) => _buildReply(reply)),

                            if (_post!.replies?.isEmpty ?? true)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No hay comentarios aún',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Campo para agregar respuesta
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyController,
                                decoration: InputDecoration(
                                  hintText: 'Escribe un comentario...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _addReply(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _isSubmitting
                                ? const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: _addReply,
                                    color: const Color(0xFF1B5E3F),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildReply(PostReply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: reply.user?.profilePhotoUrl != null
                    ? NetworkImage(reply.user!.profilePhotoUrl!)
                    : null,
                child: reply.user?.profilePhotoUrl == null
                    ? Text(
                        (reply.user?.firstName ?? 'U')[0].toUpperCase(),
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
                      '${reply.user?.firstName ?? ''} ${reply.user?.lastName ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      reply.createdAtUtc?.split('T').first ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
