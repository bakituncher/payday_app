import 'package:cloud_firestore/cloud_firestore.dart';
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
// Bildirimlerden gelen rotalar için gerekli importlar:
import 'package:payday/features/premium/screens/premium_paywall_screen.dart';
import 'package:payday/features/transactions/screens/add_transaction_screen.dart';

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

  /// ✅ YENİ EKLENEN FONKSİYON
  /// Uygulama her açıldığında kullanıcının güncel saat dilimini kaydeder.
  /// Cloud Function bu offset değerine göre bildirim gönderir.
  Future<void> _updateTimezone() async {
    // Auth provider'dan mevcut kullanıcıyı al (Async değil, cache'den okur)
    final user = ref.read(currentUserProvider).asData?.value;

    if (user != null) {
      try {
        final int offsetHours = DateTime.now().timeZoneOffset.inHours;

        // Firestore'a saat dilimini ve son görülmeyi yaz
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'utcOffset': offsetHours,
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint("🌍 Başlangıç Kontrolü: Saat dilimi güncellendi (UTC $offsetHours)");
      } catch (e) {
        debugPrint("❌ Başlangıç Kontrolü: Saat dilimi hatası: $e");
      }
    }
  }

  Future<void> _setupNotifications() async {
    final notificationService = NotificationService();

    // Initialize metoduna navigatorKey ve token kaydetme fonksiyonunu veriyoruz
    await notificationService.initialize(
      navigatorKey: navigatorKey,
      onTokenRefresh: (token) async {
        // Burada token'ı ve saat dilimini Firestore'a kaydediyoruz (Token değişirse çalışır)
        final user = ref.read(currentUserProvider).asData?.value;
        if (user != null) {
          try {
            // ✅ Saat dilimi farkını (Offset) alıyoruz
            final int offsetHours = DateTime.now().timeZoneOffset.inHours;

            // Kullanıcının dokümanına fcmToken ve utcOffset alanını ekle/güncelle
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'fcmToken': token,
              'utcOffset': offsetHours, // 🌍 Saat dilimi eklendi
              'lastLoginAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            debugPrint("💾 Token Refresh: Token ve UTC Offset ($offsetHours) başarıyla kaydedildi: $token");
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
      final revenueCatService = RevenueCatService(); // Servisi al

      if (user == null) {
        debugPrint('No user signed in. Signing in anonymously...');
        final authService = ref.read(authServiceProvider);
        await authService.signInAnonymously();
        // Anonim giriş AuthService içinde handle edildiği için burada tekrar çağırmaya gerek yok
      } else {
        // ✅ KRİTİK: Kullanıcı zaten giriş yapmışsa RevenueCat'i senkronize et.
        // Bu, uygulamanın her açılışında kimliğin doğrulanmasını sağlar.
        debugPrint('User signed in: ${user.uid}. Syncing with RevenueCat...');
        await revenueCatService.logIn(user.uid);
      }

      // ✅ KRİTİK EKLEME: Kullanıcı oturumu doğrulandıktan sonra
      // uygulama her açıldığında timezone'u güncelle.
      if (mounted) {
        await _updateTimezone();
      }

    } catch (e, stack) {
      debugPrint('Error initializing auth: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Auth Init Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Payday',
      navigatorKey: navigatorKey, // ✅ Global key
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      initialRoute: '/',
      // 🚀 BİLDİRİM ROTALARI GÜNCELLENDİ
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscriptions': (context) => const SubscriptionsScreen(),
        '/monthly-summary': (context) => const MonthlySummaryScreen(),
        '/premium': (context) => const PremiumPaywallScreen(), // Pazarlama bildirimi için
        '/add-transaction': (context) => const AddTransactionScreen(), // Harcama girişi bildirimi için
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
          final localSettings = await localRepo.getUserSettings('check_local');
          final localHasData = localSettings != null && await localRepo.hasCompletedOnboarding();

          if (localHasData && localSettings != null) {
            debugPrint("Splash: ✅ Local data found! Attempting migration...");

            try {
              final migrationService = ref.read(dataMigrationServiceProvider);
              await migrationService.migrateLocalToFirebase(user.uid, localSettings.userId);
              ref.invalidate(userSettingsProvider);
              debugPrint("Splash: Migration process finished (Success or Aborted safely). Rechecking onboarding...");
              hasCompletedOnboarding = await repository.hasCompletedOnboarding();

              // Eğer hala görünmüyorsa, en azından local veri var diye true'ya çekelim
              if (!hasCompletedOnboarding) {
                hasCompletedOnboarding = true;
              }
            } catch (e) {
              debugPrint("Splash: Migration Failed with error: $e");
              hasCompletedOnboarding = localHasData;
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

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _pulseController]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Animasyonu (Pulse efekti ile)
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/icon.png', // Logo varlığı varsayıldı
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Uygulama İsmi
                      Text(
                        'Payday',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}