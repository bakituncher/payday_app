import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// 👇 App Check import eklendi
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

// ✅ EKLENDİ: Premium provider'a erişmemiz lazım
import 'package:payday/features/premium/providers/premium_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 👇 App Check Aktivasyonu
  // Firebase.initializeApp'ten hemen sonra, diğer servislerden önce çağırıyoruz.
  await FirebaseAppCheck.instance.activate(
    // Android için: Debug moddaysa debug provider, değilse Play Integrity
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // iOS için: Debug moddaysa debug provider, değilse App Attest
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,  );

  // RevenueCat'i başlat
  await RevenueCatService().init();

  // Debug Logu: Başlangıçta RevenueCat hazır mı?
  debugPrint("RevenueCat Initialized");

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
    await notificationService.initialize();
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyEngagementReminders();
    debugPrint("🔔 Bildirim sistemi hazır ve günlük planlar kuruldu.");
  }

  Future<void> _initializeAuth() async {
    try {
      final authService = ref.read(authServiceProvider);
      if (authService.currentUser == null) {
        debugPrint('No user signed in. Signing in anonymously...');
        await authService.signInAnonymously();
        debugPrint('Signed in anonymously.');
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

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after delay
    _checkStatusAndNavigate();
  }

  // ✅ BU FONKSİYON GÜNCELLENDİ: ARTIK AUTH PROVIDER'I BEKLİYOR
  Future<void> _checkStatusAndNavigate() async {
    // 1. Animasyon süresi VE Auth durumunun yüklenmesini paralel bekle
    // Bu sayede eğer auth işlemi 2 saniyeden uzun sürerse onu da beklemiş oluruz.
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)), // Min bekleme süresi
      ref.read(currentUserProvider.future), // Auth state'in ilk değerini almasını bekle
    ]);

    if (!mounted) return;

    // 2. Premium durumunu kontrol et
    debugPrint("Splash: Checking Premium Status...");
    try {
      await refreshPremiumStatus(ref);
      final isPremium = ref.read(isPremiumProvider);
      debugPrint("Splash: Premium Status Checked -> $isPremium");
    } catch (e) {
      debugPrint("Splash: Premium Check Failed -> $e");
    }

    // 3. Onboarding durumunu kontrol et
    // Auth artık yüklendiği için doğru repository (Firebase/Local) seçilecektir.
    final repository = ref.read(userSettingsRepositoryProvider);
    final hasCompletedOnboarding = await repository.hasCompletedOnboarding();

    debugPrint("Splash: Has Completed Onboarding -> $hasCompletedOnboarding");

    if (!mounted) return;

    // 4. Yönlendirme yap
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
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPink.withValues(alpha: isDark ? 0.08 : 0.15),
                    AppColors.primaryPink.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryPurple.withValues(alpha: isDark ? 0.06 : 0.12),
                    AppColors.secondaryPurple.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: AppColors.premiumGradient,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withValues(alpha: 0.5),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                                  blurRadius: 60,
                                  spreadRadius: -10,
                                  offset: const Offset(0, 25),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // App Name with slide animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Payday',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(context),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tagline
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Your Money Countdown Starts Now',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPink,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}