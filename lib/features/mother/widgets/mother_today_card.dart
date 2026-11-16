import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models.dart';
import '../../../domain/nutrition/nutrition_calculator.dart';
import '../../../shared/widgets.dart';

class MotherPregnancyTodayCard extends StatelessWidget {
  const MotherPregnancyTodayCard({
    super.key,
    required this.pregnancy,
    required this.today,
    required this.onTtd,
    required this.onTakeTtd,
    required this.onAnc,
    required this.onCheckup,
  });

  final Pregnancy pregnancy;
  final DateTime today;
  final VoidCallback onTtd;
  final VoidCallback onTakeTtd;
  final VoidCallback onAnc;
  final VoidCallback onCheckup;

  @override
  Widget build(BuildContext context) {
    final takenToday = pregnancy.ttdDates.contains(dateToIso(today));
    final checkup = pregnancy.latestCheckup;
    final ancRemaining = (AkgReference.ancTarget - pregnancy.ancCount).clamp(
      0,
      AkgReference.ancTarget,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Hari ini', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                formatDateId(today, withYear: false),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MotherTodayRow(
            icon: Icons.medication_rounded,
            color: AppColors.coral,
            tint: AppColors.peachSoft,
            title: 'Tablet Tambah Darah',
            subtitle: takenToday
                ? 'Sudah dicatat hari ini'
                : 'Minum 1 tablet setelah makan malam',
            onTap: onTtd,
            trailing: takenToday
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 22,
                  )
                : FilledButton(
                    onPressed: onTakeTtd,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Catat'),
                  ),
          ),
          const Divider(height: 24),
          MotherTodayRow(
            icon: Icons.event_available_rounded,
            color: AppColors.primary,
            tint: AppColors.mint,
            title: 'Kunjungan ANC',
            subtitle: ancRemaining == 0
                ? '${pregnancy.ancCount} kunjungan tercatat'
                : '${pregnancy.ancCount}/${AkgReference.ancTarget} tercatat • $ancRemaining lagi',
            onTap: onAnc,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ),
          const Divider(height: 24),
          MotherTodayRow(
            icon: Icons.monitor_heart_outlined,
            color: AppColors.blue,
            tint: AppColors.blueSoft,
            title: 'Pemeriksaan terakhir',
            subtitle: checkup == null
                ? 'Belum ada catatan pemeriksaan'
                : '${relativeDayLabel(checkup.date)} • BB ${fmt1(checkup.weightKg)} kg • LiLA ${fmt1(checkup.lilaCm)} cm',
            onTap: onCheckup,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ),
          if (checkup?.needsConsultation == true) ...[
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Perlu konsultasi',
              body: 'LiLA < 23,5 cm atau Hb < 11 g/dL. Diskusikan dengan bidan atau dokter.',
              icon: Icons.warning_amber_rounded,
              background: AppColors.amberSoft,
              foreground: AppColors.amber,
            ),
          ],
        ],
      ),
    );
  }
}

class MotherTodayRow extends StatelessWidget {
  const MotherTodayRow({
    super.key,
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}
