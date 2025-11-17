import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/careers.dart';
import 'main_tabs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _semester = TextEditingController();
  String? _selectedCareer;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'phone': _phone.text.trim(),
        'semester': int.tryParse(_semester.text),
        'career': _selectedCareer,
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainTabs()));
    } catch (e) {
      final message = (e is Exception) ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E3F)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9F6), Color(0xFFE8F5F1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B5E3F),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_add, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B5E3F)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Únete a la comunidad UpsaMe',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 32),
                    // Nombre y Apellido
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstName,
                            label: 'Nombre',
                            icon: Icons.person_outline,
                            validator: (v) => (v ?? '').isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastName,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            validator: (v) => (v ?? '').isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Email
                    _buildTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v ?? '').isEmpty ? 'Email requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    // Contraseña
                    _buildTextField(
                      controller: _password,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => (v ?? '').length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    // Teléfono y Semestre
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _phone,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: _buildTextField(
                            controller: _semester,
                            label: 'Semestre',
                            icon: Icons.school_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Carrera dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCareer,
                      isExpanded: true,
                      items: careersMap.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: _loading ? null : (v) => setState(() => _selectedCareer = v),
                      decoration: InputDecoration(
                        labelText: 'Carrera',
                        labelStyle: const TextStyle(color: Color(0xFF1B5E3F)),
                        prefixIcon: const Icon(Icons.school, color: Color(0xFF1B5E3F), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0E8E0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0E8E0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B5E3F), width: 2)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v == null ? 'Selecciona una carrera' : null,
                    ),
                    const SizedBox(height: 28),
                    // Botón crear cuenta
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1B5E3F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                'Crear Cuenta',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      enabled: !_loading,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1B5E3F)),
        prefixIcon: Icon(icon, color: Color(0xFF1B5E3F), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0E8E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0E8E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B5E3F), width: 2)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
