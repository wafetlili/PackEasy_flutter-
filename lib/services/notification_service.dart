import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Initialisation avec écouteur de clic
  Future<void> init({Function(String?)? onNotificationTap}) async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Cette fonction est appelée quand l'utilisateur clique sur la notification
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );
  }

  Future<void> showNotification({
    String title = 'PackEasy',
    String body = 'Action réussie !',
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint('Notification Web : $title - $body (Payload: $payload)');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload, // Le payload permet de savoir quel écran ouvrir
    );
  }
}