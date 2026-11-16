import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models.dart';
import '../../../domain/nutrition/nutrition_calculator.dart';
import '../../../shared/ui.dart';
import '../../../shared/widgets.dart';
import 'mother_today_card.dart';

class MotherNutritionCard extends StatefulWidget {
  const MotherNutritionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totals,
    required this.target,
    required this.onOpenDiary,
    required this.onLog,
    required this.primaryAction,
    this.onMeasure,
  });

  final String title;
  final String subtitle;
  final NutritionTotals totals;
  final AkgTarget target;
  final VoidCallback onOpenDiary;
  final VoidCallback onLog;
  final bool primaryAction;
  final VoidCallback? onMeasure;

  @override
  State<MotherNutritionCard> createState() => _MotherNutritionCardState();
}

class _MotherNutritionCardState extends State<MotherNutritionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final totals = widget.totals;
    final target = widget.target;
    final kcal = totals.kcal;
    final percent =
        (NutritionCalculator.percent(kcal, target.energyKcal) ?? 0) / 100;
    final status = NutritionCalculator.status(kcal, target.energyKcal);
    final statusColor = switch (status) {
      NutrientStatus.low => AppColors.amber,
      NutrientStatus.high => AppColors.coral,
      _ => AppColors.primary,
    };
    final statusLabel = switch (status) {
      NutrientStatus.low => 'Perlu dilengkapi',
      NutrientStatus.high => 'Melebihi anjuran',
      _ => 'Sesuai anjuran',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.onOpenDiary,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Catatan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CalorieRing(percent: percent, color: statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: kcal == null ? '—' : kcal.round().toString(),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.text,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${target.energyKcal.round()} kkal',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$statusLabel • ${target.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (totals.incomplete) ...[
                      const SizedBox(height: 3),
                      const Text(
                        'Sebagian nilai gizi belum lengkap',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 18,
              ),
              label: Text(
                _expanded ? 'Sembunyikan rincian' : 'Lihat rincian gizi',
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _MacroBar(
                    label: 'Protein',
                    value: totals.proteinG,
                    target: target.proteinG,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroBar(
                    label: 'Lemak',
                    value: totals.fatG,
                    target: target.fatG,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroBar(
                    label: 'Karbo',
                    value: totals.carbG,
                    target: target.carbG,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MicroValue(
                  label: 'Zat besi',
                  value: totals.ironMg,
                  unit: 'mg',
                ),
                const SizedBox(width: 10),
                _MicroValue(label: 'Zink', value: totals.zincMg, unit: 'mg'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (widget.primaryAction)
            NuriButton(
              label: 'Catat makan',
              icon: Icons.add_a_photo_outlined,
              height: 46,
              onPressed: widget.onLog,
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onLog,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Catat makan'),
              ),
            ),
          if (widget.onMeasure != null) ...[
            const Divider(height: 24),
            MotherTodayRow(
              icon: Icons.straighten_rounded,
              color: AppColors.primary,
              tint: AppColors.mint,
              title: 'Ukur anak',
              subtitle: 'Perbarui berat dan panjang badan',
              onTap: widget.onMeasure,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MicroValue extends StatelessWidget {
  const _MicroValue({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ),
            Text(
              value == null ? '—' : '${value!.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safe = percent.clamp(0.0, 1.0);
    return SizedBox(
      width: 68,
      height: 68,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: safe),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                backgroundColor: AppColors.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double? value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = ((value ?? 0) / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ),
            Text(
              value == null ? '—' : '${value!.round()}/${target.round()}g',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
