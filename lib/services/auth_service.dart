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
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }

    // Si no hay baseUrl configurada usar mock
    if (ApiClient.instance.baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      _accessToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
      ApiClient.instance.setToken(_accessToken);
      isLoggedIn.value = true;
      return;
    }

    // Llamada real al backend
    final payload = {'email': email.trim(), 'password': password};
    final resp = await ApiClient.instance.post('/auth/login', payload);
    if (resp.statusCode == 200) {
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final token = data['accessToken'] as String? ?? data['token'] as String?;
        if (token == null) throw Exception('Token no recibido');
        _accessToken = token;
        await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
        ApiClient.instance.setToken(_accessToken);
        // Obtener perfil del usuario
        final meResp = await ApiClient.instance.get('/me');
        if (meResp.statusCode == 200) {
          final meJson = jsonDecode(meResp.body) as Map<String, dynamic>;
          _userProfile = UserProfile.fromJson(meJson);
          await _storage.write(key: _kUserProfileKey, value: jsonEncode(_userProfile!.toJson()));
        }
        isLoggedIn.value = true;
        return;
      } catch (e) {
        throw Exception('Error parseando respuesta de login: $e');
      }
    }
    // Error del servidor
    final body = resp.body;
    throw Exception('Error login: $resp.statusCode $body');
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
      
      // Si no hay baseUrl configurada usar mock
      if (ApiClient.instance.baseUrl.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 600));
        _accessToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
        ApiClient.instance.setToken(_accessToken);
        // Crear y almacenar perfil de usuario local
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
        return;
      }

      // Llamada real al backend
      final resp = await ApiClient.instance.post('/auth/register', payload);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        try {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final token = data['accessToken'] as String? ?? data['token'] as String?;
          if (token == null) throw Exception('Token no recibido');
          _accessToken = token;
          await _storage.write(key: _kAccessTokenKey, value: _accessToken!);
          ApiClient.instance.setToken(_accessToken);
          // Obtener perfil del usuario
          final meResp = await ApiClient.instance.get('/me');
          if (meResp.statusCode == 200) {
            final meJson = jsonDecode(meResp.body) as Map<String, dynamic>;
            _userProfile = UserProfile.fromJson(meJson);
            await _storage.write(key: _kUserProfileKey, value: jsonEncode(_userProfile!.toJson()));
          }
          isLoggedIn.value = true;
          return;
        } catch (e) {
          throw Exception('Error parseando respuesta de register: $e');
        }
      }
      final body = resp.body;
      throw Exception('Error register: $resp.statusCode $body');
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
