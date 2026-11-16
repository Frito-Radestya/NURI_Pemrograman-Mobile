import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class RecommendationPortionGuide extends StatelessWidget {
  const RecommendationPortionGuide({super.key, required this.pregnancyMode});

  final bool pregnancyMode;

  @override
  Widget build(BuildContext context) {
    final items = pregnancyMode
        ? const [
            (
              'Energi',
              'Tambahan ±300 kkal pada trimester 2–3',
              Icons.local_fire_department_rounded,
              AppColors.amber,
            ),
            (
              'Protein',
              '70–85 g per hari',
              Icons.fitness_center_rounded,
              AppColors.coral,
            ),
            (
              'Zat besi',
              '18 mg per hari + TTD 90 tablet',
              Icons.medication_rounded,
              AppColors.primary,
            ),
            (
              'Cairan',
              '±2,3 liter per hari',
              Icons.water_drop_rounded,
              AppColors.blue,
            ),
          ]
        : const [
            (
              'Makanan pokok',
              '100 g nasi / 2–3 kali sehari',
              Icons.rice_bowl_rounded,
              AppColors.amber,
            ),
            (
              'Protein hewani',
              '35 g ikan/telur/ayam per hari',
              Icons.fitness_center_rounded,
              AppColors.coral,
            ),
            (
              'Sayur & buah',
              '50 g sayur + 50 g buah',
              Icons.eco_rounded,
              AppColors.primary,
            ),
            (
              'Lemak tambahan',
              '5 g minyak / santan secukupnya',
              Icons.water_drop_rounded,
              AppColors.blue,
            ),
          ];
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: items[i].$4.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(items[i].$3, size: 18, color: items[i].$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].$1,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          items[i].$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class RecommendationFourStarGrid extends StatelessWidget {
  const RecommendationFourStarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Makanan pokok',
        'Nasi, kentang, jagung',
        Icons.rice_bowl_rounded,
        AppColors.amber,
      ),
      (
        'Protein hewani',
        'Ikan, telur, ayam, hati',
        Icons.set_meal_rounded,
        AppColors.coral,
      ),
      ('Sayur', 'Bayam, wortel, buncis', Icons.eco_rounded, AppColors.primary),
      ('Buah', 'Pisang, pepaya, jeruk', Icons.apple_rounded, AppColors.blue),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.7,
      children: items.map((item) {
        return AppCard(
          padding: const EdgeInsets.all(12),
          radius: 15,
          child: Row(
            children: [
              Icon(item.$3, size: 22, color: item.$4),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class RecommendationStepsCard extends StatelessWidget {
  const RecommendationStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Isi setengah piring dengan sayur dan buah.',
      'Sisakan seperempat untuk makanan pokok.',
      'Isi seperempat lagi dengan protein hewani.',
      'Tambahkan sedikit lemak sehat dan air putih.',
    ];
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(fontSize: 13, height: 1.45),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
