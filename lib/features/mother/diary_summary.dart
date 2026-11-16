import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../shared/widgets.dart';

class DiarySummary extends StatelessWidget {
  const DiarySummary({
    super.key,
    required this.totals,
    required this.target,
    required this.targetLabel,
    required this.onAdd,
  });

  final NutritionTotals totals;
  final AkgTarget target;
  final String targetLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final percent =
        (NutritionCalculator.percent(totals.kcal, target.energyKcal) ?? 0) /
        100;
    final status = NutritionCalculator.status(totals.kcal, target.energyKcal);
    final color = switch (status) {
      NutrientStatus.low => AppColors.amber,
      NutrientStatus.high => AppColors.coral,
      _ => AppColors.primary,
    };
    final label = switch (status) {
      NutrientStatus.low => 'Perlu dilengkapi',
      NutrientStatus.high => 'Melebihi anjuran',
      _ => 'Sesuai anjuran',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 7.5,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: AlwaysStoppedAnimation(color),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(percent * 100).round()}%',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            'AKG',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: totals.kcal == null
                                ? '—'
                                : totals.kcal!.round().toString(),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.text,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${target.energyKcal.round()} kkal',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      targetLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NutrientBar(
                  label: 'Protein',
                  value: totals.proteinG,
                  target: target.proteinG,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Lemak',
                  value: totals.fatG,
                  target: target.fatG,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Karbo',
                  value: totals.carbG,
                  target: target.carbG,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Besi',
                  value: totals.ironMg,
                  target: target.ironMg,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah makan'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double? value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = ((value ?? 0) / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
        const SizedBox(height: 3),
        Text(
          value == null ? '—' : value!.toStringAsFixed(value! < 10 ? 1 : 0),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '/ ${target.toStringAsFixed(target < 10 ? 1 : 0)}',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
