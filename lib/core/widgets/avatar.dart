import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A circular avatar widget that displays the first letter of a name
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const Avatar({
    super.key,
    required this.name,
    this.size = 48,
    this.backgroundColor,
    this.textStyle,
  });

  String get _firstLetter {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  Color get _avatarColor {
    if (backgroundColor != null) return backgroundColor!;
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return AppColors.avatarColors[0];
    final index = trimmed.codeUnitAt(0) % AppColors.avatarColors.length;
    return AppColors.avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _firstLetter,
          style: textStyle ??
              TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
