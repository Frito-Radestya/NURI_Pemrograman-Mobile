import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models.dart';
import '../../../domain/pregnancy/pregnancy_calculator.dart';
import '../../../shared/widgets.dart';

class MotherPregnancyHero extends StatelessWidget {
  const MotherPregnancyHero({
    super.key,
    required this.pregnancy,
    required this.progress,
  });

  final Pregnancy pregnancy;
  final PregnancyProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.headerWide,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill(
                label: 'Trimester ${progress.trimester}',
                background: AppColors.softMint,
                foreground: AppColors.deepForest,
                fontSize: 11.5,
                bold: true,
              ),
              const Spacer(),
              Text(
                progress.daysToHpl >= 0
                    ? '${progress.daysToHpl} hari menuju HPL'
                    : 'Sudah waktunya',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Usia kehamilan',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${progress.weeks} minggu ${progress.days} hari',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              height: 1.12,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Stack(
                children: [
                  Container(
                    height: 6,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(height: 6, color: AppColors.leafGreen),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perkiraan lahir ${formatDateId(pregnancy.hpl, withYear: true)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.child_care_rounded,
                  size: 19,
                  color: AppColors.leafGreen,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Si Kecil ${progress.sizeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '±${progress.fetalWeightG} g',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.82),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MotherChildHero extends StatelessWidget {
  const MotherChildHero({super.key, required this.child, required this.onTap});

  final Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    final status = latest == null ? null : _plainGrowthStatus(latest.category);
    return AppCard(
      onTap: onTap,
      shadow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                name: child.nickname,
                index: child.avatarIndex,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            child.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            child.ageLabel(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
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
                          status?.label ?? 'Pantau Tumbuh Kembang',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Berat Badan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: fmt1(latest.weightKg),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            children: const [
                              TextSpan(
                                text: ' kg',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '+0.3 kg',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tinggi Badan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: fmt1(latest.measuredCm),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            children: const [
                              TextSpan(
                                text: ' cm',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Normal',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Lingkar Kepala',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '47.0 cm',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Normal',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Belum ada pengukuran',
              body: 'Catat panjang dan berat badan pertama untuk melihat posisi tumbuh Si Kecil.',
              icon: Icons.straighten_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

({String label, IconData icon, Color background, Color foreground})
_plainGrowthStatus(GrowthCategory category) => (
  label: category.plainLabel,
  icon: switch (category) {
    GrowthCategory.normal => Icons.check_circle_outline_rounded,
    GrowthCategory.stunted => Icons.trending_down_rounded,
    GrowthCategory.severelyStunted => Icons.error_outline_rounded,
    GrowthCategory.tall => Icons.trending_up_rounded,
  },
  background: switch (category) {
    GrowthCategory.normal => AppColors.mint,
    GrowthCategory.stunted => AppColors.amberSoft,
    GrowthCategory.severelyStunted => AppColors.redSoft,
    GrowthCategory.tall => AppColors.blueSoft,
  },
  foreground: switch (category) {
    GrowthCategory.normal => AppColors.primaryDark,
    GrowthCategory.stunted => AppColors.amber,
    GrowthCategory.severelyStunted => AppColors.red,
    GrowthCategory.tall => AppColors.blue,
  },
);

class MotherEmptyDataCard extends StatelessWidget {
  const MotherEmptyDataCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x100D631B),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/nuri_logo_mark.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.spa_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Data Ibu belum lengkap',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tambahkan data kehamilan atau anak dari menu Profil untuk mulai memantau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
