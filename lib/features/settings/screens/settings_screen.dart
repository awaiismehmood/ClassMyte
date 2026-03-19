import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Settings'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                      FirebaseAuth.instance.signOut();
                      context.go('/login');
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    color: Colors.redAccent,
                    onTap: () {
                      // Delete account logic
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
