import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_tabs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  void _submit() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _loading = true);
    
    final success = await AuthService.instance.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    
    setState(() => _loading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabs()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas. Verifica tu email y contraseña.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary.withOpacity(0.95), primary.withOpacity(0.85), primary.withOpacity(0.75)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      shape: const CircleBorder(),
                      elevation: 10,
                      color: theme.scaffoldBackgroundColor.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('🦉', style: TextStyle(fontSize: 64, color: primary)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('UpsaMe', style: theme.textTheme.displaySmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Tu espacio académico. tu comunidad.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    Card(
                      color: theme.cardColor.withOpacity(0.96),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ingresar', style: theme.textTheme.headlineSmall?.copyWith(color: primary)),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _emailCtrl,
                              enabled: !_loading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: primary, size: 20)),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordCtrl,
                              enabled: !_loading,
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_loading) _submit();
                              },
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline, color: primary, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: primary),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
                                child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Text('Ingresar', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.grey)),
                                TextButton(onPressed: _loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), child: Text('Regístrate', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
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
}
