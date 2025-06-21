import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Skip on iOS and web
    if (kIsWeb) {
      log('🌐 Skipping Firebase Messaging initialization on web');
      return;
    }

    // For mobile platforms, we'll need to check iOS differently
    // Since we can't use Platform.isIOS on web, we'll skip this for now
    // and handle iOS detection in a platform-specific way if needed

    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    log('📦 FCM Token: $fcmToken');

    await _initLocalNotifications();
    _initPushNotificationHandlers();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  void _initPushNotificationHandlers() {
    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      log(
        '📩 Foreground Notification Received: ${message.notification?.title}',
      );
      _showLocalNotification(message);
    });

    // Background (app opened from tap)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🔔 Opened from Notification: ${message.notification?.title}');
    });

    // Terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log('🔋 App Launched via Notification: ${message.notification?.title}');
      }
    });
  }
}
