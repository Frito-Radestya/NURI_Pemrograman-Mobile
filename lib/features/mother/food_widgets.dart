import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';

class FoodMealSelector extends StatelessWidget {
  const FoodMealSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.dark = false,
  });

  final MealType value;
  final ValueChanged<MealType> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: MealType.values.map((meal) {
        final selected = meal == value;
        return GestureDetector(
          onTap: () => onChanged(meal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (dark ? Colors.white : AppColors.primary)
                  : (dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.mint),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected
                    ? (dark ? Colors.white : AppColors.primary)
                    : (dark
                          ? Colors.white.withValues(alpha: 0.16)
                          : AppColors.line),
              ),
            ),
            child: Text(
              meal.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (dark ? AppColors.primaryDeep : Colors.white)
                    : (dark ? Colors.white70 : AppColors.muted),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
