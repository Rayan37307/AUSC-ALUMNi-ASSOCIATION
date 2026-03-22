import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class YearSelector extends StatefulWidget {
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final int minYear;
  final int maxYear;

  YearSelector({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
    this.minYear = 1970,
    int? maxYear,
  }) : maxYear = maxYear ?? DateTime.now().year + 5;

  @override
  State<YearSelector> createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  late ScrollController _scrollController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedYear - widget.minYear;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(YearSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      setState(() {
        _currentIndex = widget.selectedYear - widget.minYear;
      });
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    const itemWidth = 72.0;
    final offset =
        _currentIndex * itemWidth -
        (MediaQuery.of(context).size.width / 2) +
        (itemWidth / 2);
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = List.generate(
      widget.maxYear - widget.minYear + 1,
      (index) => widget.minYear + index,
    );

    return Container(
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: years.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == widget.selectedYear;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
                widget.onYearSelected(year);
                _scrollToSelected();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected
                      ? null
                      : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModernYearSelector extends StatefulWidget {
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final int minYear;
  final int maxYear;

  ModernYearSelector({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
    this.minYear = 1970,
    int? maxYear,
  }) : maxYear = maxYear ?? DateTime.now().year + 5;

  @override
  State<ModernYearSelector> createState() => _ModernYearSelectorState();
}

class _ModernYearSelectorState extends State<ModernYearSelector> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: widget.selectedYear - widget.minYear,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = List.generate(
      widget.maxYear - widget.minYear + 1,
      (index) => widget.minYear + index,
    );

    return Container(
      height: 160,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              widget.onYearSelected(years[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: years.length,
              builder: (context, index) {
                final year = years[index];
                final selected = year == widget.selectedYear;

                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      fontSize: selected ? 24 : 18,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    child: Text(year.toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
