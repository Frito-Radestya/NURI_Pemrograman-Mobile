import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/growth_chart.dart';
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

/// Detail lengkap satu sasaran balita: pengukuran, tren, nutrisi, dan rencana.
class KaderTargetDetailScreen extends StatelessWidget {
  const KaderTargetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild ??
        (state.children.isNotEmpty ? state.children.first : null);

    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/kader-targets'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI KADER', style: AppText.caption),
            SizedBox(height: 2),
            Text('Detail Sasaran Balita', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(icon: Icons.search_rounded, onPressed: () {}),
          const SizedBox(width: 8),
          NuriSoftButton(icon: Icons.ios_share_rounded, onPressed: () {}),
        ],
      ),
      body: child == null
          ? const _EmptyDetail()
          : _DetailBody(state: state, child: child),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.child_care_rounded, size: 48, color: AppColors.inkFaint),
          SizedBox(height: 12),
          Text('Belum ada data balita', style: AppText.h3),
          SizedBox(height: 6),
          Text(
            'Tambahkan data anak untuk melihat detail tumbuh kembangnya.',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state, required this.child});

  final NuriAppState state;
  final Child child;

  @override
  Widget build(BuildContext context) {
    final ScreeningRecord? record = state.latestScreening(child.id);
    final List<ScreeningRecord> history = state.screeningsFor(child.id).reversed
        .toList();
    final Recommendation? recommendation = record == null
        ? null
        : record.result.recommendation ??
            state.reference.recommendations.find(
              record.result.status,
              record.result.ageMonths,
            );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 28),
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
                    size: 56,
                    background: _statusSoft(
                      record?.result.status ?? GrowthStatus.normal,
                    ),
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.h3,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${child.sex.label} • ${child.ageLabelAt(state.today)}',
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
              const SizedBox(height: 12),
              Text(
                child.posyanduName ?? 'Posyandu Melati',
                style: AppText.caption,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SoftChip(
                    label: child.sex.label,
                    icon: Icons.family_restroom_rounded,
                  ),
                  SoftChip(
                    label: child.consent == null
                        ? 'Consent belum tercatat'
                        : 'Consent ${child.consent!.method.label}',
                    icon: Icons.verified_user_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: NuriSecondaryButton(
                      label: 'Hubungi Ibu',
                      icon: Icons.chat_bubble_outline_rounded,
                      filled: true,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NuriSecondaryButton(
                      label: 'Buka KIA',
                      icon: Icons.menu_book_outlined,
                      filled: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (record == null)
          const NoteBox(
            background: AppColors.pastelPeach,
            icon: Icons.info_outline_rounded,
            child: Text(
              'Balita ini belum memiliki hasil pengukuran. Catat pengukuran '
              'terlebih dahulu untuk melihat analisis tumbuh kembang.',
              style: AppText.bodySm,
            ),
          )
        else ...[
          SectionHeader(
            title: 'Hasil Pengukuran Posyandu',
            subtitle: _formatDate(record.measurement.measuredOn),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MetricBox(
                  label: 'BERAT BADAN',
                  value: record.measurement.weightKg.toStringAsFixed(1),
                  unit: 'kg',
                  trend: 'Umur ${record.result.ageMonths} bulan',
                  trendColor: AppColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricBox(
                  label: 'TINGGI BADAN',
                  value: record.measurement.lengthHeightCm.toStringAsFixed(1),
                  unit: 'cm',
                  trend: 'Metode ${record.measurement.method.shortLabel}',
                  trendColor: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banner Z-Score.
          NuriCard(
            color: _statusSoft(record.result.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Dot(color: _statusColor(record.result.status)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Z-SCORE TB/U : ${record.result.zLabel} SD • '
                        '${record.result.status.label}',
                        style: AppText.h3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Tag(text: record.result.status.plainLanguage),
                const SizedBox(height: 10),
                Text(
                  recommendation?.summary ??
                      'Lanjutkan pemantauan rutin tumbuh kembang anak di '
                          'Posyandu setiap bulan.',
                  style: AppText.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Riwayat & tren KMS.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Riwayat & Tren KMS', style: AppText.h3),
                    ),
                    Tag(text: '${history.length} Pengukuran'),
                  ],
                ),
                const SizedBox(height: 16),
                if (history.length >= 2)
                  GrowthChart(
                    points: _normalized(history),
                    labels: _labels(history),
                    highlightIndex: history.length - 1,
                    highlightLabel:
                        '${history.first.measurement.lengthHeightCm.toStringAsFixed(1)} cm',
                  )
                else
                  const Text(
                    'Butuh minimal dua pengukuran untuk menampilkan tren.',
                    style: AppText.bodySm,
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Data append-only: setiap pengukuran baru disimpan tanpa '
                  'menghapus riwayat sebelumnya.',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                for (final ScreeningRecord item in history.take(6)) ...[
                  _HistoryRow(record: item),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rekomendasi.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Rencana & Tindak Lanjut',
                        style: AppText.h3,
                      ),
                    ),
                    Tag(text: '${recommendation?.actions.length ?? 0} Langkah'),
                  ],
                ),
                const SizedBox(height: 14),
                if (recommendation == null)
                  const Text(
                    'Belum ada rekomendasi untuk kombinasi status dan umur ini.',
                    style: AppText.bodySm,
                  )
                else ...[
                  Text(recommendation.title, style: AppText.title),
                  const SizedBox(height: 4),
                  Text(recommendation.summary, style: AppText.bodySm),
                  const SizedBox(height: 12),
                  for (final String action in recommendation.actions) ...[
                    _Bullet(text: action),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Catat Konseling',
                  icon: Icons.edit_note_rounded,
                  filled: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NuriPrimaryButton(
                  label: 'Buat Rujukan Puskesmas',
                  onPressed: () => context.push('/kader-result'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final ScreeningRecord record;

  @override
  Widget build(BuildContext context) {
    final GrowthStatus status = record.result.status;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.measurement.measuredOn),
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 2),
                Text(
                  'BB ${record.measurement.weightKg.toStringAsFixed(1)} kg • '
                  'TB ${record.measurement.lengthHeightCm.toStringAsFixed(1)} cm',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          StatusChip(text: status.label, color: _statusSoft(status)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
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

List<double> _normalized(List<ScreeningRecord> history) {
  final List<ScreeningRecord> ordered = history.reversed.toList();
  final List<double> values = ordered
      .map((ScreeningRecord r) => r.measurement.lengthHeightCm)
      .toList();
  final double min = values.reduce((double a, double b) => a < b ? a : b);
  final double max = values.reduce((double a, double b) => a > b ? a : b);
  final double range = max - min;
  if (range == 0) {
    return values.map((_) => 0.5).toList();
  }
  return values.map((double v) => (v - min) / range).toList();
}

List<String> _labels(List<ScreeningRecord> history) {
  final List<ScreeningRecord> ordered = history.reversed.toList();
  return ordered
      .map((ScreeningRecord r) => _bulan[r.measurement.measuredOn.month - 1])
      .toList();
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
