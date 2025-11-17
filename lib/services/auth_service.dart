import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._private();

  static final AuthService instance = AuthService._private();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  UserProfile? _userProfile;

  static const _kAccessTokenKey = 'access_token';
  static const _kUserProfileKey = 'user_profile';

  Future<void> init() async {
    final token = await _storage.read(key: _kAccessTokenKey);
    if (token != null) {
      _accessToken = token;
      ApiClient.instance.setToken(token);
      isLoggedIn.value = true;
    }
    // Cargar perfil del usuario si existe
    final profileJson = await _storage.read(key: _kUserProfileKey);
    if (profileJson != null) {
      try {
        _userProfile = UserProfile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
      } catch (e) {
        _userProfile = null;
      }
    }
  }

  UserProfile? getUserProfile() => _userProfile;

  Future<void> login(String email, String password) async {
    // Mock login - sin validación del servidor
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }
    
    // Simular un pequeño delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generar un token simulado
    _accessToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
    ApiClient.instance.setToken(_accessToken);
    isLoggedIn.value = true;
  }

  Future<void> register(Map<String, dynamic> payload) async {
    try {
      // Validate required fields
      if ((payload['email'] as String?)?.isEmpty ?? true) {
        throw Exception('Email es requerido');
      }
      if ((payload['password'] as String?)?.isEmpty ?? true) {
        throw Exception('Contraseña es requerida');
      }
      if ((payload['firstName'] as String?)?.isEmpty ?? true) {
        throw Exception('Nombre es requerido');
      }
      if ((payload['lastName'] as String?)?.isEmpty ?? true) {
        throw Exception('Apellido es requerido');
      }
      
      // Simular un pequeño delay de red
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Generar un token simulado
      _accessToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
      ApiClient.instance.setToken(_accessToken);
      
      // Crear y almacenar perfil de usuario
      _userProfile = UserProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        firstName: payload['firstName'] as String? ?? '',
        lastName: payload['lastName'] as String? ?? '',
        email: payload['email'] as String? ?? '',
        phone: payload['phone'] as String?,
        career: payload['career'] as String?,
        semester: payload['semester'] as int?,
      );
      await _storage.write(key: _kUserProfileKey, value: jsonEncode(_userProfile!.toJson()));
      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _userProfile = null;
    ApiClient.instance.setToken(null);
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kUserProfileKey);
    isLoggedIn.value = false;
  }

  String? get token => _accessToken;
}
