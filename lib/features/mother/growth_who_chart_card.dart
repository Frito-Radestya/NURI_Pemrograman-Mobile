import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/growth/who_lms.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class GrowthWhoChartCard extends StatelessWidget {
  const GrowthWhoChartCard({super.key, required this.child});

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
      _referenceLine(reference(0), AppColors.deepForest, width: 2.2),
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
          color: AppColors.freshGreen,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 5.0,
                  color: AppColors.leafGreen,
                  strokeWidth: 2.2,
                  strokeColor: AppColors.deepForest,
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
                color: AppColors.deepForest,
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
                      color: AppColors.green.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Area Hijau: Rentang Tumbuh Normal (WHO)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
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
                      color: AppColors.greenSoft,
                      border: Border.all(color: AppColors.green, width: 1.2),
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
                    decoration: BoxDecoration(
                      color: AppColors.freshGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepForest,
                        width: 1.5,
                      ),
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
