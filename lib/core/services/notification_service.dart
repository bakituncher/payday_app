import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Arka plan mesajlarını işlemek için üst düzey fonksiyon (Class dışında olmalı)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Arka plan mesajı alındı: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Arka plan handler'ı kaydet (main.dart içinde de çağrılabilir ama burada tanımlı olması iyidir)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Yerel Bildirim Ayarları (Ön planda göstermek için)
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
        // Bildirime tıklandığında yapılacak işlemler
        debugPrint("Bildirime tıklandı: ${details.payload}");
      },
    );

    // 3. Android için Bildirim Kanalı Oluştur (Önemli)
    await _createNotificationChannel();

    // 4. Ön Plan Mesajlarını Dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotification(message);
    });

    // 5. Uygulama kapalıyken bildirime tıklanıp açıldığında
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Bildirim ile uygulama açıldı: ${message.data}");
      // Burada ilgili ekrana yönlendirme yapabilirsiniz
    });

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    // Firebase Messaging İzinleri
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Kullanıcı izin durumu: ${settings.authorizationStatus}');

    // FCM Token'ı Al ve Yazdır
    await _getToken();
  }

  Future<void> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("🔥 FCM Token: $token");
      // Bu token'ı veritabanınıza kaydedip sunucunuzdan bildirim atarken kullanacaksınız.
    } catch (e) {
      debugPrint("FCM Token alma hatası: $e");
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Yüksek Öncelikli Bildirimler', // title
      description: 'Bu kanal önemli bildirimler içindir.', // description
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // FCM mesajı geldiğinde yerel bildirim olarak göster
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
        payload: message.data.toString(),
      );
    }
  }
}