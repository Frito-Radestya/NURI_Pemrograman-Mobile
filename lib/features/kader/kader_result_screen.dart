import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../data/nuri_repository.dart' show ScreeningRecord;
import '../../domain/models/child.dart';
import '../../domain/models/growth_status.dart';
import '../../domain/models/recommendation.dart';
import '../../state/app_state.dart';

/// Hasil skrining balita: ringkasan antropometri, interpretasi, dan tindak lanjut.
class KaderResultScreen extends StatelessWidget {
  const KaderResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final ScreeningRecord? record =
        child == null ? null : state.latestScreening(child.id);

    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/kader-entry'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('KADER POSYANDU', style: AppText.caption),
            SizedBox(height: 2),
            Text('Hasil Skrining Balita', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(icon: Icons.search_rounded, onPressed: () {}),
          const SizedBox(width: 8),
          NuriSoftButton(icon: Icons.ios_share_rounded, onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          const NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.info_outline_rounded,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Skrining Awal Posyandu • Bukan Diagnosis Medis',
                    style: AppText.bodyStrong,
                  ),
                  TextSpan(
                    text:
                        '\nHasil ini merupakan indikasi awal untuk pemantauan '
                        'tumbuh kembang dan penanganan tindak lanjut terpadu ke '
                        'Puskesmas/Tenaga Kesehatan.',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (child == null || record == null)
            const NoteBox(
              background: AppColors.pastelPeach,
              icon: Icons.info_outline_rounded,
              child: Text(
                'Belum ada hasil skrining. Catat pengukuran balita terlebih '
                'dahulu dari layar input pengukuran.',
                style: AppText.bodySm,
              ),
            )
          else
            _ResultBody(child: child, record: record, state: state),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.child,
    required this.record,
    required this.state,
  });

  final Child child;
  final ScreeningRecord record;
  final NuriAppState state;

  @override
  Widget build(BuildContext context) {
    final GrowthStatus status = record.result.status;
    final Recommendation? recommendation = record.result.recommendation ??
        state.reference.recommendations.find(
          status,
          record.result.ageMonths,
        );
    final bool duaT = record.result.zScore < -2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profil.
        NuriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NuriAvatar(
                    initials: _initials(child.nickname),
                    size: 52,
                    background: _statusSoft(status),
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.nickname, style: AppText.h3),
                        const SizedBox(height: 3),
                        Text(
                          '${child.ageLabelAt(state.today)} • ${child.sex.label}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.inkFaint,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Diukur ${_formatDate(record.measurement.measuredOn)} • '
                'Metode ${record.measurement.method.shortLabel}',
                style: AppText.caption,
              ),
              const SizedBox(height: 12),
              const NoteRow(
                icon: Icons.location_on_outlined,
                text: 'Posyandu Melati RW 04 • Kader Posyandu',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Status utama.
        NuriCard(
          border: _statusSoft(status),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(
                    text: '${status.label} • Z ${record.result.zLabel} SD',
                    color: _statusSoft(status),
                  ),
                  const Tag(text: 'e-PPGBM RI'),
                ],
              ),
              const SizedBox(height: 14),
              Text(status.plainLanguage, style: AppText.h2),
              const SizedBox(height: 10),
              Text(
                recommendation?.summary ??
                    'Lanjutkan pemantauan rutin di Posyandu setiap bulan.',
                style: AppText.body,
              ),
              const SizedBox(height: 12),
              const NoteRow(
                icon: Icons.verified_outlined,
                color: AppColors.brandText,
                text: 'Dihitung lokal memakai baku WHO & Standar Kemenkes RI',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (duaT) ...[
          const NoteBox(
            background: AppColors.pastelPink,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.statusSangatPendek,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Peringatan 2T',
                    style: AppText.bodyStrong,
                  ),
                  TextSpan(
                    text:
                        '\nZ-score TB/U berada di bawah -2 SD. Anak masuk '
                        'kategori pendek/sangat pendek dan disarankan tindak '
                        'lanjut segera ke Puskesmas.',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SectionHeader(
          title: 'Hasil Antropometri Terkini',
          subtitle: 'Baku WHO - MGRS',
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MetricBox(
                label: 'Berat Badan',
                value: record.measurement.weightKg.toStringAsFixed(2),
                unit: 'kg',
                trend: 'Umur ${record.result.ageMonths} bulan',
                trendColor: AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricBox(
                label: 'Tinggi Badan',
                value: record.measurement.lengthHeightCm.toStringAsFixed(1),
                unit: 'cm',
                trend: 'Z ${record.result.zLabel} SD (${status.label})',
                trendColor: _statusColor(status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Tag(text: 'Metode ${record.measurement.method.label}'),
            Tag(
              text: child.consent == null
                  ? 'Consent belum tercatat'
                  : 'Consent ${child.consent!.method.label}',
            ),
            const Tag(text: 'Kader Posyandu'),
          ],
        ),
        const SizedBox(height: 16),

        // Rekomendasi tindak lanjut.
        NuriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rekomendasi Tindak Lanjut',
                      style: AppText.h3,
                    ),
                  ),
                  Tag(text: '${recommendation?.actions.length ?? 0} Langkah'),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendation == null)
                const Text(
                  'Belum ada rekomendasi khusus untuk status dan umur ini.',
                  style: AppText.bodySm,
                )
              else ...[
                Text(recommendation.title, style: AppText.title),
                const SizedBox(height: 4),
                Text(recommendation.summary, style: AppText.bodySm),
                const SizedBox(height: 12),
                for (final String action in recommendation.actions) ...[
                  _ActionRow(text: action),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        const NoteBox(
          background: AppColors.pastelGreenSoft,
          icon: Icons.eco_rounded,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Skrining awal, bukan diagnosis medis.',
                  style: AppText.bodyStrong,
                ),
                TextSpan(
                  text:
                      '\nKeputusan klinis tetap berada pada dokter atau tenaga '
                      'kesehatan. Kader berperan mendampingi keluarga menuju '
                      'layanan lanjutan.',
                  style: AppText.bodySm,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: NuriSecondaryButton(
                label: 'Kirim ke Ibu',
                icon: Icons.send_outlined,
                filled: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NuriPrimaryButton(
                label: 'Kirim Rujukan',
                onPressed: () => context.push('/kader-activity'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.brand,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.bodySm)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utilitas.
// ---------------------------------------------------------------------------

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

Color _statusColor(GrowthStatus status) {
  switch (status) {
    case GrowthStatus.normal:
      return AppColors.statusNormal;
    case GrowthStatus.pendek:
      return AppColors.statusPendek;
    case GrowthStatus.sangatPendek:
      return AppColors.statusSangatPendek;
    case GrowthStatus.tinggi:
      return AppColors.statusTinggi;
  }
}

Color _statusSoft(GrowthStatus status) {
  switch (status) {
    case GrowthStatus.normal:
      return AppColors.statusNormalSoft;
    case GrowthStatus.pendek:
      return AppColors.statusPendekSoft;
    case GrowthStatus.sangatPendek:
      return AppColors.statusSangatPendekSoft;
    case GrowthStatus.tinggi:
      return AppColors.statusTinggiSoft;
  }
}

const List<String> _bulan = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _formatDate(DateTime date) =>
    '${date.day} ${_bulan[date.month - 1]} ${date.year}';
