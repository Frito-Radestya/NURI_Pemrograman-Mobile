import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../core/widgets/who_growth_chart.dart';
import '../../data/nuri_repository.dart';
import '../../domain/models/child.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/growth_status.dart';
import '../../domain/models/recommendation.dart';
import '../../state/app_state.dart';

/// Hasil skrining dini stunting si kecil.
class ScreeningResultScreen extends StatefulWidget {
  const ScreeningResultScreen({super.key});

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen> {
  bool _disclaimerRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_disclaimerRequested) return;
    _disclaimerRequested = true;
    // Tandai disclaimer telah dibaca saat layar hasil dibuka (F2).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NuriScope.read(context).acceptDisclaimer();
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/screening');
    }
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final ScreeningRecord? latest = state.latestForSelected;

    return NuriScaffold(
      topBar: NuriTopBar(
        showBack: true,
        onBack: _back,
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SKRINING DINI STUNTING', style: AppText.caption),
            const NuriBrand(markSize: 22, fontSize: 16),
          ],
        ),
        actions: [
          NuriSoftButton(icon: Icons.help_outline, onPressed: () {}),
          const SizedBox(width: 8),
          const NuriAvatar(imageUrl: DemoImages.avatarMother),
        ],
      ),
      body: child == null
          ? _EmptyState(
              title: 'Belum Ada Data Anak',
              message: 'Tambahkan profil anak untuk melihat hasil skrining.',
              actionLabel: 'Tambah anak',
              route: '/child-data',
            )
          : latest == null
              ? _EmptyState(
                  title: 'Belum Ada Hasil',
                  message: 'Ukur berat dan tinggi ${child.nickname} terlebih '
                      'dahulu untuk melihat hasil skrining.',
                  actionLabel: 'Ukur sekarang',
                  route: '/screening',
                )
              : _ResultBody(state: state, child: child),
    );
  }
}

/// Isi hasil skrining ketika data tersedia.
class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.state, required this.child});

  final NuriAppState state;
  final Child child;

  @override
  Widget build(BuildContext context) {
    final ScreeningRecord latest = state.latestForSelected!;
    final GrowthResult result = latest.result;
    final GrowthStatus status = result.status;
    final Recommendation? recommendation = result.recommendation ??
        state.reference.recommendations.find(status, result.ageMonths);
    final List<String> actions =
        recommendation?.actions ?? _fallbackActions;
    final List<ScreeningRecord> records = state.screeningsFor(child.id);
    final List<WhoChartPoint> points = <WhoChartPoint>[
      for (int i = 0; i < records.length; i++)
        WhoChartPoint(
          month: records[i].result.ageMonths,
          cm: records[i].measurement.adjustedCm,
          isLatest: i == records.length - 1,
        ),
    ];
    final DateTime now = DateTime.now();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PillLabel(text: 'Hasil Skrining'),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brand,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Skrining Dini Stunting', style: AppText.bodySm),
            ],
          ),
          const SizedBox(height: 18),

          // Kartu profil anak.
          NuriCard(
            child: Row(
              children: [
                const IconBadge(icon: Icons.eco_rounded),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.nickname, style: AppText.h3),
                      const SizedBox(height: 2),
                      Text(
                        '${child.ageLabelAt(now)} • ${child.sex.label}',
                        style: AppText.bodySm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const NuriPhoto(
                  url: DemoImages.riceFish,
                  width: 56,
                  height: 56,
                  radius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Banner status sesuai GrowthStatus.
          NuriCard(
            color: _statusSoft(status),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(status),
                    color: _statusColor(status),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(
                        text: 'STATUS: ${status.label.toUpperCase()}',
                        color: AppColors.surface,
                        onColor: _statusColor(status),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Z-score ${result.zLabel} SD • Baku WHO',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Text(
            'Tumbuh Kembang ${child.nickname}: ${status.plainLanguage}',
            style: AppText.h2,
          ),
          const SizedBox(height: 10),
          Text(
            recommendation?.summary ??
                '${status.plainLanguage}. Laju pertumbuhan dapat dipantau '
                    'melalui kurva baku WHO dan asupan gizi harian.',
            style: AppText.body,
          ),
          if (result.methodAdjusted) ...[
            const SizedBox(height: 14),
            NoteRow(
              icon: Icons.straighten,
              text: 'Disesuaikan '
                  '${result.correctedCm - result.rawCm >= 0 ? '+' : '−'}'
                  '${_fmtNum((result.correctedCm - result.rawCm).abs())} cm '
                  'karena perbedaan metode ukur '
                  '(${result.method.shortLabel} → '
                  '${result.recommendedMethod.shortLabel}).',
            ),
          ],
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: MetricBox(
                  label: 'Berat Badan',
                  value: _fmtNum(latest.measurement.weightKg),
                  unit: 'kg',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricBox(
                  label: 'Tinggi Badan',
                  value: _fmtNum(latest.measurement.lengthHeightCm),
                  unit: 'cm',
                  icon: Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          const SectionHeader(
            title: 'Tren Pertumbuhan',
            subtitle: 'Kurva baku WHO tinggi/panjang menurut umur',
          ),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      label: 'Pita hijau −2 s.d. +2 SD',
                    ),
                    _ChartLegend(
                      color: AppColors.brand,
                      label: 'Titik ${child.nickname}',
                      circular: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          SectionHeader(
            title: 'Apa yang Bisa Dilakukan',
            subtitle: recommendation?.title,
          ),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          actions[i],
                          style: AppText.bodySm.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          NoteBox(
            background: AppColors.surfaceSand,
            icon: Icons.favorite_border,
            child: RichText(
              text: TextSpan(
                style: AppText.bodySm,
                children: [
                  const TextSpan(
                    text: 'Pesan Kasih Bunda dari NURI',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  TextSpan(
                    text: '\nBunda, sudah menjadi perjalanan hebat mendampingi '
                        '${child.nickname}. Terus pantau perkembangannya, NURI '
                        'siap menemani Bunda menjaga asupan gizi seimbang '
                        'setiap hari.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          NuriPrimaryButton(
            label: 'Lihat Menu Gizi Hari Ini',
            trailingArrow: true,
            onPressed: () => context.go('/nutrition'),
          ),
          const SizedBox(height: 14),
          ActionTile(
            title: '${child.posyanduName ?? 'Posyandu'} • Jadwal berikutnya',
            icon: Icons.event_available_outlined,
            showChevron: false,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Unduh PDF',
                  icon: Icons.download_rounded,
                  filled: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Kirim ke Kader Posyandu',
                  icon: Icons.send_outlined,
                  filled: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // DISCLAIMER wajib (F2).
          const Text('DISCLAIMER', style: AppText.label),
          const SizedBox(height: 8),
          const NoteBox(
            background: AppColors.surfaceSand,
            icon: Icons.info_outline,
            child: Text(
              'Skrining awal, bukan diagnosis medis. Untuk keluhan, '
              'konsultasikan ke tenaga kesehatan.',
              style: AppText.bodySm,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Keadaan kosong dengan satu tombol aksi.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.route,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        NuriCard(
          child: Column(
            children: [
              const IconBadge(
                icon: Icons.assignment_outlined,
                size: 60,
                radius: 20,
              ),
              const SizedBox(height: 14),
              Text(title, style: AppText.h3),
              const SizedBox(height: 8),
              Text(message, style: AppText.body, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              NuriPrimaryButton(
                label: actionLabel,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go(route),
              ),
            ],
          ),
        ),
      ],
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

// ---------------------------------------------------------------------------
// Helper & konten cadangan.

const List<String> _fallbackActions = <String>[
  'Berikan makanan bergizi seimbang sesuai usia anak.',
  'Lanjutkan pemantauan pertumbuhan rutin di Posyandu.',
  'Konsultasikan ke tenaga kesehatan bila ada kekhawatiran.',
];

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
      GrowthStatus.normal => Icons.check_circle_rounded,
      GrowthStatus.tinggi => Icons.trending_up_rounded,
    };
