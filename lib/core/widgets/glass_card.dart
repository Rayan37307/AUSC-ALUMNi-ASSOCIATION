import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final double blur;
  final double opacity;
  final List<Color>? gradientColors;
  final bool hasGradientBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.showBorder = true,
    this.blur = 10,
    this.opacity = 0.1,
    this.gradientColors,
    this.hasGradientBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: hasGradientBorder
          ? _buildGradientBorderCard(context, isDark)
          : _buildGlassCard(context, isDark),
    );
  }

  Widget _buildGlassCard(BuildContext context, bool isDark) {
    final backgroundColor = isDark ? AppColors.glassDark : AppColors.glassLight;
    final borderColor = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: opacity + 0.1),
                borderRadius: BorderRadius.circular(borderRadius),
                border: showBorder
                    ? Border.all(color: borderColor, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBorderCard(BuildContext context, bool isDark) {
    final colors = gradientColors ?? AppColors.cardGradientColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius - 1),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius - 1),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final double borderWidth;
  final List<Color>? borderColors;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.borderWidth = 2,
    this.borderColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = borderColors ?? AppColors.cardGradientColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
