import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF0056B3); // Professional Blue
  static const Color primaryLight = Color(0xFF4B9FE1);
  static const Color primaryDark = Color(0xFF003D80);
  
  // Secondary / Accent
  static const Color accent = Color(0xFF3282B8);
  static const Color secondary = Color(0xFFBBE1FA);
  
  // Backgrounds
  static const Color background = Color(0xFFF4F7FD);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1B262C);
  static const Color textSecondary = Color(0xFF536162);
  static const Color textLight = Color(0xFF90A4AE);
  
  // Functional Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
