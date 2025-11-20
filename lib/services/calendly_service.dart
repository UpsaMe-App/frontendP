import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class CalendlyLog {
  final int id;
  final String? eventType;
  final String receivedAt;
  final String preview;

  CalendlyLog({
    required this.id,
    this.eventType,
    required this.receivedAt,
    required this.preview,
  });

  factory CalendlyLog.fromJson(Map<String, dynamic> json) {
    return CalendlyLog(
      id: json['id'] as int,
      eventType: json['eventType'] as String?,
      receivedAt: json['receivedAt'] as String,
      preview: json['preview'] as String? ?? '',
    );
  }

  DateTime get receivedAtDate {
    try {
      return DateTime.parse(receivedAt);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDate {
    final date = receivedAtDate;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class CalendlyService {
  CalendlyService._private();
  static final CalendlyService instance = CalendlyService._private();
  factory CalendlyService() => instance;

  final _apiClient = ApiClient.instance;

  /// GET /api/CalendlyWebhook/logs - Obtiene los logs de webhooks recibidos
  Future<List<CalendlyLog>> getLogs({int take = 50}) async {
    try {
      final response = await _apiClient.get(
        '/api/CalendlyWebhook/logs',
        {'take': take.toString()},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CalendlyLog.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      debugPrint('Get Calendly logs failed: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Get Calendly logs error: $e');
      return [];
    }
  }

  /// POST /api/CalendlyWebhook/webhook - Enviar webhook de prueba
  /// (Normalmente este endpoint lo llama Calendly automáticamente, 
  /// pero puedes usarlo para testing)
  Future<bool> sendTestWebhook(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        '/api/CalendlyWebhook/webhook',
        payload,
      );
      
      if (response.statusCode == 200) {
        debugPrint('Test webhook sent successfully');
        return true;
      }
      
      debugPrint('Send test webhook failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('Send test webhook error: $e');
      return false;
    }
  }
}
