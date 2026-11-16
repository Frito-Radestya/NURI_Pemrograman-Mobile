import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/growth/growth_calculator.dart';
import '../../shared/widgets.dart';

class GrowthPreviewCard extends StatelessWidget {
  const GrowthPreviewCard({super.key, required this.evaluation});

  final GrowthEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final colors = GrowthStatusBadge.colorsFor(evaluation.category);
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: colors.$1,
      borderColor: colors.$1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pratinjau skrining',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              GrowthStatusBadge(category: evaluation.category),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${evaluation.zScore >= 0 ? '+' : ''}${evaluation.zScore.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1,
                  color: colors.$2,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'SD',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.$2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Median WHO ${evaluation.medianCm.toStringAsFixed(1)} cm',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rentang normal: ${evaluation.minus2Cm.toStringAsFixed(1)}–${evaluation.plus2Cm.toStringAsFixed(1)} cm untuk usia ${evaluation.ageMonths} bulan.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          if (evaluation.correctionNote != null) ...[
            const SizedBox(height: 6),
            Text(
              evaluation.correctionNote!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ],
          if (evaluation.implausible) ...[
            const SizedBox(height: 8),
            const Text(
              'Nilai z di luar ±6 SD. Periksa kembali sebelum menyimpan.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
