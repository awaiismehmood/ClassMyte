import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About ClassMyte', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/pencil_white.png', height: 100),
              const SizedBox(height: 24),
              Text(
                'ClassMyte is your all-in-one classroom management companion. Designed for teachers to easily track student data, manage classes, and communicate through SMS.',
                style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Version', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          Text('1.0.0', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
