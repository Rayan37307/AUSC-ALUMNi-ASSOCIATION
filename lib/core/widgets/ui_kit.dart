import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Rounded white surface with a soft, diffuse shadow.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.radius = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Dark, glossy pill button (the primary call to action).
class InkPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;
  final bool loading;

  const InkPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const SizedBox(
            height: 20,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.inkGradient,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onPressed == null || loading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Soft grey circular icon button.
class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  const CircleActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final button = Material(
      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEDEDED),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.42,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Small peach tag, e.g. "Batch 2004".
class TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool onDark;

  const TagChip({super.key, required this.label, this.icon, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = onDark
        ? Colors.white.withValues(alpha: 0.9)
        : (isDark ? AppColors.tagBgDark : AppColors.tagBg);
    final fg = onDark
        ? AppColors.lightText
        : (isDark ? AppColors.tagTextDark : AppColors.tagText);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// White pill with a leading icon, used for quick-access shortcuts.
class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: isDark ? AppColors.tagTextDark : AppColors.tagText,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _isDark(context)
                  ? AppColors.tagTextDark
                  : AppColors.tagText,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Large page title used at the top of each tab.
class PageTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const PageTitle({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                title,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Warm, blurred orange gradient — the brand's signature surface.
class EmberBackground extends StatelessWidget {
  final Widget? child;
  final BorderRadius borderRadius;

  const EmberBackground({
    super.key,
    this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A55), Color(0xFFF2542D), Color(0xFFC9361A)],
                  stops: [0, 0.55, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.6),
                  radius: 0.9,
                  colors: [
                    const Color(0xFFFFD2B8).withValues(alpha: 0.85),
                    const Color(0xFFFFD2B8).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, 1.0),
                  radius: 1.0,
                  colors: [
                    const Color(0xFF8E2410).withValues(alpha: 0.55),
                    const Color(0xFF8E2410).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
