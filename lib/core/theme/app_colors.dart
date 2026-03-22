import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Gradient Colors
  static const Color primaryStart = Color(0xFFB71C1C);
  static const Color primaryEnd = Color(0xFFFFD700);

  // Secondary Gradient Colors
  static const Color secondaryStart = Color(0xFFFF6B6B);
  static const Color secondaryEnd = Color(0xFFC62828);

  // Accent Gradient Colors
  static const Color accentStart = Color(0xFFFFE082);
  static const Color accentEnd = Color(0xFFFFFFFF);

  // Primary color (for compatibility)
  static const Color primary = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFFFCDD2);
  static const Color primaryDark = Color(0xFF8E0000);

  // Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryStart, secondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme colors
  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFFFF3E0);
  static const Color lightText = Color(0xFF2C2C2C);
  static const Color lightTextSecondary = Color(0xFF8D6E63);
  static const Color lightDivider = Color(0xFFFFE0B2);
  static const Color lightCardBg = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkText = Color(0xFFFFF8E1);
  static const Color darkTextSecondary = Color(0xFFFFD54F);
  static const Color darkDivider = Color(0xFF3E2723);
  static const Color darkCardBg = Color(0xFF1F1F1F);

  // Glassmorphism colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A1E1E1E);
  static const Color glassBorderLight = Color(0x33FFD700);
  static const Color glassBorderDark = Color(0x33C62828);

  // Status colors
  static const Color success = Color(0xFFD4AF37);
  static const Color successLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFFB71C1C);
  static const Color infoLight = Color(0xFFFFCDD2);

  // Avatar colors
  static const List<Color> avatarColors = [
    Color(0xFFC62828),
    Color(0xFFB71C1C),
    Color(0xFFFFD700),
    Color(0xFFFFA000),
    Color(0xFF8E0000),
    Color(0xFFFF6F00),
    Color(0xFFFFC107),
    Color(0xFFD32F2F),
  ];

  // Card gradient border colors
  static const List<Color> cardGradientColors = [
    Color(0xFFC62828),
    Color(0xFFFFD700),
    Color(0xFFB71C1C),
    Color(0xFFFFA000),
  ];

  // Shimmer colors
  static const Color shimmerLight = Color(0xFFFFF3E0);
  static const Color shimmerDark = Color(0xFF2C2C2C);

  // Shadow colors
  static Color primaryShadow = const Color(0xFFC62828).withValues(alpha: 0.3);
  static Color cardShadow = Colors.black.withValues(alpha: 0.12);
}