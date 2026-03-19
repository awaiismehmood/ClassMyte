import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/auth/forgetPassword.dart';
import 'package:classmyte/features/auth/login.dart';
import 'package:classmyte/features/auth/signup.dart';
import 'package:classmyte/features/home/home_screen.dart';
import 'package:classmyte/features/premium/subscription_screen.dart';
import 'package:classmyte/features/data_sync/screen_dn.dart';
import 'package:classmyte/features/students/students.dart';
import 'package:classmyte/features/students/student_details.dart';
import 'package:classmyte/features/classes/classes.dart';
import 'package:classmyte/features/sms/sms.dart';
import 'package:classmyte/features/settings/settings.dart';
import 'package:classmyte/features/settings/contact_us.dart';
import 'package:classmyte/features/settings/about.dart';
import 'package:classmyte/features/settings/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/data-management',
        builder: (context, state) => const UploadDownloadScreen(),
      ),
      GoRoute(
        path: '/students',
        builder: (context, state) => const StudentContactsScreen(),
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) {
              final student = state.extra as Map<String, String>;
              return StudentDetailsScreen(student: student);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/classes',
        builder: (context, state) => const ClassScreen(),
      ),
      GoRoute(
        path: '/sms',
        builder: (context, state) => const NewMessageScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
           GoRoute(
            path: 'contact-us',
            builder: (context, state) => const ContactUsScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup' || 
                         state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
