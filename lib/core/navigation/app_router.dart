import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/features/auth/screens/forgot_password_screen.dart';
import 'package:classmyte/features/auth/screens/login_screen.dart';
import 'package:classmyte/features/auth/screens/signup_screen.dart';
import 'package:classmyte/features/home/screens/home_screen.dart';
import 'package:classmyte/features/premium/screens/subscription_screen.dart';
import 'package:classmyte/features/data_sync/screens/import_screen.dart';
import 'package:classmyte/features/data_sync/screens/export_screen.dart';
import 'package:classmyte/features/students/screens/students_screen.dart';
import 'package:classmyte/features/students/screens/student_details_screen.dart';
import 'package:classmyte/features/classes/screens/classes_screen.dart';
import 'package:classmyte/features/sms/screens/sms_screen.dart';
import 'package:classmyte/features/sms/screens/manage_templates_screen.dart';
import 'package:classmyte/features/sms/screens/personalize_message_screen.dart';
import 'package:classmyte/features/sms/screens/message_report_screen.dart';
import 'package:classmyte/features/settings/screens/settings_screen.dart';
import 'package:classmyte/features/settings/screens/contact_us_screen.dart';
import 'package:classmyte/features/settings/screens/about_screen.dart';
import 'package:classmyte/features/settings/screens/privacy_policy_screen.dart';
import 'package:classmyte/features/settings/screens/change_password_screen.dart';
import 'package:classmyte/features/settings/screens/profile_screen.dart';
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
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: '/students',
        name: 'students',
        builder: (context, state) => const StudentContactsScreen(),
        routes: [
          GoRoute(
            path: 'details',
            name: 'student-details',
            builder: (context, state) {
              final student = state.extra as Student;
              return StudentDetailsScreen(student: student);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/classes',
        name: 'classes',
        builder: (context, state) => const ClassScreen(),
      ),
      GoRoute(
        path: '/sms',
        name: 'sms',
        builder: (context, state) => const NewMessageScreen(),
      ),
      GoRoute(
        path: '/manage-templates',
        name: 'manage-templates',
        builder: (context, state) => const ManageTemplatesScreen(),
      ),
      GoRoute(
        path: '/personalize-message',
        name: 'personalize-message',
        builder: (context, state) => const PersonalizeMessageScreen(),
      ),
      GoRoute(
        path: '/message-report',
        name: 'message-report',
        builder: (context, state) => const MessageReportScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'contact-us',
            name: 'contact-us',
            builder: (context, state) => const ContactUsScreen(),
          ),
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'change-password',
            name: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup' || state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';

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
        if (user != null) return const HomePage();
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
