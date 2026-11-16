import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';

class DiaryDateNavigator extends StatelessWidget {
  const DiaryDateNavigator({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    return Column(
      children: [
        Row(
          children: [
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () =>
                  onChanged(selected.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    relativeDayLabel(selected),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    formatDateId(selected),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: selected.isBefore(today)
                  ? () => onChanged(selected.add(const Duration(days: 1)))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: days.map((date) {
            final active = dateOnly(date) == dateOnly(selected);
            final isToday = dateOnly(date) == today;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: InkWell(
                  onTap: () => onChanged(date),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.line,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          formatDayShort(date),
                          style: TextStyle(
                            fontSize: 11,
                            color: active ? Colors.white70 : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: active ? Colors.white : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isToday
                                ? (active ? AppColors.peach : AppColors.coral)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? AppColors.line : AppColors.text,
        ),
      ),
    );
  }
}
