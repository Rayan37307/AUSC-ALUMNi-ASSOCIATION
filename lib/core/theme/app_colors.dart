import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color
  static const Color primary = Color(0xFF0a7ea4);
  static const Color primaryLight = Color(0xFF1a9ec4);
  static const Color primaryDark = Color(0xFF086884);

  // Light theme colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF151718);
  static const Color darkSurface = Color(0xFF1E2021);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF2D2D2D);

  // Avatar colors
  static const List<Color> avatarColors = [
    Color(0xFF0a7ea4),
    Color(0xFF1a9ec4),
    Color(0xFF086884),
    Color(0xFF2D9F8F),
    Color(0xFF3D8BC4),
    Color(0xFF5B7FB8),
    Color(0xFF7B68A8),
    Color(0xFF9B5B98),
  ];

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}
