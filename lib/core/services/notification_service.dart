import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ⚠ ÖNEMLİ: Bu fonksiyon sınıfın dışında, en üst seviyede olmalıdır.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🌙 Arka plan mesajı alındı: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  Function(String)? _onTokenRefresh;

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    Function(String)? onTokenRefresh,
  }) async {
    if (_initialized) return;

    _navigatorKey = navigatorKey;
    _onTokenRefresh = onTokenRefresh;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await requestPermissions();
    await _createNotificationChannel();
    await _initLocalNotifications();

    // Sadece Foreground ve Background-Resume dinleyicileri.
    // getInitialMessage BURADA YOK.
    _setupMessageListeners();

    await _setupToken();

    _initialized = true;
    debugPrint("🔔 NotificationService tamamen başlatıldı.");
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _navigateFromPayload(details.payload!);
        }
      },
    );
  }

  void _setupMessageListeners() {
    // A. Uygulama Açıkken (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("☀ Ön plan mesajı: ${message.notification?.title}");
      _showForegroundNotification(message);
    });

    // B. Uygulama Arka Plandan (Askıdan) Çağrıldığında
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🚀 Uygulama bildirimle açıldı (Background->Foreground): ${message.data}");
      _handleRemoteMessageNavigation(message);
    });

    // ❌ "Terminated" (getInitialMessage) KODU BURADA YOK.
    // O işi Splash Screen yapıyor.
  }

  Future<void> _setupToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null && _onTokenRefresh != null) {
      _onTokenRefresh!(token);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (_onTokenRefresh != null) {
        _onTokenRefresh!(newToken);
      }
    });
  }

  void _handleRemoteMessageNavigation(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      final String route = message.data['route'];
      _navigatorKey?.currentState?.pushNamed(route);
    }
  }

  void _navigateFromPayload(String payload) {
    if (payload.startsWith('/')) {
      _navigatorKey?.currentState?.pushNamed(payload);
    }
  }

  Future<void> requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Yüksek Öncelikli Bildirimler',
      description: 'Bu kanal önemli bildirimler içindir.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Yüksek Öncelikli Bildirimler',
            channelDescription: 'Bu kanal önemli bildirimler içindir.',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'] ?? '/home',
      );
    }
  }
}