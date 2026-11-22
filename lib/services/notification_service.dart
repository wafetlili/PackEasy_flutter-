// ============================================================
// notification_service.dart
// Notifications :
//  - push Firebase (firebase_messaging) : premier plan,
//    arrière-plan et application fermée
//  - notifications locales (flutter_local_notifications) :
//    déclenchées par une action dans l'application
// Un appui sur la notification ouvre l'écran indiqué par "screen".
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

// Fonction appelée par Firebase quand un message arrive alors que
// l'application est en arrière-plan ou fermée.
// Elle doit être en dehors de toute classe (fonction "top-level").
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Si le message contient un champ "notification", Android l'affiche tout seul.
  debugPrint('Message reçu en arrière-plan : ${message.messageId}');
}

class NotificationService {
  // Une seule instance pour toute l'application
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const String _channelId = 'packeasy_channel';
  static const String _offersKey = 'notif_offers';
  static const String _offersTopic = 'offers';

  // Clé VAPID (uniquement pour les notifications push sur le web).
  // Console Firebase > Paramètres > Cloud Messaging > Certificats Web Push.
  static const String _vapidKey = '';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ------------------------------------------------------------
  // Initialisation (appelée une seule fois dans main)
  // [onOpenScreen] est appelée quand l'utilisateur appuie sur une notification
  // ------------------------------------------------------------
  Future<void> init({required void Function(String? screen) onOpenScreen}) async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb) {
      // 1. Notifications locales (pas disponibles sur le web)
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        // Appui sur une notification locale
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          onOpenScreen(response.payload);
        },
      );

      // 2. Messages reçus quand l'application est en arrière-plan
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    // 3. Message reçu quand l'application est au premier plan :
    //    Firebase n'affiche rien tout seul, on affiche donc une notification locale.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 4. Appui sur une notification alors que l'application était en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onOpenScreen(message.data['screen']);
    });

    // 5. Le jeton de l'appareil peut changer : on le met à jour
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) _saveToken(user.uid, token);
    });
  }

  // Demande l'autorisation d'afficher des notifications (Android 13+ et iOS)
  Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      // Sur iOS on affiche nous-mêmes la notification au premier plan
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Permission notifications : $e');
    }
  }

  // ------------------------------------------------------------
  // Écran à ouvrir si l'application a été lancée en appuyant sur
  // une notification (application complètement fermée avant)
  // ------------------------------------------------------------
  Future<String?> getLaunchScreen() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) return message.data['screen'];

      if (!kIsWeb) {
        final details = await _local.getNotificationAppLaunchDetails();
        if (details?.didNotificationLaunchApp ?? false) {
          return details?.notificationResponse?.payload;
        }
      }
    } catch (e) {
      debugPrint('Notification de lancement : $e');
    }
    return null;
  }

  // ------------------------------------------------------------
  // Enregistre le jeton FCM de l'appareil dans users/{uid}
  // (permet d'envoyer une notification à cet utilisateur)
  // ------------------------------------------------------------
  Future<void> saveTokenForUser(String uid) async {
    try {
      if (kIsWeb && _vapidKey.isEmpty) return;
      final token = await FirebaseMessaging.instance
          .getToken(vapidKey: kIsWeb ? _vapidKey : null);
      if (token != null) await _saveToken(uid, token);
    } catch (e) {
      debugPrint('Jeton FCM : $e');
    }
  }

  Future<void> _saveToken(String uid, String token) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  // ------------------------------------------------------------
  // Réglage "recevoir les offres" (abonnement au sujet FCM "offers")
  // ------------------------------------------------------------
  Future<bool> isOffersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offersKey) ?? true;
  }

  Future<void> setOffersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offersKey, enabled);
    if (kIsWeb) return; // les sujets FCM ne sont pas disponibles sur le web
    try {
      if (enabled) {
        await FirebaseMessaging.instance.subscribeToTopic(_offersTopic);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(_offersTopic);
      }
    } catch (e) {
      debugPrint('Sujet FCM : $e');
    }
  }

  // Message FCM reçu au premier plan -> notification locale
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    showNotification(
      title: notification.title ?? 'PackEasy',
      body: notification.body ?? '',
      payload: message.data['screen'],
    );
  }

  // ------------------------------------------------------------
  // Affiche une notification locale (utilisée après une action :
  // connexion, réservation, etc.)
  // [payload] indique l'écran à ouvrir au clic ('reservation', 'favorites'...)
  // ------------------------------------------------------------
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint('Notification web : $title - $body');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'PackEasy',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
