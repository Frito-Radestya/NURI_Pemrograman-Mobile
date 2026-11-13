import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/growth/growth_calculator.dart';
import '../../domain/growth/who_lms.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class GrowthDetailScreen extends ConsumerWidget {
  const GrowthDetailScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final children = state.myChildren;
    final child = state.activeChild;

    final header = embedded
        ? NuriPageHeader(
            title: 'Tumbuh Kembang',
            subtitle: 'Pantau panjang/tinggi badan terhadap standar WHO.',
            trailing: child == null
                ? null
                : RoundIconButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MeasurementInputScreen(childId: child.id),
                      ),
                    ),
                  ),
          )
        : ScreenHeader(
            title: 'Tumbuh Kembang',
            subtitle: 'Grafik WHO dan riwayat pengukuran',
            onBack: () => Navigator.of(context).pop(),
            action: child == null
                ? null
                : RoundIconButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MeasurementInputScreen(childId: child.id),
                      ),
                    ),
                  ),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: embedded ? 28 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              if (children.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: children.map((item) {
                        final selected = item.id == child?.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(item.nickname.split(' ').first),
                            selected: selected,
                            onSelected: (_) => ref
                                .read(appControllerProvider.notifier)
                                .selectChild(item.id),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.text,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (child == null)
                const EmptyState(
                  title: 'Belum ada data anak',
                  body: 'Tambahkan data anak untuk melihat grafik pertumbuhan.',
                  icon: Icons.child_care_rounded,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GrowthSummary(child: child),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _WhoChartCard(child: child),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MeasurementNote(child: child),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Riwayat pengukuran',
                    subtitle: '${child.measurements.length} catatan tersimpan',
                    actionLabel: 'Semua',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GrowthHistoryScreen(childId: child.id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HistoryPreview(child: child),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: NuriDisclaimer(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GrowthSummary extends StatelessWidget {
  const _GrowthSummary({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: child.nickname,
                index: child.avatarIndex,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.nickname,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${child.ageLabel()} • ${child.sex.label}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (latest != null) GrowthStatusBadge(category: latest.category),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _SummaryStat(
                  label: 'Berat',
                  value: latest == null ? '—' : fmt1(latest.weightKg),
                  unit: 'kg',
                ),
                _SummaryStat(
                  label: 'TB / PB',
                  value: latest == null ? '—' : fmt1(latest.measuredCm),
                  unit: 'cm',
                ),
                _SummaryStat(
                  label: 'Z-score',
                  value: latest == null
                      ? '—'
                      : '${latest.zHfa >= 0 ? '+' : ''}${fmt2(latest.zHfa)}',
                  unit: 'SD',
                  color: latest == null
                      ? AppColors.text
                      : GrowthStatusBadge.colorsFor(latest.category).$2,
                ),
                _SummaryStat(
                  label: 'Diukur',
                  value: latest == null
                      ? '—'
                      : formatDateId(
                          latest.date,
                          withYear: false,
                          shortMonth: true,
                        ),
                  unit: '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.public_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'WHO Child Growth Standards 2006 • panjang/tinggi menurut umur',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.unit,
    this.color = AppColors.text,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

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
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: color,
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

class _WhoChartCard extends StatelessWidget {
  const _WhoChartCard({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final table = WhoReference.instance.forSex(child.sex);
    List<FlSpot> reference(double z) => List.generate(60, (month) {
      final days = month * 30.4375;
      return FlSpot(month.toDouble(), table.valueAtZ(days, z));
    });

    final childSpots =
        child.measurements
            .where((m) => m.ageDays <= 1856)
            .map((m) => FlSpot(m.ageDays / 30.4375, m.correctedCm))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    final lineBars = <LineChartBarData>[
      _referenceLine(
        reference(-3),
        AppColors.red.withValues(alpha: 0.6),
        dash: true,
      ),
      _referenceLine(
        reference(-2),
        AppColors.amber.withValues(alpha: 0.7),
        dash: true,
      ),
      _referenceLine(reference(0), AppColors.primary, width: 2.2),
      _referenceLine(
        reference(2),
        AppColors.amber.withValues(alpha: 0.7),
        dash: true,
      ),
      _referenceLine(
        reference(3),
        AppColors.red.withValues(alpha: 0.6),
        dash: true,
      ),
      if (childSpots.isNotEmpty)
        LineChartBarData(
          spots: childSpots,
          isCurved: false,
          barWidth: 2.5,
          color: AppColors.coral,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4.5,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.coral,
                ),
          ),
        ),
    ];

    if (childSpots.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Grafik Pertumbuhan ${child.nickname}',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Grafik pertumbuhan masih kosong karena panjang atau tinggi badan Si Kecil belum dicatat. Catat pengukuran pertama di bawah untuk melihat kurva pertumbuhan.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Area Hijau: Rentang Tumbuh Normal (WHO)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final latestCat = child.latestMeasurement?.category;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Grafik Pertumbuhan ${child.nickname}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Pill(
                label: '0–59 bulan',
                background: AppColors.surfaceSubtle,
                foreground: AppColors.primaryDark,
                fontSize: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Sumbu tegak: panjang/tinggi (cm) • Sumbu mendatar: umur (bulan)',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      border: Border.all(color: AppColors.primary, width: 1.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Rentang Tumbuh Normal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Si Kecil (${child.nickname})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 245,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 60,
                minY: 45,
                maxY: 120,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.line.withValues(alpha: 0.9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 1,
                    toIndex: 3,
                    color: AppColors.mint.withValues(alpha: 0.65),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 10,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 12,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${value.toInt()} bl',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.text,
                    tooltipBorderRadius: BorderRadius.circular(10),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    maxContentWidth: 180,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) {
                      final childSpot = spots.firstWhere(
                        (s) => s.barIndex == lineBars.length - 1,
                        orElse: () => spots.first,
                      );
                      return [
                        LineTooltipItem(
                          '${child.nickname}: ${childSpot.y.toStringAsFixed(1)} cm\n(Usia ${childSpot.x.toInt()} bulan)',
                          const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ];
                    },
                  ),
                ),
                lineBarsData: lineBars,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: latestCat == GrowthCategory.normal
                  ? AppColors.mint
                  : AppColors.peachSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  latestCat == GrowthCategory.normal
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: latestCat == GrowthCategory.normal
                      ? AppColors.primary
                      : AppColors.coral,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    latestCat == GrowthCategory.normal
                        ? '${child.nickname} tumbuh optimal di dalam area hijau sesuai standar umur.'
                        : '${child.nickname} berada di status ${latestCat?.plainLabel ?? "perlu pantauan"}. Disarankan konsultasi ke bidan/Puskesmas.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: latestCat == GrowthCategory.normal
                          ? AppColors.primaryDark
                          : AppColors.coral,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _referenceLine(
    List<FlSpot> spots,
    Color color, {
    double width = 1.3,
    bool dash = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      barWidth: width,
      color: color,
      dashArray: dash ? const [5, 4] : null,
      dotData: const FlDotData(show: false),
    );
  }
}

class _MeasurementNote extends StatelessWidget {
  const _MeasurementNote({required this.child});

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

class _HistoryPreview extends StatelessWidget {
  const _HistoryPreview({required this.child});

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
            _HistoryTile(
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.measurement, required this.onTap});

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

class MeasurementInputScreen extends ConsumerStatefulWidget {
  const MeasurementInputScreen({
    super.key,
    required this.childId,
    this.isCadre = false,
  });

  final String childId;
  final bool isCadre;

  @override
  ConsumerState<MeasurementInputScreen> createState() =>
      _MeasurementInputScreenState();
}

class _MeasurementInputScreenState
    extends ConsumerState<MeasurementInputScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());
  MeasurementMethod? _method;
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  (GrowthEvaluation?, String?) _evaluate(Child child) {
    final weight = _parse(_weight);
    final height = _parse(_height);
    if (weight == null || height == null) return (null, null);
    final method =
        _method ??
        GrowthCalculator.defaultMethodForAge(child.ageMonthsAt(_date));
    try {
      final evaluation = GrowthCalculator(reference: WhoReference.instance)
          .evaluate(
            heightCm: height,
            weightKg: weight,
            sex: child.sex,
            dob: child.dob,
            measureDate: _date,
            method: method,
          );
      return (evaluation, null);
    } on GrowthValidationException catch (error) {
      return (null, error.message);
    }
  }

  Future<void> _save(Child child, GrowthEvaluation? evaluation) async {
    FocusScope.of(context).unfocus();
    final weight = _parse(_weight);
    final height = _parse(_height);
    if (weight == null || height == null) {
      showNuriSnack(
        context,
        'Lengkapi berat dan panjang/tinggi badan.',
        error: true,
      );
      return;
    }
    if (evaluation != null && evaluation.implausible) {
      final proceed = await showNuriConfirm(
        context: context,
        title: 'Nilai sangat tidak biasa',
        message:
            'Z-score ${evaluation.zScore.toStringAsFixed(1)} SD berada di luar batas wajar. Periksa kembali alat ukur dan tanggal lahir sebelum menyimpan.',
        confirmLabel: 'Simpan tetap',
        danger: true,
      );
      if (!proceed || !mounted) return;
    }
    setState(() => _saving = true);
    final result = ref
        .read(appControllerProvider.notifier)
        .addMeasurement(
          childId: child.id,
          weightKg: weight,
          heightCm: height,
          date: _date,
          method:
              _method ??
              GrowthCalculator.defaultMethodForAge(child.ageMonthsAt(_date)),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result == null) {
      showNuriSnack(
        context,
        'Pengukuran gagal disimpan. Coba lagi.',
        error: true,
      );
      return;
    }
    final status = result.category.plainLabel;
    if (!widget.isCadre) {
      showNuriSnack(context, 'Pengukuran tersimpan • $status');
      Navigator.of(context).pop(result);
      return;
    }

    final next = _nextWaitingChild(child.id);
    await showNuriSheet<void>(
      context: context,
      isDismissible: false,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengukuran tersimpan',
                        style: Theme.of(sheetContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${child.nickname} • $status',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InfoBanner(
              title:
                  'Berat ${fmt1(result.weightKg)} kg • Panjang ${fmt1(result.measuredCm)} cm',
              body: 'Sasaran otomatis ditandai hadir pada sesi ini.',
              icon: Icons.straighten_rounded,
            ),
            const SizedBox(height: 14),
            if (next != null) ...[
              NuriButton(
                label: 'Ukur ${next.name} berikutnya',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MeasurementInputScreen(
                        childId: next.subjectId!,
                        isCadre: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Selesai'),
                ),
              ),
            ] else
              NuriButton(
                label: 'Kembali ke sesi',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
          ],
        ),
      ),
    );
  }

  RosterEntry? _nextWaitingChild(String currentChildId) {
    final roster = ref.read(appControllerProvider).roster;
    final candidates =
        roster
            .where(
              (entry) =>
                  entry.type == RosterType.child &&
                  entry.attendance == AttendanceStatus.waiting &&
                  entry.subjectId != null &&
                  entry.subjectId != currentChildId,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return candidates.isEmpty ? null : candidates.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    Child? child;
    for (final item in state.children) {
      if (item.id == widget.childId) {
        child = item;
        break;
      }
    }

    if (child == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Input pengukuran',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(
                  title: 'Data anak tidak ditemukan',
                  body: 'Pilih sasaran lain dari daftar.',
                  icon: Icons.person_search_rounded,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeChild = child;
    final method =
        _method ??
        GrowthCalculator.defaultMethodForAge(activeChild.ageMonthsAt(_date));
    final (evaluation, error) = _evaluate(activeChild);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Input pengukuran',
              subtitle: activeChild.nickname,
              eyebrow: widget.isCadre
                  ? 'Kader • Sesi posyandu'
                  : 'Catatan mandiri',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppAvatar(
                                name: activeChild.nickname,
                                index: activeChild.avatarIndex,
                                size: 42,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeChild.nickname,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${activeChild.ageLabel(_date)} • ${activeChild.sex.label}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (activeChild.latestMeasurement != null)
                                GrowthStatusBadge(
                                  category:
                                      activeChild.latestMeasurement!.category,
                                  compact: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          NuriDateField(
                            label: 'Tanggal ukur',
                            value: _date,
                            firstDate: activeChild.dob,
                            lastDate: DateTime.now(),
                            onChanged: (value) => setState(() {
                              _date = dateOnly(value);
                              _method = null;
                            }),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'Berat badan (kg)',
                                  controller: _weight,
                                  hint: '11,2',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'Panjang/tinggi (cm)',
                                  controller: _height,
                                  hint: '82,5',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const NuriFormLabel(text: 'Cara ukur'),
                          NuriSegmentedControl<MeasurementMethod>(
                            values: MeasurementMethod.values,
                            selected: method,
                            labelFor: (value) =>
                                value == MeasurementMethod.lying
                                ? 'Berbaring'
                                : 'Berdiri',
                            onChanged: (value) =>
                                setState(() => _method = value),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeChild.ageMonthsAt(_date) < 24
                                ? 'Usia < 24 bulan: ukur berbaring (PB). Bila berdiri, NURI menambahkan koreksi +0,7 cm.'
                                : 'Usia ≥ 24 bulan: ukur berdiri (TB). Bila berbaring, NURI mengurangi 0,7 cm.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (error != null)
                      InfoBanner(
                        title: 'Periksa input',
                        body: error,
                        icon: Icons.error_outline_rounded,
                        background: AppColors.redSoft,
                        foreground: AppColors.red,
                      )
                    else if (evaluation != null)
                      _PreviewCard(evaluation: evaluation)
                    else
                      const InfoBanner(
                        title: 'Pratinjau z-score',
                        body: 'Isi berat dan panjang/tinggi badan untuk melihat klasifikasi WHO sebelum menyimpan.',
                        icon: Icons.insights_rounded,
                      ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan pengukuran',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: () => _save(activeChild, evaluation),
                    ),
                    const SizedBox(height: 8),
                    const NuriDisclaimer(compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.evaluation});

  final GrowthEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final colors = GrowthStatusBadge.colorsFor(evaluation.category);
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: colors.$1,
      borderColor: colors.$1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pratinjau skrining',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              GrowthStatusBadge(category: evaluation.category),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${evaluation.zScore >= 0 ? '+' : ''}${evaluation.zScore.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1,
                  color: colors.$2,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'SD',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.$2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Median WHO ${evaluation.medianCm.toStringAsFixed(1)} cm',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rentang normal: ${evaluation.minus2Cm.toStringAsFixed(1)}–${evaluation.plus2Cm.toStringAsFixed(1)} cm untuk usia ${evaluation.ageMonths} bulan.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          if (evaluation.correctionNote != null) ...[
            const SizedBox(height: 6),
            Text(
              evaluation.correctionNote!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ],
          if (evaluation.implausible) ...[
            const SizedBox(height: 8),
            const Text(
              'Nilai z di luar ±6 SD. Periksa kembali sebelum menyimpan.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GrowthHistoryScreen extends ConsumerWidget {
  const GrowthHistoryScreen({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    Child? child;
    for (final item in state.children) {
      if (item.id == childId) {
        child = item;
        break;
      }
    }
    if (child == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Riwayat',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(child: EmptyState(title: 'Data tidak ditemukan')),
            ],
          ),
        ),
      );
    }
    final list = List<Measurement>.from(child.measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Riwayat pengukuran',
              subtitle: child.nickname,
              onBack: () => Navigator.of(context).pop(),
              action: RoundIconButton(
                icon: Icons.add_rounded,
                filled: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeasurementInputScreen(childId: child!.id),
                  ),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      title: 'Belum ada pengukuran',
                      body: 'Catat pengukuran pertama untuk melihat riwayat.',
                      icon: Icons.straighten_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final measurement = list[index];
                        return AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => showMeasurementDetail(
                            context,
                            child!,
                            measurement,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.straighten_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDateId(measurement.date),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${measurement.ageMonths} bulan • ${fmt1(measurement.measuredCm)} cm • ${fmt1(measurement.weightKg)} kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GrowthStatusBadge(
                                category: measurement.category,
                                compact: true,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 19,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
