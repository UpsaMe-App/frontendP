import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._private();
  static final ApiClient instance = ApiClient._private();

  // Base URL del backend. Debe ser la raíz (sin /index.html ni slash final).
  String baseUrl = 'http://localhost:5034';
  String? _token;

  /// Permite configurar la base URL en tiempo de ejecución (p. ej. cuando se re-conecta al backend)
  void setBaseUrl(String url) {
    // normalize common accidental values (e.g. '/index.html' from static hosts)
    var b = url.trim();
    if (b.endsWith('/index.html')) b = b.substring(0, b.length - '/index.html'.length);
    if (b.endsWith('/')) b = b.substring(0, b.length - 1);
    baseUrl = b;
  }

  String _buildUrl(String path) {
    final b = baseUrl;
    final p = (path.startsWith('/')) ? path : '/$path';
    return '$b$p';
  }

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<http.Response> post(String path, Object? body) async {
    final uri = Uri.parse(_buildUrl(path));
    try {
      debugPrint('📤 POST $uri');
      debugPrint('   Body: ${jsonEncode(body)}');
      final resp = await http.post(uri, headers: _headers(), body: jsonEncode(body));
      debugPrint('📥 Response: ${resp.statusCode}');
      _maybeLogNonJson(resp);
      return resp;
    } catch (e) {
      debugPrint('❌ POST $path error: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String path, Object? body) async {
    final uri = Uri.parse(_buildUrl(path));
    try {
      final resp = await http.put(uri, headers: _headers(), body: jsonEncode(body));
      _maybeLogNonJson(resp);
      return resp;
    } catch (e) {
      debugPrint('PUT $path error: $e');
      rethrow;
    }
  }

  Future<http.Response> get(String path, [Map<String, String>? queryParameters]) async {
    final baseWithPath = _buildUrl(path);
    final uri = Uri.parse(baseWithPath).replace(queryParameters: queryParameters);
    try {
      final resp = await http.get(uri, headers: _headers());
      _maybeLogNonJson(resp);
      return resp;
    } catch (e) {
      debugPrint('GET $path error: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse(_buildUrl(path));
    try {
      final resp = await http.delete(uri, headers: _headers());
      _maybeLogNonJson(resp);
      return resp;
    } catch (e) {
      debugPrint('DELETE $path error: $e');
      rethrow;
    }
  }

  void _maybeLogNonJson(http.Response resp) {
    if (!kDebugMode) return; // solo en modo debug para no filtrar en producción
    final content = resp.body.trimLeft();
    if (content.isEmpty) return;
    // Si la respuesta no comienza con [ o { y el content-type no es json, lo logueamos
    final ct = resp.headers['content-type'] ?? '';
    if (!(ct.contains('application/json') || content.startsWith('{') || content.startsWith('['))) {
      developer.log('ApiClient non-JSON response', name: 'ApiClient', error: {
        'status': resp.statusCode,
        'contentType': ct,
        'bodyPreview': content.length > 400 ? '${content.substring(0, 400)}... (truncated)' : content,
      });
    }
  }

  /// Send a multipart/form-data PUT request. Useful for endpoints like `/users/me` that accept files.
  Future<http.StreamedResponse> putMultipart(String path, Map<String, String> fields, {Map<String, List<int>>? files}) async {
    final uri = Uri.parse(_buildUrl(path));
    final req = http.MultipartRequest('PUT', uri);
    // add headers except content-type, MultipartRequest sets it
    final headers = <String, String>{};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    req.headers.addAll(headers);
    fields.forEach((k, v) {
      req.fields[k] = v;
    });
    if (files != null) {
      for (final entry in files.entries) {
        final name = entry.key;
        final bytes = entry.value;
        req.files.add(http.MultipartFile.fromBytes(name, bytes, filename: name));
      }
    }
    final streamed = await req.send();
    return streamed;
  }

  // Add other methods (put, delete) as needed
}
