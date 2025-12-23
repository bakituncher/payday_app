import 'package:cloud_firestore/cloud_firestore.dart'; // Token ve Offset kaydı için
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:payday/features/home/screens/home_screen.dart';
import 'package:payday/features/onboarding/screens/onboarding_screen.dart';
import 'package:payday/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:payday/features/insights/screens/monthly_summary_screen.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/theme_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';
import 'package:payday/core/services/data_migration_service.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/features/home/providers/home_providers.dart';

// Navigasyon işlemleri için Global Key (RouterContext olmadan yönlendirme için)
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
    // Bildirim sistemini başlat
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final notificationService = NotificationService();

    // Initialize metoduna navigatorKey ve token kaydetme fonksiyonunu veriyoruz
    await notificationService.initialize(
      navigatorKey: navigatorKey,
      onTokenRefresh: (token) async {
        // Burada token'ı ve saat dilimini Firestore'a kaydediyoruz
        final user = ref.read(currentUserProvider).asData?.value;
        if (user != null) {
          try {
            // ✅ YENİ: Saat dilimi farkını (Offset) alıyoruz (Örn: Türkiye için 3, NY için -5)
            final int offsetHours = DateTime.now().timeZoneOffset.inHours;

            // Kullanıcının dokümanına fcmToken ve utcOffset alanını ekle/güncelle
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'fcmToken': token,
              'utcOffset': offsetHours, // 🌍 Saat dilimi eklendi
              'lastLoginAt': FieldValue.serverTimestamp(), // Son görülme zamanı (opsiyonel ama faydalı)
            }, SetOptions(merge: true));

            debugPrint("💾 Token ve UTC Offset ($offsetHours) başarıyla kaydedildi: $token");
          } catch (e) {
            debugPrint("❌ Token ve Offset kaydetme hatası: $e");
          }
        } else {
          debugPrint("⚠️ Kullanıcı oturumu açık değil, token kaydedilemedi (daha sonra tekrar denenebilir).");
        }
      },
    );
  }

  Future<void> _initializeAuth() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        debugPrint('No user signed in. Signing in anonymously...');
        final authService = ref.read(authServiceProvider);
        await authService.signInAnonymously();
      }
    } catch (e, stack) {
      debugPrint('Error signing in anonymously: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Anonymous Auth Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Payday',
      navigatorKey: navigatorKey, // ✅ EKLENDİ: Global key'i buraya bağlıyoruz
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
    // 1. Beklemeler
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)),
      ref.read(currentUserProvider.future),
    ]);

    if (!mounted) return;

    // 2. Premium Kontrolü
    try { await refreshPremiumStatus(ref); } catch (_) {}

    // 3. Onboarding & Migration Kontrolü
    final repository = ref.read(userSettingsRepositoryProvider);
    bool hasCompletedOnboarding = false;

    try {
      hasCompletedOnboarding = await repository.hasCompletedOnboarding();
      debugPrint("Splash: Has Completed Onboarding (Initial Check) -> $hasCompletedOnboarding");

      if (!hasCompletedOnboarding) {
        final user = ref.read(currentUserProvider).asData?.value;

        if (user != null && !user.isAnonymous) {
          debugPrint("Splash: Authenticated user but no Firebase data found via Onboarding check. Checking Local...");

          final localRepo = LocalUserSettingsRepository();
          final localHasData = await localRepo.hasCompletedOnboarding();

          if (localHasData) {
            debugPrint("Splash: ✅ Local data found! Attempting migration...");

            try {
              final migrationService = ref.read(dataMigrationServiceProvider);
              await migrationService.migrateLocalToFirebase(user.uid, 'local_user');
              ref.invalidate(userSettingsProvider);
              debugPrint("Splash: Migration process finished (Success or Aborted safely).");
              hasCompletedOnboarding = true;

            } catch (e) {
              debugPrint("Splash: Migration Failed with error: $e");
              hasCompletedOnboarding = true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Splash: Error checking status: $e");
    }

    if (!mounted) return;

    // 4. Yönlendirme
    if (hasCompletedOnboarding) {
      Navigator.of(context).pushReplacementNamed('/home');
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}