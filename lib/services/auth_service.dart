import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import 'api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._private();
  static final AuthService instance = AuthService._private();

  final _apiClient = ApiClient.instance;
  final _secureStorage = const FlutterSecureStorage();

  // ✅ Cambiar a getter/setter públicos
  AuthUser? _currentUser;
  
  AuthUser? get currentUser => _currentUser;
  set currentUser(AuthUser? user) => _currentUser = user;

  String? _accessToken;
  String? _refreshToken;

  bool get isLoggedIn => _currentUser != null && _accessToken != null;

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? careerId,
    int? semester,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (careerId != null) 'careerId': careerId,
        if (semester != null) 'semester': semester,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar tokens
        _accessToken = data['accessToken'] as String?;
        _refreshToken = data['refreshToken'] as String?;
        
        if (_accessToken != null) {
          _apiClient.setToken(_accessToken);
          
          // Obtener datos del usuario
          await _fetchCurrentUser();
          
          // Programar refresh automático en 55 minutos (antes de que expire)
          _scheduleTokenRefresh();
          
          return true;
        }
      }
      
      debugPrint('Register failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar tokens
        _accessToken = data['accessToken'] as String?;
        _refreshToken = data['refreshToken'] as String?;
        
        if (_accessToken != null) {
          _apiClient.setToken(_accessToken);
          
          // Obtener datos del usuario
          await _fetchCurrentUser();
          
          // Programar refresh automático en 55 minutos
          _scheduleTokenRefresh();
          
          return true;
        }
      }
      
      debugPrint('Login failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fullName = data['fullName'] as String? ?? '';
        final nameParts = fullName.split(' ');

        _currentUser = AuthUser(
          id: data['id'],
          email: data['email'],
          firstName: nameParts.isNotEmpty ? nameParts[0] : '',
          lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          careerId: data['careerId'],
          career: data['career'],
          semester: data['semester'],
          profilePhotoUrl: data['profilePhotoUrl'],
        );
      }
    } catch (e) {
      debugPrint('Fetch user error: $e');
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) {
      debugPrint('No refresh token available');
      return false;
    }

    try {
      final response = await _apiClient.post('/auth/refresh', {
        'refreshToken': _refreshToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Actualizar tokens
        _accessToken = data['accessToken'] as String?;
        _refreshToken = data['refreshToken'] as String?;
        
        if (_accessToken != null) {
          _apiClient.setToken(_accessToken);
          
          // Programar siguiente refresh
          _scheduleTokenRefresh();
          
          debugPrint('Token refreshed successfully');
          return true;
        }
      }
      
      debugPrint('Refresh failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }

  // Timer para refresh automático
  Timer? _refreshTimer;

  void _scheduleTokenRefresh() {
    // Cancelar timer anterior si existe
    _refreshTimer?.cancel();
    
    // Programar refresh en 55 minutos (5 min antes de expirar)
    _refreshTimer = Timer(const Duration(minutes: 55), () async {
      debugPrint('Auto-refreshing token...');
      final success = await refreshAccessToken();
      if (!success) {
        debugPrint('Auto-refresh failed, logging out');
        logout();
      }
    });
  }

  void logout() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _refreshTimer?.cancel();
    _apiClient.setToken(null);
  }
}
