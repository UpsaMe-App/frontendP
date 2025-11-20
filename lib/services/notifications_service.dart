import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../models/notification_models.dart';

class NotificationsService {
  NotificationsService._private();
  static final NotificationsService instance = NotificationsService._private();

  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);

  /// Register device on backend: POST /notifications/devices
  Future<void> registerDevice(RegisterDeviceDto dto) async {
    try {
      final resp = await ApiClient.instance.post('/notifications/devices', dto.toJson());
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return;
      }
      throw Exception('registerDevice failed: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      debugPrint('NotificationsService.registerDevice failed: $e');
      rethrow;
    }
  }

  /// Fetch notifications: GET /notifications
  Future<List<NotificationItem>> fetchNotifications({int page = 1, int pageSize = 30}) async {
    try {
      final resp = await ApiClient.instance.get('/notifications', {'page': page.toString(), 'pageSize': pageSize.toString()});
      if (resp.statusCode == 200) {
        final body = resp.body.trimLeft();
        if (body.isEmpty) return [];
        try {
          final data = jsonDecode(body) as List<dynamic>;
          final list = data.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
          notificationsNotifier.value = List<NotificationItem>.from(list);
          return list;
        } catch (e) {
          debugPrint('NotificationsService.parse failed: $e');
          throw Exception('Invalid server response');
        }
      }
      throw Exception('fetchNotifications failed: ${resp.statusCode}');
    } catch (e) {
      debugPrint('NotificationsService.fetchNotifications error: $e');
      rethrow;
    }
  }

  /// Mark notification as read: POST /notifications/{id}/read
  Future<void> markAsRead(String id) async {
    try {
      final resp = await ApiClient.instance.post('/notifications/$id/read', {});
      if (resp.statusCode == 200) {
        // update cached list
        final list = List<NotificationItem>.from(notificationsNotifier.value);
        final idx = list.indexWhere((n) => n.id == id);
        if (idx != -1) {
          final n = list[idx];
          list[idx] = NotificationItem(id: n.id, title: n.title, body: n.body, isRead: true, createdAtUtc: n.createdAtUtc);
          notificationsNotifier.value = list;
        }
        return;
      }
      throw Exception('markAsRead failed: ${resp.statusCode}');
    } catch (e) {
      debugPrint('NotificationsService.markAsRead failed: $e');
      rethrow;
    }
  }

  /// Send a test notification through backend: POST /notifications/send-test
  Future<void> sendTest(String message) async {
    try {
      // The API expects a simple payload; wrap in object for compatibility
      final payload = {'message': message};
      final resp = await ApiClient.instance.post('/notifications/send-test', payload);
      if (resp.statusCode == 200) return;
      throw Exception('sendTest failed: ${resp.statusCode}');
    } catch (e) {
      debugPrint('NotificationsService.sendTest failed: $e');
      rethrow;
    }
  }
}
