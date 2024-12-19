// ignore_for_file: avoid_print
import 'package:classmyte/ads/ads.dart';
import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homepage/home_screen.dart';
import 'authentication/login.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize(); // Initialize Google Mobile Ads SDK

  try {
    await Firebase.initializeApp();

    runApp(const MyApp());
  } catch (e) {
    print("Error initializing app: $e");
  }
  MobileAds.instance.initialize();
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
   final AdManager _adManager = AdManager(); // Create an instance of AdManager
    final SubscriptionData subscriptionData = SubscriptionData();

  @override
void initState() {
  super.initState();
  _checkOnboardingStatus();
  WidgetsBinding.instance.addObserver(this);

  // Wait for the subscription status to be checked before loading the ad
  _checkSubscriptionAndLoadAd();
}

Future<void> _checkSubscriptionAndLoadAd() async {
  await subscriptionData.checkSubscriptionStatus();
  if (!subscriptionData.isPremiumUser.value) {
    _adManager.loadAppOpenAd(); // Load ads only if not premium
    _adManager.loadRewardedAd();
    _adManager.loadBannerAd((){});
  }
}


 @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Check the subscription status before showing the ad
    subscriptionData.checkSubscriptionStatus().then((_) {
      if (!subscriptionData.isPremiumUser.value) {
        _adManager.showAppOpenAd(); // Show ads only if not premium
      }
    });
  }
}


  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSeenOnboarding = prefs.getBool('hasSeenOnboarding');
    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding ?? false;
      _isLoading = false;
    });
  }

  Future<void> _setOnboardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _hasSeenOnboarding
          ? _buildAuthStream()
          : OnboardingScreen(onFinish: _onFinishOnboarding),
    );
  }

  void _onFinishOnboarding() {
    _setOnboardingComplete();
    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  Widget _buildAuthStream() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adManager.dispose();
    super.dispose();
  }
}
