import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/alumni_list_provider.dart';

/// Hosts the five main tabs and the bottom navigation bar.
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    // Home and Alumni both show directory data, so fetch it once up front.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AlumniListProvider>();
      if (provider.allAlumni.isEmpty) provider.loadAlumni();
    });
  }

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      index,
      // Tapping the active tab returns it to its first page.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.groups_2_outlined, Icons.groups_2_rounded, 'Alumni'),
    _NavItem(Icons.account_balance_outlined, Icons.account_balance_rounded, 'School'),
    _NavItem(Icons.co_present_outlined, Icons.co_present_rounded, 'Teachers'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.darkText : AppColors.ink;
    final idleColor = isDark ? const Color(0xFF6A6A6A) : const Color(0xFFB5B5B5);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: i == currentIndex,
                    activeColor: activeColor,
                    idleColor: idleColor,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final Color activeColor;
  final Color idleColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.idleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : idleColor;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: color,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(item.label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
