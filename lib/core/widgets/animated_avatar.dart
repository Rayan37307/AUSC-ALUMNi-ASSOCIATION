import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class AnimatedAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double? ringWidth;
  final List<Color>? ringColors;
  final bool showRing;
  final VoidCallback? onTap;

  const AnimatedAvatar({
    super.key,
    required this.name,
    this.size = 80,
    this.ringWidth,
    this.ringColors,
    this.showRing = true,
    this.onTap,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Color get _avatarColor {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return AppColors.avatarColors[0];
    final index = trimmed.codeUnitAt(0) % AppColors.avatarColors.length;
    return AppColors.avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final ring = ringWidth ?? size * 0.06;
    final colors = ringColors ?? AppColors.cardGradientColors;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_avatarColor, _avatarColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _avatarColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );

    if (showRing) {
      avatar = Container(
        width: size + ring * 2 + 4,
        height: size + ring * 2 + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(ring),
        child: avatar,
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class GradientRingAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double ringThickness;
  final List<Color>? gradientColors;

  const GradientRingAvatar({
    super.key,
    required this.name,
    this.size = 80,
    this.ringThickness = 4,
    this.gradientColors,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Color get _avatarColor {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return AppColors.avatarColors[0];
    final index = trimmed.codeUnitAt(0) % AppColors.avatarColors.length;
    return AppColors.avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.cardGradientColors;

    return Container(
      width: size + ringThickness * 2,
      height: size + ringThickness * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [...colors, colors.first],
          startAngle: 0,
          endAngle: 6.28,
        ),
      ),
      padding: EdgeInsets.all(ringThickness / 2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardBg
              : AppColors.lightCardBg,
        ),
        child: Container(
          margin: EdgeInsets.all(ringThickness / 2 + 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_avatarColor, _avatarColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PulsingAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool isOnline;

  const PulsingAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedAvatar(name: name, size: size, showRing: false),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child:
                Container(
                      width: size * 0.25,
                      height: size * 0.25,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkCardBg
                              : AppColors.lightCardBg,
                          width: 2,
                        ),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 1000.ms,
                    )
                    .fadeOut(begin: 1, duration: 1000.ms),
          ),
      ],
    );
  }
}
