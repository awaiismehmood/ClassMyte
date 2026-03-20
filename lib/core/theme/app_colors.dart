import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Standard)
  static const Color primary = Color(0xFF2563EB); // Premium Royal Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E3A8A);
  
  // Secondary / Accent
  static const Color accent = Color(0xFFF59E0B);
  static const Color secondary = Color(0xFFDBEAFE);
  
  // Light Mode Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1B262C);
  static const Color textSecondary = Color(0xFF536162);
  static const Color textLight = Color(0xFF90A4AE);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A); // Deep slate
  static const Color surfaceDark = Color(0xFF1E293B); // Lighter slate
  static const Color cardBgDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textLightDark = Color(0xFF64748B);

  // Functional Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient dynamicBackgroundGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
        ? [backgroundDark, surfaceDark] 
        : [background, surface],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
