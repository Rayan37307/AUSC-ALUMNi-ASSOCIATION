import 'package:flutter/material.dart';

/// A container widget that adapts to the current theme
class ThemedView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxDecoration? decoration;
  final double? borderRadius;
  final bool expand;

  const ThemedView({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.borderRadius,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultDecoration = decoration ??
        BoxDecoration(
          color: color ??
              (isDark
                  ? const Color(0xFF1E2021)
                  : const Color(0xFFF5F5F5)),
          borderRadius: borderRadius != null
              ? BorderRadius.circular(borderRadius!)
              : null,
        );

    return Container(
      padding: padding,
      margin: margin,
      decoration: expand ? null : defaultDecoration,
      child: child,
    );
  }
}

/// A card widget with theme-aware styling
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
