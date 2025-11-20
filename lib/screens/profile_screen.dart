import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/careers.dart';
import 'login_screen.dart';
import '../models/auth_models.dart';
import 'avatar_picker_screen.dart';
import '../services/avatars_service.dart';
import 'calendly_logs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService.instance;
  bool _isEditing = false;
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _semesterController = TextEditingController();
  String? _selectedCareer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
      _semesterController.text = user.semester?.toString() ?? '';
      _selectedCareer = user.career;
    }
  }

  Future<void> _saveChanges() async {
    if (_firstNameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre es requerido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El apellido es requerido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // TODO: Implementar llamada al backend PUT /users/me
    // final success = await _userService.updateProfile(...);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _authService.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeAvatar() async {
    final selectedAvatar = await Navigator.push<Avatar>(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarPickerScreen(),
      ),
    );

    if (selectedAvatar != null && mounted) {
      // TODO: Implementar actualización del avatar en el backend
      // PUT /users/me con avatarId
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar seleccionado: ${selectedAvatar.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _viewCalendlyLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendlyLogsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      });
      
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
              tooltip: 'Editar perfil',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar con botón para cambiar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFEFEFEF),
                  backgroundImage: user.profilePhotoUrl != null
                      ? NetworkImage(user.profilePhotoUrl!)
                      : null,
                  child: user.profilePhotoUrl == null
                      ? Text(
                          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E3F),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _changeAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E3F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (!_isEditing) ...[
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(user),
            ] else
              _buildEditForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(AuthUser user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.phone,
              'Teléfono',
              user.phoneNumber ?? 'No especificado',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.school,
              'Semestre',
              user.semester?.toString() ?? 'No especificado',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.book,
              'Carrera',
              user.career ?? 'No especificada',
            ),
            const Divider(),
            // Botón para ver logs de Calendly (solo en debug/admin)
            ListTile(
              leading: const Icon(Icons.webhook, color: Color(0xFF1B5E3F)),
              title: const Text('Calendly Webhooks'),
              subtitle: const Text('Ver eventos recibidos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _viewCalendlyLogs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E3F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildTextField(
          controller: _firstNameController,
          label: 'Nombre',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Apellido',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _semesterController,
          label: 'Semestre',
          icon: Icons.school,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _selectedCareer != null && UpsaCareers.allCareers.contains(_selectedCareer)
              ? _selectedCareer
              : null,
          decoration: InputDecoration(
            labelText: 'Carrera',
            prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF1B5E3F)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B5E3F), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: UpsaCareers.allCareers.map((String career) {
            return DropdownMenuItem<String>(
              value: career,
              child: Text(
                career,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedCareer = value;
            });
          },
          hint: const Text('Selecciona tu carrera'),
          isExpanded: true,
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _loadUserData();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF1B5E3F)),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF1B5E3F)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1B5E3F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E3F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B5E3F), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
