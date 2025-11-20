class RegisterDeviceDto {
  final String? provider;
  final String? deviceId;
  final String? pushToken;

  RegisterDeviceDto({this.provider, this.deviceId, this.pushToken});

  Map<String, dynamic> toJson() => {
        if (provider != null) 'provider': provider,
        if (deviceId != null) 'deviceId': deviceId,
        if (pushToken != null) 'pushToken': pushToken,
      };
}

class NotificationDevice {
  final String id;
  final String provider;
  final String? deviceId;
  final String? pushToken;

  NotificationDevice({required this.id, required this.provider, this.deviceId, this.pushToken});

  factory NotificationDevice.fromJson(Map<String, dynamic> j) => NotificationDevice(
        id: j['id'] as String? ?? '',
        provider: j['provider'] as String? ?? '',
        deviceId: j['deviceId'] as String?,
        pushToken: j['pushToken'] as String?,
      );
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAtUtc;

  NotificationItem({required this.id, required this.title, required this.body, required this.isRead, this.createdAtUtc});

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String? ?? '',
        title: (j['title'] ?? j['Title'] ?? '') as String,
        body: (j['body'] ?? j['Body'] ?? '') as String,
        isRead: (j['isRead'] ?? j['IsRead'] ?? false) as bool,
        createdAtUtc: (j['createdAtUtc'] ?? j['CreatedAtUtc']) as String?,
      );
}
