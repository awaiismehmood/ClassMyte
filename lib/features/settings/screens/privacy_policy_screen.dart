import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Privacy Policy'),
              const SizedBox(height: 16),
              _buildBodyText(
                'Your privacy is important to us. It is ClassMyte\'s policy to respect your privacy regarding any information we may collect from you through our app.',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Data Storage'),
              const SizedBox(height: 16),
              _buildBodyText(
                'All your data (student records, classes, etc.) is securely stored in Firebase and your local storage.',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Contact Support'),
              const SizedBox(height: 16),
              _buildBodyText(
                'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at teams.classmyte@gmail.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildBodyText(String text) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary, height: 1.5));
  }
}
