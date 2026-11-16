import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class ProfilePregnancyCard extends StatelessWidget {
  const ProfilePregnancyCard({
    super.key,
    required this.pregnancy,
    required this.onAdd,
    required this.onTtd,
    required this.onAnc,
    required this.onCheckup,
    required this.onBirth,
    required this.onEnd,
  });

  final Pregnancy? pregnancy;
  final VoidCallback onAdd;
  final VoidCallback onTtd;
  final VoidCallback onAnc;
  final VoidCallback onCheckup;
  final VoidCallback onBirth;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    if (pregnancy == null) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pregnant_woman_rounded,
                  size: 20,
                  color: AppColors.purple,
                ),
                SizedBox(width: 8),
                Text(
                  'Kehamilan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada kehamilan aktif. Tambahkan HPHT untuk memantau usia kehamilan, TTD, dan ANC.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            NuriButton(
              label: 'Tambah kehamilan',
              icon: Icons.add_rounded,
              variant: NuriButtonVariant.outlined,
              onPressed: onAdd,
            ),
          ],
        ),
      );
    }
    final active = pregnancy!;
    final progress = PregnancyCalculator.progress(
      hpht: active.hpht,
      hpl: active.hpl,
    );
    final trimester = progress.trimester;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pregnant_woman_rounded,
                size: 20,
                color: AppColors.purple,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kehamilan aktif',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Pill(
                label: 'Trimester $trimester',
                background: AppColors.purpleSoft,
                foreground: AppColors.purple,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PregnancyStat(
                label: 'Usia',
                value: '${progress.weeks}',
                unit: 'mgg',
              ),
              _PregnancyStat(
                label: 'Hari',
                value: '${progress.days}',
                unit: 'hari',
              ),
              _PregnancyStat(
                label: 'HPL',
                value: formatDateId(
                  active.hpl,
                  withYear: false,
                  shortMonth: true,
                ),
                unit: '',
              ),
              _PregnancyStat(
                label: 'TTD',
                value: '${active.ttdCount}',
                unit: 'tab',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.medication_outlined,
                  label: 'TTD',
                  onTap: onTtd,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.event_available_outlined,
                  label: 'ANC',
                  onTap: onAnc,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Periksa',
                  onTap: onCheckup,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBirth,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  icon: const Icon(Icons.child_friendly_rounded, size: 17),
                  label: const Text('Lahirkan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: onEnd,
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  child: const Text('Akhiri kehamilan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PregnancyStat extends StatelessWidget {
  const _PregnancyStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: AppColors.text,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
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

class _PregnancyAction extends StatelessWidget {
  const _PregnancyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
