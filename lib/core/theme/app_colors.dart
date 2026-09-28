import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — warm ember orange
  static const Color primaryStart = Color(0xFFFF7A45);
  static const Color primaryEnd = Color(0xFFE2401C);

  // Secondary gradient (softer coral)
  static const Color secondaryStart = Color(0xFFFFA27A);
  static const Color secondaryEnd = Color(0xFFF2542D);

  // Accent gradient (peach wash)
  static const Color accentStart = Color(0xFFFFE1D2);
  static const Color accentEnd = Color(0xFFFFFFFF);

  // Primary color (for compatibility)
  static const Color primary = Color(0xFFF2542D);
  static const Color primaryLight = Color(0xFFFFE1D2);
  static const Color primaryDark = Color(0xFFC23A17);

  // Ink — dark pill buttons and selected nav items
  static const Color ink = Color(0xFF2B2B2B);
  static const Color inkLight = Color(0xFF4A4A4A);

  // Tag chips
  static const Color tagBg = Color(0xFFFFE1D2);
  static const Color tagText = Color(0xFFD2461F);
  static const Color tagBgDark = Color(0xFF3A2219);
  static const Color tagTextDark = Color(0xFFFF9A72);

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

  // Ink gradient for pill buttons
  static const LinearGradient inkGradient = LinearGradient(
    colors: [inkLight, ink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light theme colors
  static const Color lightBackground = Color(0xFFF1F1F1);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF6F6F6);
  static const Color lightText = Color(0xFF1E1E1E);
  static const Color lightTextSecondary = Color(0xFF8A8A8A);
  static const Color lightDivider = Color(0xFFE8E8E8);
  static const Color lightCardBg = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color darkSurfaceVariant = Color(0xFF262626);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkDivider = Color(0xFF2E2E2E);
  static const Color darkCardBg = Color(0xFF1C1C1C);

  // Glassmorphism colors
  static const Color glassLight = Color(0xB3FFFFFF);
  static const Color glassDark = Color(0x991C1C1C);
  static const Color glassBorderLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);

  // Status colors
  static const Color success = Color(0xFF2E9E6A);
  static const Color successLight = Color(0xFFE3F5EC);
  static const Color error = Color(0xFFD93A2B);
  static const Color errorLight = Color(0xFFFDE8E6);
  static const Color warning = Color(0xFFF2A12D);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFFF2542D);
  static const Color infoLight = Color(0xFFFFE1D2);

  // Avatar colors
  static const List<Color> avatarColors = [
    Color(0xFFF2542D),
    Color(0xFFE2401C),
    Color(0xFFFF7A45),
    Color(0xFFC23A17),
    Color(0xFFFF9466),
    Color(0xFF4A4A4A),
    Color(0xFFD9602F),
    Color(0xFF2B2B2B),
  ];

  // Card gradient border colors
  static const List<Color> cardGradientColors = [
    Color(0xFFFF7A45),
    Color(0xFFF2542D),
    Color(0xFFE2401C),
    Color(0xFFFFA27A),
  ];

  // Shimmer colors
  static const Color shimmerLight = Color(0xFFEDEDED);
  static const Color shimmerDark = Color(0xFF262626);

  // Shadow colors
  static Color primaryShadow = const Color(0xFFF2542D).withValues(alpha: 0.3);
  static Color cardShadow = Colors.black.withValues(alpha: 0.06);
}
