import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class GrowthSummary extends StatelessWidget {
  const GrowthSummary({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    final zFormatted = latest == null
        ? '—'
        : '${latest.zHfa >= 0 ? '+' : ''}${fmt1(latest.zHfa)} SD';

    return Column(
      children: [
        // 4 WHO Growth Metrics Grid (2x2 Clean Rounded Bento)
        Row(
          children: [
            // 1. BB / Umur
            Expanded(
              child: _BentoMetricCard(
                label: 'BB / Umur',
                value: latest == null ? '—' : fmt1(latest.weightKg),
                unit: 'kg',
                sublabel: 'Z-Score: +0.4 SD',
                badgeText: 'Berat Normal',
                icon: Icons.scale_rounded,
                badgeBg: AppColors.secondaryFixed.withValues(alpha: 0.4),
                badgeFg: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            // 2. TB / Umur
            Expanded(
              child: _BentoMetricCard(
                label: 'TB / Umur',
                value: latest == null ? '—' : fmt1(latest.measuredCm),
                unit: 'cm',
                sublabel: 'Z-Score: $zFormatted',
                badgeText:
                    latest != null && latest.category == GrowthCategory.stunted
                    ? 'Perlu Perhatian'
                    : 'Bebas Stunting',
                icon: Icons.straighten_rounded,
                badgeBg:
                    latest != null && latest.category == GrowthCategory.stunted
                    ? AppColors.amberSoft
                    : AppColors.secondaryFixed.withValues(alpha: 0.4),
                badgeFg:
                    latest != null && latest.category == GrowthCategory.stunted
                    ? AppColors.amber
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. BB / TB (Wasting)
            Expanded(
              child: _BentoMetricCard(
                label: 'BB / TB (Wasting)',
                value: latest == null ? '—' : '13.5',
                unit: 'kg/m²',
                sublabel: 'Z-Score: 0.0 SD (Ideal)',
                badgeText: 'Gizi Baik',
                icon: Icons.child_care_rounded,
                badgeBg: AppColors.secondaryFixed.withValues(alpha: 0.4),
                badgeFg: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            // 4. LK / Umur (Lingkar Kepala)
            Expanded(
              child: _BentoMetricCard(
                label: 'Lingkar Kepala',
                value: latest == null ? '—' : '47.0',
                unit: 'cm',
                sublabel: 'Z-Score: Normal',
                badgeText: 'Kepala Normal',
                icon: Icons.face_rounded,
                badgeBg: AppColors.surfaceContainer,
                badgeFg: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoMetricCard extends StatelessWidget {
  const _BentoMetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.sublabel,
    required this.badgeText,
    required this.icon,
    required this.badgeBg,
    required this.badgeFg,
  });

  final String label;
  final String value;
  final String unit;
  final String sublabel;
  final String badgeText;
  final IconData icon;
  final Color badgeBg;
  final Color badgeFg;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerLow,
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                height: 1,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
