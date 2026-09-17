import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00C9A7);
  static const Color primaryDark = Color(0xFF00B4A0);
  static const Color primaryLight = Color(0xFF36D1C4);
  static const Color tealHeader = Color(0xFF1EC8B8);
  static const Color tealHeaderEnd = Color(0xFF00BFA5);

  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFB0B0B0);

  static const Color inputFill = Color(0xFFF0F2F8);
  static const Color background = Color(0xFFFFFFFF);
  static const Color softBlue = Color(0xFFE8F4FC);
  static const Color softBlueCard = Color(0xFFD6EEF8);
  static const Color softPeach = Color(0xFFFFE8E0);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color softPurple = Color(0xFFEDE7F6);

  static const Color stepTeal = Color(0xFF00B4A0);
  static const Color stepOrange = Color(0xFFFF8A65);

  static const Color splashBgTop = Color(0xFFE8F7FA);
  static const Color splashBgBottom = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4B8), Color(0xFF00C9A7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1ED4C4), Color(0xFF00C9A7), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
