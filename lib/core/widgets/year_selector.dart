import 'package:flutter/material.dart';

/// A horizontal scrollable year selector widget
class YearSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final years = List.generate(
      maxYear - minYear + 1,
      (index) => minYear + index,
    );

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == selectedYear;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onYearSelected(year),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
