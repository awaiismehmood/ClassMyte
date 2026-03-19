import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Privacy Policy'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Privacy Policy', Icons.privacy_tip_outlined),
                      const SizedBox(height: 16),
                      _buildBodyText(
                        'Your privacy is important to us. It is ClassMyte\'s policy to respect your privacy regarding any information we may collect from you through our app.',
                      ),
                      const Divider(height: 48),
                      _buildSectionTitle('Data Storage', Icons.storage_outlined),
                      const SizedBox(height: 16),
                      _buildBodyText(
                        'All your data (student records, classes, etc.) is securely stored in Firebase and your local storage.',
                      ),
                      const Divider(height: 48),
                      _buildSectionTitle('Contact Support', Icons.support_agent_outlined),
                      const SizedBox(height: 16),
                      _buildBodyText(
                        'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at teams.classmyte@gmail.com.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildBodyText(String text) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary, height: 1.6));
  }
}

