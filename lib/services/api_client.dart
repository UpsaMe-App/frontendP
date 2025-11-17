import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._private();
  static final ApiClient instance = ApiClient._private();

  // Base URL del backend - comentada temporalmente para evitar validación del servidor
  // String baseUrl = 'http://localhost:5034';
  // Apuntamos por defecto al backend local Swagger mientras desarrollamos
  String baseUrl = 'http://localhost:5034';
  String? _token;

  /// Permite configurar la base URL en tiempo de ejecución (p. ej. cuando se re-conecta al backend)
  void setBaseUrl(String url) {
    baseUrl = url;
  }

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<http.Response> post(String path, Object? body) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> get(String path, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    return http.get(uri, headers: _headers());
  }

  // Add other methods (put, delete) as needed
}
