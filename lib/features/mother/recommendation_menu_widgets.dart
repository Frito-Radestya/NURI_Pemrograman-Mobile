import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RecommendationTrimesterGuideCard extends StatelessWidget {
  const RecommendationTrimesterGuideCard({super.key, required this.trimester});

  final int trimester;

  @override
  Widget build(BuildContext context) {
    final target = const AkgReference().forPregnancy(trimester);
    final (title, focus, tip, microFocus) = switch (trimester) {
      1 => (
        'Trimester 1 (Minggu 1–13): Asam Folat & Anti-Mual',
        'Pembentukan tabung saraf & organ vital janin. Target energi ${target.energyKcal.round()} kkal & protein ${target.proteinG.round()} g/hari.',
        'Makan porsi kecil tapi sering (5–6x sehari), pilih kuah hangat beraroma jahe, dan utamakan folat & vitamin B6.',
        'Folat 600 mcg • Vit B6 • Besi ${target.ironMg.round()} mg',
      ),
      2 => (
        'Trimester 2 (Minggu 14–27): Tulang Janin & Cegah Anemia',
        'Pertumbuhan kerangka & organ janin (+300 kkal). Target energi ${target.energyKcal.round()} kkal & protein ${target.proteinG.round()} g/hari.',
        'Wajib ada lauk protein hewani (ikan, telur, hati, daging) setiap makan utama ditambah TTD rutin & kalsium.',
        'Kalsium 1200 mg • Besi ${target.ironMg.round()} mg + TTD • Zink ${target.zincMg.round()} mg',
      ),
      _ => (
        'Trimester 3 (Minggu 28–40): Otak Janin, Persalinan & ASI',
        'Pematangan otak, paru, dan cadangan zat besi persalinan. Target energi ${target.energyKcal.round()} kkal & protein tinggi ${target.proteinG.round()} g/hari.',
        'Tingkatkan protein hewani (+30 g), asam lemak DHA/Omega-3 dari ikan laut, serta serat & air untuk cegah sembelit.',
        'Protein ${target.proteinG.round()} g • DHA Omega-3 • Besi ${target.ironMg.round()} mg',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            focus,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(
                label: '${target.energyKcal.round()} kkal/hari',
                background: AppColors.peachSoft,
                foreground: AppColors.coral,
                fontSize: 10.5,
                bold: true,
              ),
              Pill(
                label: 'Protein ${target.proteinG.round()} g',
                background: AppColors.mint,
                foreground: AppColors.primaryDark,
                fontSize: 10.5,
                bold: true,
              ),
              Pill(
                label: microFocus,
                background: AppColors.surfaceSubtle,
                foreground: AppColors.onSurfaceVariant,
                fontSize: 10.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuIdea {
  const MenuIdea({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.kcal,
    required this.protein,
    required this.minutes,
    required this.tags,
    required this.ingredients,
    required this.steps,
    this.mealType = MealType.lunch,
    this.grams = 250,
    this.fatG = 14,
    this.carbG = 60,
    this.ironMg = 3.5,
    this.zincMg = 2.2,
    this.benefitNote,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final int kcal;
  final int protein;
  final int minutes;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> steps;
  final MealType mealType;
  final double grams;
  final double fatG;
  final double carbG;
  final double ironMg;
  final double zincMg;
  final String? benefitNote;

  FoodLogItem toFoodLogItem() {
    final factor = 100.0 / (grams <= 0 ? 250.0 : grams);
    return FoodLogItem(
      foodId: id,
      name: title,
      grams: grams,
      kcalPer100: kcal * factor,
      proteinPer100: protein * factor,
      fatPer100: fatG * factor,
      carbPer100: carbG * factor,
      ironPer100: ironMg * factor,
      zincPer100: zincMg * factor,
      source: FoodSource.recipe,
    );
  }
}

class RecommendationHeroBanner extends StatelessWidget {
  const RecommendationHeroBanner({
    super.key,
    required this.pregnancyMode,
    this.trimester = 2,
  });

  final bool pregnancyMode;
  final int trimester;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (trimester) {
      1 =>
        'Trimester 1 fokus pada asam folat tinggi, vitamin B6 pereda mual, serta porsi kecil padat nutrisi.',
      2 =>
        'Trimester 2 membutuhkan tambahan +300 kkal, protein hewani, zat besi, dan kalsium untuk tulang & organ janin.',
      _ =>
        'Trimester 3 membutuhkan protein tinggi (85 g/hari), DHA Omega-3 untuk otak janin, serta zat besi persiapan persalinan & ASI.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.peachSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregnancyMode
                ? 'Gizi Ibu Hamil • Trimester $trimester'
                : 'Gizi Balita',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pregnancyMode
                ? 'Menu terukur sesuai kebutuhan tiap trimester.'
                : 'Piring kecil, gizi lengkap.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pregnancyMode
                ? subtitle
                : 'Setiap makan usahakan ada makanan pokok, protein hewani, sayur, dan buah.',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationMenuCard extends StatelessWidget {
  const RecommendationMenuCard({
    super.key,
    required this.menu,
    required this.selected,
    required this.onToggle,
    required this.onRecipe,
    this.onLogMeal,
  });

  final MenuIdea menu;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRecipe;
  final VoidCallback? onLogMeal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: selected ? AppColors.primary : AppColors.line,
      color: selected ? AppColors.mint : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NuriImage(asset: menu.image, width: 84, height: 84, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Pill(
                          label: menu.mealType.label,
                          background: AppColors.primarySoft,
                          foreground: AppColors.primaryDark,
                          fontSize: 10,
                          bold: true,
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: onToggle,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.5,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      menu.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: menu.tags
                          .map(
                            (tag) => Pill(
                              label: tag,
                              background: AppColors.surfaceSubtle,
                              foreground: AppColors.text,
                              fontSize: 10.5,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 15,
                color: AppColors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                '${menu.kcal} kkal',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.fitness_center_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 3),
              Text(
                '${menu.protein}g prot',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.bloodtype_rounded,
                size: 14,
                color: AppColors.coral,
              ),
              const SizedBox(width: 2),
              Text(
                '${menu.ironMg.toStringAsFixed(1)}mg Fe',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onRecipe,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Resep',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              if (onLogMeal != null) ...[
                const SizedBox(width: 4),
                FilledButton.tonalIcon(
                  onPressed: onLogMeal,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 15),
                  label: const Text(
                    'Catat',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendationRecipeMetric extends StatelessWidget {
  const RecommendationRecipeMetric({
    super.key,
    required this.icon,
    required this.value,
  });
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
