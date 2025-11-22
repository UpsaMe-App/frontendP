import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/directory_service.dart';
import 'main_tabs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService.instance;
  final _directoryService = DirectoryService.instance;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _semesterController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedFacultyId;
  String? _selectedCareerId;
  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _careers = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 RegisterScreen: Iniciando carga de facultades...');
    _loadFaculties();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _loadFaculties() async {
    debugPrint('📡 Cargando facultades desde backend...');
    final faculties = await _directoryService.getFacultiesMap();
    
    debugPrint('✅ Facultades recibidas: ${faculties.length}');
    
    if (mounted) {
      setState(() {
        _faculties = faculties;
      });
      
      if (faculties.isEmpty) {
        debugPrint('⚠️ No se recibieron facultades del backend');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ No se pudieron cargar las facultades. Verifica tu conexión.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        debugPrint('✅ ${faculties.length} facultades disponibles');
        for (var f in faculties) {
          debugPrint('   - ${f['name']} (${f['id']})');
        }
      }
    }
  }

  Future<void> _loadCareers(String facultyId) async {
    debugPrint('📡 Cargando carreras para facultad: $facultyId');
    final careers = await _directoryService.getCareersMap(facultyId);
    
    debugPrint('✅ Carreras recibidas: ${careers.length}');
    
    if (mounted) {
      setState(() {
        _careers = careers;
        _selectedCareerId = null;
      });
      
      if (careers.isEmpty) {
        debugPrint('⚠️ No se recibieron carreras para esta facultad');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Esta facultad no tiene carreras disponibles'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('✅ ${careers.length} carreras disponibles');
        for (var c in careers) {
          debugPrint('   - ${c['name']} (${c['id']})');
        }
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════╗');
    debugPrint('║     📝 REGISTRANDO NUEVO USUARIO      ║');
    debugPrint('╚═══════════════════════════════════════');
    debugPrint('📧 Email: ${_emailController.text.trim()}');
    debugPrint('👤 Nombre: ${_firstNameController.text.trim()} ${_lastNameController.text.trim()}');
    debugPrint('🎓 CareerId: $_selectedCareerId');
    debugPrint('📚 Semester: ${_semesterController.text}');
    debugPrint('═══════════════════════════════════════');

    setState(() => _isLoading = true);

    final success = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      careerId: _selectedCareerId,
      semester: _semesterController.text.isNotEmpty 
          ? int.tryParse(_semesterController.text) 
          : null,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      debugPrint('✅ REGISTRO EXITOSO - Usuario autenticado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cuenta creada exitosamente'),
          backgroundColor: Color(0xFF1B5E3F),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTabs()),
      );
    } else if (mounted) {
      debugPrint('❌ REGISTRO FALLÓ');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al registrar. El email podría estar en uso.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E3F),
              Color(0xFF2D8659),
              Color(0xFF3FA675),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con animación
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 60,
                          color: Color(0xFF1B5E3F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a la comunidad UpsaMe',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Card contenedor del formulario
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'Nombre',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El apellido es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El email es requerido';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La contraseña es requerida';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'Teléfono (opcional)',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _buildDropdown<String>(
                            value: _selectedFacultyId,
                            label: 'Facultad (opcional)',
                            icon: Icons.domain,
                            items: _faculties.isEmpty
                                ? [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: Text('Cargando facultades...'),
                                    )
                                  ]
                                : _faculties.map((faculty) {
                                    return DropdownMenuItem<String>(
                                      value: faculty['id'] as String,
                                      child: Text(faculty['name'] as String),
                                    );
                                  }).toList(),
                            onChanged: (value) {
                              if (_faculties.isEmpty) return;
                              setState(() {
                                _selectedFacultyId = value;
                                _careers = [];
                                _selectedCareerId = null;
                              });
                              if (value != null) {
                                _loadCareers(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildDropdown<String>(
                            value: _selectedCareerId,
                            label: 'Carrera (opcional)',
                            icon: Icons.school_outlined,
                            items: _selectedFacultyId == null
                                ? [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: Text('Primero selecciona una facultad'),
                                    )
                                  ]
                                : _careers.isEmpty
                                    ? [
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          enabled: false,
                                          child: Text('Cargando carreras...'),
                                        )
                                      ]
                                    : _careers.map((career) {
                                        return DropdownMenuItem<String>(
                                          value: career['id'] as String,
                                          child: Text(career['name'] as String),
                                        );
                                      }).toList(),
                            onChanged: (value) {
                              if (_careers.isEmpty) return;
                              setState(() {
                                _selectedCareerId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _semesterController,
                            label: 'Semestre (opcional)',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            isLastField: true, // ← Agregar esto
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final semester = int.tryParse(value);
                                if (semester == null || semester < 1 || semester > 12) {
                                  return 'Semestre válido: 1-12';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de registro mejorado
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B5E3F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5E3F)),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registrarse',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Link a login mejorado
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
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
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool isLastField = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (value) {
        if (isLastField) {
          // Auto-registrar al presionar Enter en el último campo
          _register();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF2D8659).withOpacity(0.3), // Verde más claro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF3FA675).withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF3FA675).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3FA675), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.white),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      dropdownColor: const Color(0xFF1B5E3F),
      style: const TextStyle(color: Colors.white),
      items: items,
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
