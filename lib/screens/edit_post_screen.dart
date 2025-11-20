import 'package:flutter/material.dart';
import '../models/post_models.dart';
import '../services/posts_service.dart';
import '../services/subjects_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _postsService = PostsService();
  final _subjectsService = SubjectsService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  int _selectedRole = 0;
  String? _selectedSubjectId;
  List<Subject> _subjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title ?? '';
    _contentController.text = widget.post.content;
    _selectedRole = widget.post.role;
    _selectedSubjectId = widget.post.subject?.id;
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _subjectsService.getSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _saveChanges() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El contenido no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedPost = await _postsService.updatePost(
      postId: widget.post.id,
      content: _contentController.text.trim(),
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      role: _selectedRole,
      subjectId: _selectedSubjectId,
    );

    setState(() => _isLoading = false);

    if (updatedPost != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedPost);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el post'),
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
        title: const Text('Editar Post'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de rol
            const Text(
              'Tipo de publicación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildRoleButton(0, '🆘', 'Necesito\nayuda', Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildRoleButton(1, '🤝', 'Ofrezco\nayuda', Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildRoleButton(2, '💬', 'Comentario', Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),

            // Selector de materia
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              decoration: InputDecoration(
                labelText: 'Materia',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubjectId = value);
              },
            ),
            const SizedBox(height: 16),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título (opcional)',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Contenido
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Contenido',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(int role, String emoji, String label, Color color) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
