import 'package:flutter/material.dart';

/// A text widget that automatically adapts to the current theme
class ThemedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const ThemedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style?.copyWith(
        color: color ?? (isDark ? Colors.white : const Color(0xFF1A1A1A)),
        fontWeight: fontWeight,
        fontSize: fontSize,
      ) ??
          theme.textTheme.bodyMedium?.copyWith(
            color: color ?? (isDark ? Colors.white : const Color(0xFF1A1A1A)),
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
    );
  }
}

/// A title text widget with larger font size
class ThemedTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;

  const ThemedTitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );
  }
}

/// A subtitle text widget with secondary color
class ThemedSubtitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;

  const ThemedSubtitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ThemedText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF666666),
      fontSize: 14,
    );
  }
}
