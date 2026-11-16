import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'diary_screen.dart';

class FoodSuccessScreen extends StatelessWidget {
  const FoodSuccessScreen({
    super.key,
    required this.log,
    required this.subjectLabel,
  });

  final FoodLog log;
  final String subjectLabel;

  @override
  Widget build(BuildContext context) {
    final totals = log.totals;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.mintStrong, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Catatan makan tersimpan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Terima kasih sudah mencatat untuk $subjectLabel. Catatan kecil membantu melihat pola gizi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Energi',
                            value: totals.kcal == null
                                ? '—'
                                : '${totals.kcal!.round()}',
                            unit: 'kkal',
                          ),
                        ),
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Protein',
                            value: totals.proteinG == null
                                ? '—'
                                : totals.proteinG!.toStringAsFixed(1),
                            unit: 'g',
                          ),
                        ),
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Makanan',
                            value: '${log.items.length}',
                            unit: 'item',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          log.meal.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            log.items.map((e) => e.name).join(', '),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const InfoBanner(
                title: 'Skrining awal, bukan diagnosis',
                body: 'Nilai gizi dihitung dari data TKPI 2017. Diskusikan dengan kader atau ahli gizi bila ada kekhawatiran.',
                icon: Icons.verified_user_outlined,
              ),
              const Spacer(),
              NuriButton(
                label: 'Lihat catatan hari ini',
                icon: Icons.calendar_today_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => DiaryScreen(
                      subjectId: log.subjectId,
                      subjectLabel: subjectLabel,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              NuriButton(
                label: 'Selesai',
                variant: NuriButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMetric extends StatelessWidget {
  const _SuccessMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: AppColors.text,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
