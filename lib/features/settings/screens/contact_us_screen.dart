import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  void _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/923185444845");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Contact Us'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We\'d love to hear from you!',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'For any inquiries, feedback, or support, feel free to contact us using the options below:',
                      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    _buildContactCard(
                      icon: Icons.chat_bubble_outline,
                      iconColor: Colors.green,
                      title: 'Chat on WhatsApp',
                      subtitle: '+92 318 5444845',
                      onTap: _launchWhatsApp,
                    ),
                    const SizedBox(height: 16),
                    _buildContactCard(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Email Us',
                      subtitle: 'teams.classmyte@gmail.com',
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'teams.classmyte@gmail.com',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textLight, size: 16),
          ],
        ),
      ),
    );
  }
}


