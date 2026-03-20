import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/theme/theme_provider.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/features/auth/providers/auth_providers.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email provided';
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomHeader(title: 'Profile'),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.dynamicBackgroundGradient(isDark),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // User info section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSettingsGroup(context, 'Account Security', [
                    _buildSettingsTile(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => context.push('/settings/change-password'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(context, 'Subscription', [
                    _buildSettingsTile(
                      context,
                      icon: Icons.subscriptions_outlined,
                      title: 'My Subscription',
                      onTap: () => context.push('/subscription'),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSettingsTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.redAccent,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    color: Colors.redAccent,
                    onTap: () => _showDeleteAccountDialog(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    CustomDialog.show(
      context: context,
      title: 'Confirm Logout',
      subtitle: 'Are you sure you want to sign out?',
      confirmText: 'Yes',
      cancelText: 'No',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await FirebaseAuth.instance.signOut();
        ref.invalidate(subscriptionProvider);
        ref.invalidate(studentDataProvider);
        ref.read(loginLoadingProvider.notifier).state = false;

        if (context.mounted) {
          context.go('/login');
        }
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    CustomDialog.show(
      context: context,
      title: 'Delete Account',
      subtitle: 'This action is permanent and will delete all your data. Please enter your password to confirm.',
      confirmText: 'Delete',
      confirmColor: Colors.redAccent,
      controller: passwordController,
      inputLabel: 'Confirm Password',
      inputHint: 'Enter your password',
      isPassword: true,
      onConfirm: () async {
        if (passwordController.text.isEmpty) {
          CustomSnackBar.showError(context, 'Password is required');
          return;
        }

        try {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: passwordController.text.trim(),
          );
          await user.reauthenticateWithCredential(credential);
          Navigator.pop(context); // Close dialog
          await user.delete();
          ref.invalidate(subscriptionProvider);
          ref.invalidate(studentDataProvider);
          if (context.mounted) {
            context.go('/login');
            CustomSnackBar.showSuccess(context, 'Account deleted successfully.');
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            String msg = 'Failed to delete account';
            if (e.code == 'wrong-password') msg = 'Incorrect password.';
            CustomSnackBar.showError(context, msg);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            CustomSnackBar.showError(context, 'An unexpected error occurred.');
          }
        }
      },
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
      onTap: onTap,
    );
  }
}
