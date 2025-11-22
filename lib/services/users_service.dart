import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/auth_models.dart';

class UsersService {
  UsersService._private();
  static final UsersService instance = UsersService._private();
  factory UsersService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /users/me - Obtiene el perfil del usuario actual
  Future<AuthUser?> getMyProfile() async {
    try {
      final response = await _apiClient.get('/users/me');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseUserFromJson(data);
      }
      
      debugPrint('Get my profile failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Get my profile error: $e');
      return null;
    }
  }

  /// GET /users/{id} - Obtiene el perfil de un usuario por ID
  Future<AuthUser?> getUserById(String userId) async {
    try {
      debugPrint('📡 GET /users/$userId');
      final response = await _apiClient.get('/users/$userId');
      
      debugPrint('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseUserFromJson(data);
      }
      
      debugPrint('Get user by ID failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return null;
    }
  }

  /// PUT /users/me - Actualiza el perfil del usuario actual
  Future<AuthUser?> updateMyProfile({
    String? firstName,
    String? lastName,
    String? phone,
    int? semester,
    String? careerId,
    String? avatarId,
    List<int>? profilePhotoBytes,
  }) async {
    try {
      if (profilePhotoBytes != null) {
        final fields = <String, String>{};
        if (firstName != null) fields['FirstName'] = firstName;
        if (lastName != null) fields['LastName'] = lastName;
        if (phone != null) fields['Phone'] = phone;
        if (semester != null) fields['Semester'] = semester.toString();
        if (careerId != null) fields['CareerId'] = careerId;
        if (avatarId != null) fields['AvatarId'] = avatarId;

        final files = <String, List<int>>{
          'ProfilePhoto': profilePhotoBytes,
        };

        final streamedResponse = await _apiClient.putMultipart(
          '/users/me',
          fields,
          files: files,
        );

        if (streamedResponse.statusCode == 200) {
          final responseBody = await streamedResponse.stream.bytesToString();
          final data = jsonDecode(responseBody);
          return _parseUserFromJson(data);
        }

        debugPrint('Update profile failed: ${streamedResponse.statusCode}');
        return null;
      } else {
        final body = <String, dynamic>{};
        if (firstName != null) body['firstName'] = firstName;
        if (lastName != null) body['lastName'] = lastName;
        if (phone != null) body['phone'] = phone;
        if (semester != null) body['semester'] = semester;
        if (careerId != null) body['careerId'] = careerId;
        if (avatarId != null) body['avatarId'] = avatarId;

        final response = await _apiClient.put('/users/me', body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return _parseUserFromJson(data);
        }

        debugPrint('Update profile failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      return null;
    }
  }

  /// GET /users/avatars/options - Obtiene lista de avatares disponibles
  Future<List<Map<String, String>>> getAvatarOptions() async {
    try {
      debugPrint('📡 GET /users/avatars/options');
      final response = await _apiClient.get('/users/avatars/options');
      
      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Avatares disponibles: ${data.length}');
        
        // Mapear exactamente como viene del backend
        return data.map((avatar) => {
          'id': avatar['id'] as String,           // "baby", "chicken", etc.
          'url': avatar['url'] as String,         // "/avatars/baby.png"
          'label': avatar['label'] as String,     // "Baby", "Chicken", etc.
        }).toList();
      }
      
      debugPrint('❌ Get avatar options failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Get avatar options error: $e');
      return [];
    }
  }

  AuthUser _parseUserFromJson(Map<String, dynamic> data) {
    // El backend puede devolver 'fullName' o 'firstName'+'lastName' separados
    String firstName = '';
    String lastName = '';
    
    if (data.containsKey('firstName') && data.containsKey('lastName')) {
      firstName = data['firstName'] as String? ?? '';
      lastName = data['lastName'] as String? ?? '';
    } else if (data.containsKey('fullName')) {
      final fullName = data['fullName'] as String? ?? '';
      final nameParts = fullName.split(' ');
      firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    }
    
    return AuthUser(
      id: data['id'] as String,
      email: data['email'] as String,
      firstName: firstName,
      lastName: lastName,
      careerId: data['careerId'] as String?,
      career: data['career'] as String?,
      semester: data['semester'] as int?,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
    );
  }
}
