import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ EKLİ
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:payday/core/services/revenue_cat_service.dart';
import 'package:payday/core/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/theme_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';
import 'package:payday/core/services/data_migration_service.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/features/home/providers/home_providers.dart';

// --- EKRAN IMPORTLARI ---
import 'package:payday/features/home/screens/home_screen.dart';
import 'package:payday/features/onboarding/screens/onboarding_screen.dart';
import 'package:payday/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:payday/features/insights/screens/monthly_summary_screen.dart';
import 'package:payday/features/premium/screens/premium_paywall_screen.dart';
import 'package:payday/features/transactions/screens/add_transaction_screen.dart';

// Navigasyon işlemleri için Global Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );

  await RevenueCatService().init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: PaydayApp(),
    ),
  );
}

class PaydayApp extends ConsumerStatefulWidget {
  const PaydayApp({super.key});

  @override
  ConsumerState<PaydayApp> createState() => _PaydayAppState();
}

class _PaydayAppState extends ConsumerState<PaydayApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeAuth());
    _setupNotifications();
  }

  Future<void> _updateTimezone() async {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user != null) {
      try {
        final int offsetHours = DateTime.now().timeZoneOffset.inHours;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'utcOffset': offsetHours,
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("❌ Saat dilimi hatası: $e");
      }
    }
  }

  Future<void> _setupNotifications() async {
    final notificationService = NotificationService();
    await notificationService.initialize(
      navigatorKey: navigatorKey,
      onTokenRefresh: (token) async {
        final user = ref.read(currentUserProvider).asData?.value;
        if (user != null) {
          try {
            final int offsetHours = DateTime.now().timeZoneOffset.inHours;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'fcmToken': token,
              'utcOffset': offsetHours,
              'lastLoginAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            debugPrint("❌ Token ve Offset kaydetme hatası: $e");
          }
        }
      },
    );
  }

  Future<void> _initializeAuth() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        final authService = ref.read(authServiceProvider);
        await authService.signInAnonymously();
      }
      if (mounted) {
        await _updateTimezone();
      }
    } catch (e, stack) {
      debugPrint('Error signing in: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Auth Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Payday',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscriptions': (context) => const SubscriptionsScreen(),
        '/monthly-summary': (context) => const MonthlySummaryScreen(),
        '/premium': (context) => const PremiumPaywallScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
      },
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _controller.forward();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // 1. BEKLEMELER
    // Splash, Firebase'den cevap gelene kadar bekler (Race Condition çözümü)
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)),
      ref.read(currentUserProvider.future),
      FirebaseMessaging.instance.getInitialMessage(), // ✅ Bildirim kontrolü
    ]);

    // Bildirimi al
    final RemoteMessage? initialMessage = results[2] as RemoteMessage?;

    if (!mounted) return;

    // 2. Premium Kontrolü
    try { await refreshPremiumStatus(ref); } catch (_) {}

    // 3. Onboarding & Migration Kontrolü
    final repository = ref.read(userSettingsRepositoryProvider);
    bool hasCompletedOnboarding = false;

    try {
      hasCompletedOnboarding = await repository.hasCompletedOnboarding();

      if (!hasCompletedOnboarding) {
        final user = ref.read(currentUserProvider).asData?.value;
        if (user != null && !user.isAnonymous) {
          final localRepo = LocalUserSettingsRepository();
          final localSettings = await localRepo.getUserSettings('check_local');
          final localHasData = localSettings != null && await localRepo.hasCompletedOnboarding();

          if (localHasData && localSettings != null) {
            try {
              final migrationService = ref.read(dataMigrationServiceProvider);
              await migrationService.migrateLocalToFirebase(user.uid, localSettings.userId);
              ref.invalidate(userSettingsProvider);
              hasCompletedOnboarding = await repository.hasCompletedOnboarding();
              if (!hasCompletedOnboarding) hasCompletedOnboarding = true;
            } catch (e) {
              hasCompletedOnboarding = localHasData;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Splash error: $e");
    }

    if (!mounted) return;

    // 4. YÖNLENDİRME (BURASI DEĞİŞTİ)
    if (hasCompletedOnboarding) {
      // ✅ ADIM 1: Geçmişi sil ve Home'u TEK KÖK (Root) yap.
      // (removeUntil false diyerek önceki tüm sayfaları siliyoruz)
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);

      // ✅ ADIM 2: Eğer bildirim varsa Home'un üzerine aç.
      if (initialMessage != null && initialMessage.data.containsKey('route')) {
        final String route = initialMessage.data['route'];
        debugPrint("🔔 Splash: Bildirim rotası tespit edildi: $route");

        // Çift açılmayı önlemek için frame callback içine alıyoruz.
        // Bu, Home sayfası çizildikten SONRA çalışmasını garanti eder.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamed(route);
        });
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}