import 'package:classmyte/core/theme/app_colors.dart';
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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Settings'),
          Expanded(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSettingsGroup('Account', [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile Settings',
                      onTap: () {}, // Profile logic
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => context.push('/settings/change-password'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsGroup('Application', [
                    _buildSettingsTile(
                      icon: Icons.subscriptions_outlined,
                      title: 'My Subscription',
                      onTap: () => context.push('/subscription'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About ClassMyte',
                      onTap: () => context.push('/settings/about'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => context.push('/settings/privacy'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsGroup('Support', [
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.push('/settings/contact-us'),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.redAccent,
                    onTap: () {
                      CustomDialog.show(
                        context: context,
                        title: 'Confirm Logout',
                        subtitle: 'Are you sure you want to sign out?',
                        confirmText: 'Yes',
                        cancelText: 'No',
                        confirmColor: Colors.redAccent,
                        onConfirm: () async {
                          // Explicit sign out
                          await FirebaseAuth.instance.signOut();

                          // Explicitly reset provider state — ensures next login is fresh
                          ref.invalidate(subscriptionProvider);
                          ref.invalidate(studentDataProvider);
                          ref.read(loginLoadingProvider.notifier).state = false;

                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      );
                    },
                  ),
                  _buildSettingsTile(
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

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    CustomDialog.show(
      context: context,
      title: 'Delete Account',
      subtitle:
          'This action is permanent and will delete all your data. Please enter your password to confirm.',
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
          // Re-authenticate user before deletion
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: passwordController.text.trim(),
          );

          await user.reauthenticateWithCredential(credential);

          Navigator.pop(context); // Close dialog

          // Delete from Firebase
          await user.delete();

          // Cleanup state
          ref.invalidate(subscriptionProvider);
          ref.invalidate(studentDataProvider);

          if (context.mounted) {
            context.go('/login');
            CustomSnackBar.showSuccess(
                context, 'Account deleted successfully.');
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close dialog on failure
            String msg = 'Failed to delete account';
            if (e.code == 'wrong-password') msg = 'Incorrect password.';
            CustomSnackBar.showError(context, msg);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close dialog on failure
            CustomSnackBar.showError(context, 'An unexpected error occurred.');
          }
        }
      },
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
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
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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

  Widget _buildSettingsTile({
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
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing:
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
