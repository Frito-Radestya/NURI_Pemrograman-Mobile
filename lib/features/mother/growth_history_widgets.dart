import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'growth_measurement_screen.dart';

class GrowthMeasurementNote extends StatelessWidget {
  const GrowthMeasurementNote({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    if (latest == null) {
      return const InfoBanner(
        title: 'Mulai dari satu pengukuran',
        body: 'Ukur panjang badan berbaring untuk anak < 24 bulan, atau tinggi berdiri untuk ≥ 24 bulan.',
        icon: Icons.straighten_rounded,
      );
    }
    return Column(
      children: [
        if (latest.correctionNote != null)
          InfoBanner(
            title: 'Koreksi metode ukur',
            body: latest.correctionNote!,
            icon: Icons.straighten_rounded,
          ),
        if (latest.flags.isNotEmpty) ...[
          if (latest.correctionNote != null) const SizedBox(height: 8),
          InfoBanner(
            title: latest.flags.join(' • '),
            body: latest.implausible
                ? 'Nilai ini perlu diperiksa ulang bersama tenaga kesehatan.'
                : 'Catatan otomatis dari mesin skrining NURI.',
            icon: Icons.info_outline_rounded,
            background: AppColors.amberSoft,
            foreground: AppColors.amber,
          ),
        ],
      ],
    );
  }
}

class GrowthHistoryPreview extends StatelessWidget {
  const GrowthHistoryPreview({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final list = List<Measurement>.from(child.measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    if (list.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.show_chart_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada riwayat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pengukuran pertama akan muncul di sini.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            NuriButton(
              label: 'Catat pengukuran',
              icon: Icons.add_rounded,
              variant: NuriButtonVariant.outlined,
              height: 44,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeasurementInputScreen(childId: child.id),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < list.length && i < 4; i++) ...[
            GrowthHistoryTile(
              measurement: list[i],
              onTap: () => showMeasurementDetail(context, child, list[i]),
            ),
            if (i < list.length - 1 && i < 3) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class GrowthHistoryTile extends StatelessWidget {
  const GrowthHistoryTile({
    super.key,
    required this.measurement,
    required this.onTap,
  });

  final Measurement measurement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.straighten_rounded,
                size: 19,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatDateId(measurement.date, withYear: false)} • ${measurement.ageMonths} bulan',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fmt1(measurement.measuredCm)} cm • ${fmt1(measurement.weightKg)} kg • ${measurement.source == 'kader' ? 'Kader' : 'Mandiri'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            GrowthStatusBadge(category: measurement.category, compact: true),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

void showMeasurementDetail(
  BuildContext context,
  Child child,
  Measurement measurement,
) {
  showNuriSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Detail pengukuran',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              GrowthStatusBadge(category: measurement.category),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${formatDateId(measurement.date)} • ${measurement.ageMonths} bulan',
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _DetailMetric(
                  label: 'Berat',
                  value: '${fmt1(measurement.weightKg)} kg',
                ),
                _DetailMetric(
                  label: 'Ukur',
                  value: '${fmt1(measurement.measuredCm)} cm',
                ),
                _DetailMetric(
                  label: 'Terkoreksi',
                  value: '${fmt1(measurement.correctedCm)} cm',
                ),
                _DetailMetric(
                  label: 'Z-score',
                  value:
                      '${measurement.zHfa >= 0 ? '+' : ''}${fmt2(measurement.zHfa)} SD',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          NuriInfoRow(
            icon: Icons.straighten_rounded,
            title: measurement.method.label,
            subtitle:
                measurement.correctionNote ?? 'Tidak ada koreksi metode ukur.',
          ),
          const SizedBox(height: 10),
          NuriInfoRow(
            icon: measurement.synced
                ? Icons.cloud_done_outlined
                : Icons.cloud_upload_outlined,
            title: measurement.synced ? 'Tersinkron' : 'Menunggu sinkronisasi',
            subtitle: measurement.source == 'kader'
                ? 'Dicatat oleh kader posyandu'
                : 'Dicatat mandiri oleh keluarga',
            color: measurement.synced ? AppColors.primary : AppColors.amber,
            background: measurement.synced
                ? AppColors.mint
                : AppColors.amberSoft,
          ),
          if (measurement.flags.isNotEmpty) ...[
            const SizedBox(height: 12),
            InfoBanner(
              title: 'Catatan skrining',
              body: measurement.flags.join(' • '),
              icon: Icons.info_outline_rounded,
              background: AppColors.amberSoft,
              foreground: AppColors.amber,
            ),
          ],
          const SizedBox(height: 10),
          const NuriDisclaimer(compact: true),
        ],
      ),
    ),
  );
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});
  final String label;
  final String value;

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
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
