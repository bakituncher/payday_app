import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ⚠️ BU FONKSİYON SINIFIN DIŞINDA KALMALI (Firebase Arka Plan Handler)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🌙 Arka plan FCM mesajı: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  Function(String)? _onTokenRefresh;

  /// Servisi başlatır ve gerekli ayarları yapar.
  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    Function(String)? onTokenRefresh,
  }) async {
    if (_initialized) return;

    _navigatorKey = navigatorKey;
    _onTokenRefresh = onTokenRefresh;

    // 1. Awesome Notifications'ı Başlat
    await _initializeAwesomeNotifications();

    // 2. Firebase Arka Plan Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Firebase İzinleri İste
    await requestPermissions();

    // 4. Firebase Mesaj Dinleyicileri
    _setupMessageListeners();

    // 5. Token İşlemleri
    await _setupToken();

    _initialized = true;
    debugPrint("🔔 NotificationService: Hazır (Awesome Notifications kullanılıyor)");
  }

  /// Awesome Notifications'ı başlatır ve kanalları oluşturur
  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // App icon (null = varsayılan)
      [
        // 1. Günlük Hatırlatıcılar Kanalı
        NotificationChannel(
          channelKey: 'daily_reminders',
          channelName: 'Günlük Hatırlatıcılar',
          channelDescription: 'Rutin bütçe hatırlatmaları',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          playSound: true,
          enableVibration: true,
        ),
        // 2. Firebase Kanalı (FCM mesajları için)
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'Önemli Bildirimler',
          channelDescription: 'Sunucudan gelen önemli bildirimler',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: kDebugMode,
    );

    // Action (tıklama) dinleyicisini ayarla
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationActionReceived,
    );
  }

  /// Bildirime tıklandığında çalışır
  @pragma("vm:entry-point")
  static Future<void> _onNotificationActionReceived(
      ReceivedAction receivedAction) async {
    // Payload varsa navigasyon yap
    if (receivedAction.payload != null &&
        receivedAction.payload!.containsKey('route')) {
      final String route = receivedAction.payload!['route']!;
      // Navigator key'i kullanarak yönlendirme yapılabilir
      // (Bu kısım ana initialize'da ayarlanıyor)
      debugPrint("🔔 Bildirim tıklandı, route: $route");
    }
  }

  /// ⏰ GÜNLÜK RUTİN VE REKLAM PLANLAYICI
  /// [isPremium]: True ise reklam bildirimi atlanacak.
  Future<void> scheduleDailyNotifications(bool isPremium) async {
    // Çakışmayı önlemek için önce eskileri temizle
    await AwesomeNotifications().cancelAll();

    debugPrint("📅 Günlük bildirimler planlanıyor... (Premium: $isPremium)");

    // 1. SABAH (09:00)
    await _scheduleOne(
      id: 100,
      title: "☀️ Günaydın!",
      body: "Güne başlarken bütçeni gözden geçirmeyi unutma.",
      hour: 9,
      minute: 0,
      route: '/home',
    );

    // 2. ÖĞLEN (13:00)
    await _scheduleOne(
      id: 101,
      title: "🍽️ Öğle Arası Hatırlatması",
      body: "Bugün yaptığın harcamaları ekledin mi?",
      hour: 13,
      minute: 0,
      route: '/add-transaction',
    );

    // 3. AKŞAM (23:50)
    await _scheduleOne(
      id: 102,
      title: "🌙YUNUSBABA BAKİBABA KERİMBABA",
      body: "Baki baba başaracağız Allah'ın izniyle!",
      hour: 00,
      minute: 04,
      route: '/monthly-summary',
    );

    // 4. PREMIUM PROPAGANDASI (Sadece Premium Değilse - 18:00)
    if (!isPremium) {
      await _scheduleOne(
        id: 200,
        title: "💎 Reklamsız Payday Deneyimi",
        body: "Premium'a geç, sınırları kaldır ve reklamlardan kurtul!",
        hour: 18,
        minute: 0,
        route: '/premium-paywall',
      );
    }
  }

  /// Tekil bildirim kurma fonksiyonu (Her gün aynı saatte tekrarlanır)
  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String route,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_reminders',
        title: title,
        body: body,
        payload: {'route': route},
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true, // Her gün tekrarla
      ),
    );

    debugPrint("📅 Bildirim planlandı: $title ($hour:${minute.toString().padLeft(2, '0')})");
  }

  /// İzin isteme (Firebase + Awesome Notifications)
  Future<void> requestPermissions() async {
    // 1. Firebase (Remote) İzni
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Awesome Notifications İzni (Yerel bildirimler için)
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  void _setupMessageListeners() {
    // Foreground (Uygulama Açık)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotification(message);
    });

    // Background -> Foreground (Uygulamaya tıklandı)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteMessageNavigation(message);
    });

    // Terminated -> Foreground (Uygulama kapalıyken açıldı)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleRemoteMessageNavigation(message);
      }
    });
  }

  /// Foreground bildirimi göster (FCM için)
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notification.hashCode,
          channelKey: 'high_importance_channel',
          title: notification.title,
          body: notification.body,
          payload: message.data.containsKey('route')
              ? {'route': message.data['route']}
              : null,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }
  }

  void _handleRemoteMessageNavigation(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      final String route = message.data['route'];
      // Sayfanın yüklenmesi için ufak gecikme
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigatorKey?.currentState?.pushNamed(route);
      });
    }
  }


  Future<void> _setupToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null && _onTokenRefresh != null) _onTokenRefresh!(token);
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (_onTokenRefresh != null) _onTokenRefresh!(newToken);
    });
  }
}