import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/subjects_service.dart';
import '../models/post_models.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _postsService = PostsService.instance;
  final _subjectsService = SubjectsService.instance;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  int _selectedRole = 2; // Por defecto: Student (necesito ayuda)
  String? _selectedSubjectId;
  List<Subject> _subjects = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _subjectsService.getSubjects();
    if (mounted) {
      setState(() {
        _subjects = subjects;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E3F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El contenido no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Mapeo Frontend → Backend
    // Frontend: 0=Student(Necesita), 1=Helper(Ofrece), 2=Comment
    // Backend:  1=Helper,            2=Student,          3=Comment
    final int backendRole;
    switch (_selectedRole) {
      case 0:
        backendRole = 2; // Student/Necesito ayuda
        break;
      case 1:
        backendRole = 1; // Helper/Ofrezco ayuda
        break;
      case 2:
        backendRole = 3; // Comment
        break;
      default:
        backendRole = 2;
    }

    debugPrint('Creating post with role: $backendRole (frontend: $_selectedRole)');

    final createdPost = await _postsService.createPost(
      content: _contentController.text.trim(),
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      role: backendRole,
      subjectId: _selectedSubjectId,
    );

    setState(() => _isLoading = false);

    if (createdPost != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, createdPost);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la publicación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
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
              onPressed: _createPost,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubjectId = value);
              },
              hint: const Text('Selecciona una materia'),
            ),
            const SizedBox(height: 16),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título (opcional)',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16),

            // Selector de fecha (placeholder para Calendly)
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1B5E3F)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Seleccionar fecha (opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() => _selectedDate = null);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Banner informativo de Calendly
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1B5E3F).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1B5E3F), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La integración con Calendly estará disponible próximamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
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
