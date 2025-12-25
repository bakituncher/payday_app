import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ⚠️ ÖNEMLİ: Bu fonksiyon sınıfın dışında, en üst seviyede olmalıdır.
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

  /// Servisi başlatır.
  /// [navigatorKey]: Bildirime tıklandığında sayfa yönlendirmesi yapmak için gereklidir.
  /// [onTokenRefresh]: Token değiştiğinde (veya ilk açılışta) veritabanına kaydetmek için callback.
  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    Function(String)? onTokenRefresh,
  }) async {
    if (_initialized) return;

    _navigatorKey = navigatorKey;
    _onTokenRefresh = onTokenRefresh;

    // 1. Arka plan handler'ı kaydet
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. İzinleri İste
    await requestPermissions();

    // 3. Yerel Bildirim Kanalı (Android)
    await _createNotificationChannel();

    // 4. Yerel Bildirim Ayarları
    await _initLocalNotifications();

    // 5. Firebase Mesaj Dinleyicileri (Foreground, Background, Terminated)
    _setupMessageListeners();

    // 6. Token İşlemleri (Veritabanı kaydı için)
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
        // Uygulama açıkken bildirime tıklandığında (Foreground click)
        if (details.payload != null) {
          _navigateFromPayload(details.payload!);
        }
      },
    );
  }

  void _setupMessageListeners() {
    // A. Uygulama Açıkken (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("☀️ Ön plan mesajı: ${message.notification?.title}");
      _showForegroundNotification(message);
    });

    // B. Uygulama Arka Plandan Açıldığında (Background -> Foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🚀 Uygulama bildirimle açıldı (Background): ${message.data}");
      _handleRemoteMessageNavigation(message);
    });

    // C. Uygulama Tamamen Kapalıyken Açıldığında (Terminated -> Foreground)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("🏁 Uygulama bildirimle başlatıldı (Terminated): ${message.data}");
        _handleRemoteMessageNavigation(message);
      }
    });
  }

  Future<void> _setupToken() async {
    // Mevcut token'ı al
    String? token = await _firebaseMessaging.getToken();
    if (token != null && _onTokenRefresh != null) {
      debugPrint("🔥 Mevcut FCM Token: $token");
      _onTokenRefresh!(token);
    }

    // Token yenilenirse dinle ve güncelle
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("♻️ FCM Token Yenilendi: $newToken");
      if (_onTokenRefresh != null) {
        _onTokenRefresh!(newToken);
      }
    });
  }

  void _handleRemoteMessageNavigation(RemoteMessage message) {
    // Mesajın data kısmında 'route' anahtarı var mı?
    // Örnek: { "route": "/subscriptions", "itemId": "123", "type": "bill" }
    if (message.data.containsKey('route')) {
      final String route = message.data['route'];

      // NOT: Eğer ileride detay sayfalarına argüman (arguments) göndermek isterseniz
      // message.data['itemId'] gibi değerleri buradan alıp pushNamed arguments parametresine ekleyebilirsiniz.
      // Şimdilik genel rotalara yönlendirme yapıyoruz.

      // Biraz gecikme ekleyerek sayfanın hazır olmasını bekle (özellikle cold start için)
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigatorKey?.currentState?.pushNamed(route);
      });
    }
  }

  void _navigateFromPayload(String payload) {
    // Payload doğrudan bir route ise (örn: "/home" veya "/premium")
    if (payload.startsWith('/')) {
      _navigatorKey?.currentState?.pushNamed(payload);
    } else {
      // Karmaşık bir yapıysa (JSON string) decode edilebilir.
      debugPrint("Payload işlenemedi veya route değil: $payload");
    }
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Kullanıcı izin durumu: ${settings.authorizationStatus}');
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
        // Payload olarak Cloud Function'dan gelen 'route' bilgisini kullanıyoruz.
        // Eğer route gelmezse varsayılan olarak '/home' rotasına git.
        payload: message.data['route'] ?? '/home',
      );
    }
  }
}