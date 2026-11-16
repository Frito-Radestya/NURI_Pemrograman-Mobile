import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class CheckupTile extends StatelessWidget {
  const CheckupTile({super.key, required this.checkup});

  final Checkup checkup;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: checkup.needsConsultation
                      ? AppColors.redSoft
                      : AppColors.mint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.monitor_heart_outlined,
                  size: 19,
                  color: checkup.needsConsultation
                      ? AppColors.red
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDateId(checkup.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${checkup.source == 'kader' ? 'Kader' : 'Mandiri'} • ${checkup.recordedBy}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (checkup.needsConsultation)
                const Pill(
                  label: 'Perlu konsultasi',
                  icon: Icons.warning_amber_rounded,
                  background: AppColors.redSoft,
                  foreground: AppColors.red,
                  fontSize: 11,
                )
              else
                const Pill(
                  label: 'Dalam batas',
                  icon: Icons.check_circle_outline_rounded,
                  background: AppColors.mint,
                  foreground: AppColors.primary,
                  fontSize: 11,
                ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              _CheckupValue(
                label: 'Berat',
                value: '${fmt1(checkup.weightKg)} kg',
              ),
              _CheckupValue(
                label: 'LiLA',
                value: '${fmt1(checkup.lilaCm)} cm',
                warning: checkup.lilaCm < 23.5,
              ),
              _CheckupValue(
                label: 'Hb',
                value: checkup.hbGdl == null
                    ? '—'
                    : '${fmt1(checkup.hbGdl)} g/dL',
                warning: checkup.hbGdl != null && checkup.hbGdl! < 11,
              ),
              _CheckupValue(
                label: 'Tekanan',
                value: checkup.systolic == null
                    ? '—'
                    : '${checkup.systolic}/${checkup.diastolic}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showNuriSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemeriksaan ${formatDateId(checkup.date)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            NuriInfoRow(
              icon: Icons.monitor_weight_outlined,
              title: 'Berat badan',
              subtitle: '${fmt1(checkup.weightKg)} kg',
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.straighten_rounded,
              title: 'Lingkar lengan atas (LiLA)',
              subtitle: checkup.lilaCm < 23.5
                  ? '${fmt1(checkup.lilaCm)} cm • di bawah 23,5 cm'
                  : '${fmt1(checkup.lilaCm)} cm • dalam batas',
              color: checkup.lilaCm < 23.5 ? AppColors.red : AppColors.primary,
              background: checkup.lilaCm < 23.5
                  ? AppColors.redSoft
                  : AppColors.mint,
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.science_outlined,
              title: 'Hemoglobin (Hb)',
              subtitle: checkup.hbGdl == null
                  ? 'Tidak dicatat'
                  : checkup.hbGdl! < 11
                  ? '${fmt1(checkup.hbGdl)} g/dL • anemia'
                  : '${fmt1(checkup.hbGdl)} g/dL • dalam batas',
              color: checkup.hbGdl != null && checkup.hbGdl! < 11
                  ? AppColors.red
                  : AppColors.primary,
              background: checkup.hbGdl != null && checkup.hbGdl! < 11
                  ? AppColors.redSoft
                  : AppColors.mint,
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.favorite_outline_rounded,
              title: 'Tekanan darah',
              subtitle: checkup.systolic == null
                  ? 'Tidak dicatat'
                  : '${checkup.systolic}/${checkup.diastolic} mmHg',
            ),
            if (checkup.needsConsultation) ...[
              const SizedBox(height: 12),
              const InfoBanner(
                title: 'Perlu konsultasi',
                body: 'LiLA < 23,5 cm atau Hb < 11 g/dL. Diskusikan dengan bidan atau dokter untuk tindak lanjut.',
                icon: Icons.warning_amber_rounded,
                background: AppColors.redSoft,
                foreground: AppColors.red,
              ),
            ],
            const SizedBox(height: 10),
            const NuriDisclaimer(compact: true),
          ],
        ),
      ),
    );
  }
}

class _CheckupValue extends StatelessWidget {
  const _CheckupValue({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

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
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: warning ? AppColors.red : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
