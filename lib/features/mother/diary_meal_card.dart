import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class DiaryMealCard extends StatelessWidget {
  const DiaryMealCard({
    super.key,
    required this.meal,
    required this.logs,
    required this.onAdd,
    required this.onDelete,
    required this.onOpen,
  });

  final MealType meal;
  final List<FoodLog> logs;
  final VoidCallback onAdd;
  final ValueChanged<FoodLog> onDelete;
  final ValueChanged<FoodLog> onOpen;

  IconData get _icon => switch (meal) {
    MealType.breakfast => Icons.free_breakfast_rounded,
    MealType.lunch => Icons.lunch_dining_rounded,
    MealType.dinner => Icons.dinner_dining_rounded,
    MealType.snack => Icons.cookie_rounded,
  };

  Color get _color => switch (meal) {
    MealType.breakfast => AppColors.amber,
    MealType.lunch => AppColors.primary,
    MealType.dinner => AppColors.blue,
    MealType.snack => AppColors.coral,
  };

  Color get _background => switch (meal) {
    MealType.breakfast => AppColors.amberSoft,
    MealType.lunch => AppColors.mint,
    MealType.dinner => AppColors.blueSoft,
    MealType.snack => AppColors.peachSoft,
  };

  @override
  Widget build(BuildContext context) {
    final kcal = logs.fold<double>(
      0,
      (sum, log) => sum + (log.totals.kcal ?? 0),
    );
    final hasKcal = logs.any((log) => log.totals.kcal != null);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_icon, size: 19, color: _color),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      logs.isEmpty
                          ? 'Belum dicatat'
                          : '${logs.length} catatan • ${hasKcal ? '${kcal.round()} kkal' : '— kkal'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (logs.isEmpty)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('Catat'),
                  style: TextButton.styleFrom(minimumSize: const Size(0, 38)),
                )
              else
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Tambah',
                ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 4),
              child: Divider(height: 1),
            ),
            ...logs.map(
              (log) => InkWell(
                onTap: () => onOpen(log),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.items.map((e) => e.name).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (log.note != null)
                              Text(
                                log.note!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (log.totals.kcal != null)
                        Text(
                          '${log.totals.kcal!.round()} kkal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.muted,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') onDelete(log);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.red,
                                ),
                                SizedBox(width: 8),
                                Text('Hapus catatan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
