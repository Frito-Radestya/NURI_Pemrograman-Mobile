import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart' show NuriAvatar;
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../core/widgets/who_growth_chart.dart';
import '../../data/nuri_repository.dart';
import '../../domain/models/child.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/growth_status.dart';
import '../../domain/models/recommendation.dart';
import '../../state/app_state.dart';

/// Layar pertumbuhan — kurva, metrik, dan riwayat penimbangan.
class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;

    return NuriScaffold(
      bottomNavigationBar: const MomTabBar(active: '/growth'),
      topBar: const _GrowthTopBar(),
      body: child == null
          ? const _NoChildState()
          : _GrowthBody(state: state, child: child),
    );
  }
}

/// Isi layar ketika anak sudah dipilih.
class _GrowthBody extends StatelessWidget {
  const _GrowthBody({required this.state, required this.child});

  final NuriAppState state;
  final Child child;

  @override
  Widget build(BuildContext context) {
    final ScreeningRecord? latest = state.latestForSelected;
    final List<ScreeningRecord> records = state.screeningsFor(child.id);

    if (latest == null) {
      return ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          _ProfileCard(child: child, latest: null),
          const SizedBox(height: 14),
          NuriCard(
            child: Column(
              children: [
                const IconBadge(
                  icon: Icons.monitor_weight_outlined,
                  size: 60,
                  radius: 20,
                ),
                const SizedBox(height: 14),
                const Text('Belum Ada Pengukuran', style: AppText.h3),
                const SizedBox(height: 8),
                Text(
                  'Ukur berat dan tinggi ${child.nickname} untuk melihat kurva '
                  'pertumbuhan WHO serta status gizinya.',
                  style: AppText.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                NuriPrimaryButton(
                  label: 'Ukur sekarang',
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/screening'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final GrowthResult result = latest.result;
    final GrowthStatus status = result.status;
    final Recommendation? recommendation = result.recommendation ??
        state.reference.recommendations.find(status, result.ageMonths);
    final double weight = latest.measurement.weightKg;
    final double height = latest.measurement.lengthHeightCm;
    final ScreeningRecord? previous =
        records.length >= 2 ? records[records.length - 2] : null;
    final double deltaGrams =
        previous == null ? 0 : (weight - previous.measurement.weightKg) * 1000;
    final String trend = previous == null
        ? 'Pengukuran pertama • ${status.label}'
        : '${deltaGrams >= 0 ? '+' : ''}${deltaGrams.round()} gram dari '
              'pengukuran sebelumnya • ${status.label}';

    final List<WhoChartPoint> points = <WhoChartPoint>[
      for (int i = 0; i < records.length; i++)
        WhoChartPoint(
          month: records[i].result.ageMonths,
          cm: records[i].measurement.adjustedCm,
          isLatest: i == records.length - 1,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        _ProfileCard(child: child, latest: latest),
        const SizedBox(height: 14),

        // Pemilih metrik (visual, fokus TB/U).
        const Row(
          children: [
            Expanded(
              child: _TogglePill(label: 'Berat Badan / Usia', active: true),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _TogglePill(label: 'Tinggi Badan', active: false),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu berat badan.
        NuriCard(
          color: AppColors.canvasGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined,
                      size: 18, color: AppColors.brand),
                  const SizedBox(width: 8),
                  Text('BERAT BADAN SAAT INI',
                      style: AppText.label.copyWith(fontSize: 10.5)),
                  const Spacer(),
                  NuriSoftButton(
                    icon: Icons.image_outlined,
                    size: 36,
                    background: AppColors.surface,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: _fmtNum(weight), style: AppText.display),
                    TextSpan(
                      text: ' kg',
                      style:
                          AppText.bodySm.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    deltaGrams >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: _statusColor(status),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trend,
                      style: AppText.bodyStrong
                          .copyWith(color: _statusColor(status)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: MetricBox(
                label: 'Tinggi Badan',
                value: _fmtNum(height),
                unit: 'cm',
                trend: '${_fmtNum(latest.measurement.adjustedCm)} cm '
                    'terkoreksi',
                trendColor: _statusColor(status),
                icon: Icons.straighten,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricBox(
                label: 'Z-Score TB/U',
                value: result.zLabel,
                unit: 'SD',
                trend: status.label,
                trendColor: _statusColor(status),
                icon: Icons.insights_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grafik pita hijau WHO.
        NuriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text('Grafik Pita Hijau Sehat (WHO)',
                        style: AppText.h3),
                  ),
                  Tag(text: 'KMS Digital'),
                ],
              ),
              const SizedBox(height: 14),
              WhoGrowthChart(
                table: state.reference.whoLms,
                sex: child.sex,
                points: points,
                height: 210,
                maxMonth: 60,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  const _ChartLegend(
                    color: AppColors.pastelGreen,
                    label: 'Pita Hijau Ideal (Standar WHO)',
                  ),
                  _ChartLegend(
                    color: AppColors.brand,
                    label: 'Titik Tumbuh ${child.nickname}',
                    circular: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Analisis pertumbuhan dari status & rekomendasi.
        NuriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_border_rounded,
                      size: 20, color: AppColors.brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Arti Pertumbuhan ${child.nickname} Bulan Ini',
                      style: AppText.h3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Analisis Rantai Ibu & Balita',
                  style: AppText.caption),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _statusSoft(status),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(
                      icon: _statusIcon(status),
                      color: AppColors.surface,
                      iconColor: _statusColor(status),
                      size: 42,
                      radius: 14,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tag(
                            text: 'STATUS GIZI: ${status.label.toUpperCase()}',
                            color: AppColors.surface,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            recommendation?.title ?? status.plainLanguage,
                            style: AppText.h3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                recommendation?.summary ??
                    '${status.plainLanguage}. Pertumbuhan sehat memerlukan '
                        'pola makan bergizi seimbang, stimulasi, dan pemantauan '
                        'rutin di Posyandu.',
                style: AppText.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        NoteBox(
          background: AppColors.pastelPink,
          icon: Icons.favorite_border_rounded,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Pesan Hangat untuk Bunda\n',
                  style: AppText.bodyStrong,
                ),
                TextSpan(
                  text: 'Setiap anak bertumbuh dengan ritme masing-masing. '
                      'Yang terpenting adalah asupan gizi yang cukup dan '
                      'pemantauan rutin. Bunda telah merawat ${child.nickname} '
                      'dengan penuh cinta!',
                  style: AppText.bodySm,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        NuriPrimaryButton(
          label: 'Catat Pengukuran Mandiri Hari Ini',
          icon: Icons.add_circle_outline,
          onPressed: () => context.go('/screening'),
        ),
        const SizedBox(height: 18),

        // Jadwal berikutnya.
        NuriCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('JADWAL TIMBANG BERIKUTNYA',
                        style: AppText.label),
                    const SizedBox(height: 8),
                    Text(child.posyanduName ?? 'Posyandu',
                        style: AppText.h3),
                    const SizedBox(height: 4),
                    const Text('Ikuti pengingat dari Posyandu setempat',
                        style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              NuriSecondaryButton(
                label: 'Ingatkan',
                icon: Icons.notifications_none_rounded,
                expand: false,
                onPressed: () => context.go('/notifications'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Menu paci tumbuh.
        NuriCard(
          onTap: () => context.go('/nutrition'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MENU PACI TUMBUH', style: AppText.label),
                    const SizedBox(height: 8),
                    const Text('Protein Ganda: Ikan Kembung & Telur',
                        style: AppText.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Kaya zat besi & omega-3 untuk usia '
                      '${child.ageLabelAt(DateTime.now())}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.inkFaint),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ActionTile(
          title: 'Unduh KMS Lengkap (PDF)',
          subtitle: 'Salinan cetak untuk konsultasi & arsip digital',
          icon: Icons.download_rounded,
          trailing: NuriSecondaryButton(
            label: 'Unduh',
            expand: false,
            filled: true,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 22),

        SectionHeader(
          title: 'Riwayat Pengukuran',
          actionLabel: 'Lihat Semua',
          onAction: () => context.go('/meal-history'),
        ),
        const SizedBox(height: 12),
        _HistoryCard(
          records: records,
          posyandu: child.posyanduName ?? 'Posyandu',
        ),
        const SizedBox(height: 16),
        const NoteRow(
          icon: Icons.sync,
          text: 'Data tersinkron otomatis dengan buku register Posyandu & '
              'Puskesmas setempat.',
        ),
      ],
    );
  }
}

/// Kartu profil anak + status pengukuran terakhir.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child, required this.latest});

  final Child child;
  final ScreeningRecord? latest;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NuriAvatar(imageUrl: DemoImages.avatarChild, size: 56),
              const SizedBox(width: 14),
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
                            style: AppText.h3,
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded,
                            size: 20, color: AppColors.inkSoft),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Usia ${child.ageLabelAt(now)} • ${child.sex.label}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (latest == null)
            const Tag(text: 'Belum ada pengukuran')
          else
            Tag(
              text: 'Status: ${latest!.result.status.label}',
              color: _statusSoft(latest!.result.status),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 15, color: AppColors.inkFaint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  latest == null
                      ? 'Belum ada catatan pengukuran'
                      : '${_fmtDate(latest!.measurement.measuredOn)}'
                            '${child.posyanduName != null ? ' • ${child.posyanduName}' : ''}',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Daftar riwayat pengukuran (terbaru dulu).
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.records, required this.posyandu});

  final List<ScreeningRecord> records;
  final String posyandu;

  @override
  Widget build(BuildContext context) {
    final List<ScreeningRecord> history =
        records.reversed.take(6).toList(growable: false);
    if (history.isEmpty) {
      return const NuriCard(
        child: Text('Belum ada riwayat pengukuran.', style: AppText.body),
      );
    }
    return NuriCard(
      child: Column(
        children: [
          for (int i = 0; i < history.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: AppColors.line),
            _HistoryRow(
              date: _fmtDate(history[i].measurement.measuredOn),
              weight: '${_fmtNum(history[i].measurement.weightKg)} kg',
              height: '${_fmtNum(history[i].measurement.lengthHeightCm)} cm',
              status: history[i].result.status.label,
              statusColor: _statusColor(history[i].result.status),
              subtitle: posyandu,
              latest: i == 0,
            ),
          ],
        ],
      ),
    );
  }
}

/// Keadaan kosong saat belum ada anak.
class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        NuriCard(
          child: Column(
            children: [
              const IconBadge(
                icon: Icons.child_care_rounded,
                size: 60,
                radius: 20,
              ),
              const SizedBox(height: 14),
              const Text('Belum Ada Data Anak', style: AppText.h3),
              const SizedBox(height: 8),
              const Text(
                'Tambahkan profil anak untuk melihat kurva pertumbuhannya.',
                style: AppText.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              NuriPrimaryButton(
                label: 'Tambah anak',
                icon: Icons.add_rounded,
                onPressed: () => context.go('/child-data'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper format & warna.

const List<String> _idMonths = <String>[
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

String _fmtDate(DateTime date) =>
    '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

String _fmtNum(double value, {int digits = 1}) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');

Color _statusColor(GrowthStatus status) => switch (status) {
      GrowthStatus.sangatPendek => AppColors.statusSangatPendek,
      GrowthStatus.pendek => AppColors.statusPendek,
      GrowthStatus.normal => AppColors.statusNormal,
      GrowthStatus.tinggi => AppColors.statusTinggi,
    };

Color _statusSoft(GrowthStatus status) => switch (status) {
      GrowthStatus.sangatPendek => AppColors.statusSangatPendekSoft,
      GrowthStatus.pendek => AppColors.statusPendekSoft,
      GrowthStatus.normal => AppColors.statusNormalSoft,
      GrowthStatus.tinggi => AppColors.statusTinggiSoft,
    };

IconData _statusIcon(GrowthStatus status) => switch (status) {
      GrowthStatus.sangatPendek => Icons.health_and_safety_outlined,
      GrowthStatus.pendek => Icons.health_and_safety_outlined,
      GrowthStatus.normal => Icons.eco_rounded,
      GrowthStatus.tinggi => Icons.trending_up_rounded,
    };

// ---------------------------------------------------------------------------

class _GrowthTopBar extends StatelessWidget {
  const _GrowthTopBar();

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const NuriAvatar(imageUrl: DemoImages.avatarChild),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        child == null
                            ? 'Belum ada anak'
                            : '${child.nickname} • ${child.ageLabelAt(DateTime.now())}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            NuriSoftButton(
              icon: Icons.edit_outlined,
              onPressed: () => context.go('/screening'),
            ),
            const SizedBox(width: 8),
            NuriSoftButton(
              icon: Icons.calendar_today_outlined,
              onPressed: () => context.go('/notifications'),
            ),
            const SizedBox(width: 8),
            const NuriAvatar(imageUrl: DemoImages.avatarMother),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.brand : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: active ? null : Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: AppText.bodyStrong.copyWith(
          color: active ? Colors.white : AppColors.ink,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.color,
    required this.label,
    this.circular = false,
  });

  final Color color;
  final String label;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: circular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circular ? null : BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.date,
    required this.weight,
    required this.height,
    required this.status,
    required this.statusColor,
    required this.subtitle,
    this.latest = false,
  });

  final String date;
  final String weight;
  final String height;
  final String status;
  final Color statusColor;
  final String subtitle;
  final bool latest;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const NuriAvatar(
          icon: Icons.monitor_weight_outlined,
          size: 42,
          background: AppColors.pastelGreenSoft,
          color: AppColors.brand,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title.copyWith(fontSize: 14.5),
                    ),
                  ),
                  if (latest) ...[
                    const SizedBox(width: 8),
                    const Tag(text: 'Terbaru'),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(weight, style: AppText.title.copyWith(fontSize: 14.5)),
            const SizedBox(height: 2),
            Text(height, style: AppText.caption),
            const SizedBox(height: 2),
            Text(
              status,
              style: AppText.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
