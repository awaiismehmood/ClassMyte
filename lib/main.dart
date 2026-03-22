// ignore_for_file: avoid_print
import 'package:classmyte/core/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/core/navigation/app_router.dart';
import 'package:classmyte/core/theme/app_theme.dart';
import 'package:classmyte/core/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  try {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print("Error initializing app: $e");
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize app logic after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppLogic();
    });
  }

  Future<void> _initAppLogic() async {
    await ref.read(subscriptionProvider.notifier).checkSubscriptionStatus();
    final isPremium = ref.read(subscriptionProvider).isPremiumUser;

    if (!isPremium) {
      final adManager = ref.read(adManagerProvider);
      adManager.loadAppOpenAd();
      adManager.loadRewardedAd();
      adManager.loadBannerAd(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
          .read(subscriptionProvider.notifier)
          .checkSubscriptionStatus()
          .then((_) {
        final isPremium = ref.read(subscriptionProvider).isPremiumUser;
        if (!isPremium) {
          ref.read(adManagerProvider).showAppOpenAd();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ClassMyte',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: goRouter,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
    );
  }
}
