import 'package:flutter/material.dart';
import '../models/post_models.dart';
import '../services/subjects_service.dart';
import '../services/posts_service.dart';
import '../services/app_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  Subject? _selectedSubject;
  int _role = 1;
  bool _loading = false;
  List<Subject> _subjects = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final s = await SubjectsService.instance.fetchSubjects(pageSize: 200);
      setState(() => _subjects = s);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando materias: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El contenido es requerido'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // Si es comentario (role == 3) enviamos un payload simplificado
      final payload = _role == 3
          ? {
              'title': null,
              'content': _contentCtrl.text.trim(),
              'subjectId': null,
              'capacity': null,
              'role': _role,
            }
          : {
              'title': _titleCtrl.text.trim(),
              'content': _contentCtrl.text.trim(),
              'subjectId': _selectedSubject?.id,
              'capacity': int.tryParse(_capacityCtrl.text),
              'role': _role,
            };
      await PostsService.instance.createPost(payload);
      if (!mounted) return;

      // Si la pantalla fue abierta con Navigator (canPop), cerrarla.
      // En el caso de tabs (no hay ruta a pop), simplemente limpiar el formulario
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // Limpiar campos y mostrar confirmación
        _titleCtrl.clear();
        _contentCtrl.clear();
        _capacityCtrl.clear();
        setState(() {
          _selectedSubject = null;
          _selectedDate = null;
          _role = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicado correctamente')));
        
        // Navegar al Home después de 500ms (para que vea la confirmación)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          AppState.instance.goToHome();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creando post: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear publicación')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Selecciona rol', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _roleButton(1, 'Necesita', Icons.help_outline)),
                  const SizedBox(width: 8),
                  Expanded(child: _roleButton(2, 'Ofrece', Icons.volunteer_activism)),
                  const SizedBox(width: 8),
                  Expanded(child: _roleButton(3, 'Comentario', Icons.comment_outlined)),
                ],
              ),
              const SizedBox(height: 16),

              // Campos para publicar (excepto Comentario)
              if (_role != 3) ...[
                _buildCard(
                  child: TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Título (opcional)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.title, color: Color(0xFF1B5E3F), size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: DropdownButtonFormField<Subject>(
                    initialValue: _selectedSubject,
                    items: _subjects.isEmpty
                        ? []
                        : _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => _selectedSubject = v),
                    decoration: InputDecoration(
                      hintText: 'Selecciona una materia',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.school, color: Color(0xFF1B5E3F), size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Para rol 2 (Ofrece ayuda) mostrar capacidad y fecha
                if (_role == 2) ...[
                  _buildCard(
                    child: TextField(
                      controller: _capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Capacidad máxima (opcional)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF1B5E3F), size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF1B5E3F), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Selecciona una fecha (Calendly)'
                                    : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(
                                  color: _selectedDate == null ? Colors.grey[400] : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1B5E3F)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8DC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFFB700), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Integración de Calendly próximamente',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8B6914)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildCard(
                  padding: const EdgeInsets.all(0),
                  child: TextField(
                    controller: _contentCtrl,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu publicación aquí...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Icon(Icons.description_outlined, color: Color(0xFF1B5E3F), size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Comentario: solo campo de comentario grande
                _buildCard(
                  child: TextField(
                    controller: _contentCtrl,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí... (sin título)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Icon(Icons.chat_bubble_outline, color: Color(0xFF1B5E3F), size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botón publicar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E3F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Publicar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _roleButton(int value, String label, IconData icon) {
    final isSelected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1B5E3F) : Color(0xFFF0F9F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFF1B5E3F) : Color(0xFFD0E8E0),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Color(0xFF1B5E3F), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF1B5E3F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
