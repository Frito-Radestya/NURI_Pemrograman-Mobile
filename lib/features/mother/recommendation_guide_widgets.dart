import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class RecommendationPortionGuide extends StatelessWidget {
  const RecommendationPortionGuide({
    super.key,
    required this.pregnancyMode,
    this.trimester = 2,
  });

  final bool pregnancyMode;
  final int trimester;

  @override
  Widget build(BuildContext context) {
    final items = pregnancyMode
        ? switch (trimester) {
            1 => const [
              (
                'Energi Trimester 1',
                '2.250 kkal/hari (+180 kkal) • porsi kecil 5–6x sehari',
                Icons.local_fire_department_rounded,
                AppColors.amber,
              ),
              (
                'Protein & Asam Folat',
                '60 g protein + 600 mcg folat untuk tabung saraf janin',
                Icons.fitness_center_rounded,
                AppColors.coral,
              ),
              (
                'Vitamin B6 & Zat Besi',
                '18 mg zat besi + Vit B6 & jahe hangat pereda mual',
                Icons.medication_rounded,
                AppColors.primary,
              ),
              (
                'Cairan & Elektrolit',
                '±2,3 liter air hangat/kaldu bening per hari',
                Icons.water_drop_rounded,
                AppColors.blue,
              ),
            ],
            2 => const [
              (
                'Energi Trimester 2',
                '2.550 kkal/hari (+300 kkal) untuk pacu tumbuh janin',
                Icons.local_fire_department_rounded,
                AppColors.amber,
              ),
              (
                'Protein Hewani & Nabati',
                '70 g protein/hari (ikan, telur, hati, daging, tempe)',
                Icons.fitness_center_rounded,
                AppColors.coral,
              ),
              (
                'Zat Besi & Kalsium',
                '18 mg besi (+ TTD rutin) & 1.200 mg kalsium tulang janin',
                Icons.medication_rounded,
                AppColors.primary,
              ),
              (
                'Cairan Harian',
                '±2,3–2,5 liter air putih per hari (8–10 gelas)',
                Icons.water_drop_rounded,
                AppColors.blue,
              ),
            ],
            _ => const [
              (
                'Energi Trimester 3',
                '2.550 kkal/hari (+300 kkal) & karbohidrat kompleks',
                Icons.local_fire_department_rounded,
                AppColors.amber,
              ),
              (
                'Protein Tinggi & DHA',
                '85 g protein/hari (+30 g) & Omega-3 untuk otak janin',
                Icons.fitness_center_rounded,
                AppColors.coral,
              ),
              (
                'Zat Besi Persalinan',
                '18 mg besi + TTD 90 tablet cegah perdarahan & anemia',
                Icons.medication_rounded,
                AppColors.primary,
              ),
              (
                'Serat & Cairan Laktasi',
                '±2,5 liter air + sayur/buah tinggi serat cegah sembelit',
                Icons.water_drop_rounded,
                AppColors.blue,
              ),
            ],
          }
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
