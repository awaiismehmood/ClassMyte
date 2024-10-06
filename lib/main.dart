// ignore_for_file: avoid_print
import 'package:classmyte/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'homepage/home_screen.dart';
import 'authentication/login.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await _requestNotificationPermission(); // Request notification permission
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing app: $e");
  }
  MobileAds.instance.initialize();
}

Future<void> _requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();

  if (status.isGranted) {
    _initializeNotifications();
  } else if (status.isDenied) {
    print("Notification permission denied");
  }
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
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
      return const CircularProgressIndicator(); // Show a loader while checking preferences
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
}
